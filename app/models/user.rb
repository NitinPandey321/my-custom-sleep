class User < ApplicationRecord
  has_secure_password

  enum :status, { on_track: 0, needs_attention: 1, falling_behind: 2 }, prefix: true

  has_many :email_logs, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :daily_reflections, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :sleep_records, dependent: :destroy
  has_one :sleep_metric, dependent: :destroy
  has_many :user_activity_logs, dependent: :destroy

  # ActiveStorage association for profile picture
  has_one_attached :profile_picture

  # Coach-Client relationships
  belongs_to :coach, class_name: "User", optional: true
  has_many :clients, class_name: "User", foreign_key: "coach_id"

  validates :first_name, presence: { message: "First name is required." },
                        format: { with: /\A[a-zA-Z\-'\s]+\z/, message: "First name can only contain letters, hyphens, and apostrophes." },
                        length: { maximum: 50, message: "First name cannot exceed 50 characters." }

  validates :last_name, presence: { message: "Last name is required." },
                       format: { with: /\A[a-zA-Z\-'\s]+\z/, message: "Last name can only contain letters, hyphens, and apostrophes." },
                       length: { maximum: 50, message: "Last name cannot exceed 50 characters." }

  validates :email, presence: { message: "Email is required." },
                    uniqueness: { case_sensitive: false, message: "This email is already registered." },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "Enter a valid email address." },
                    length: { maximum: 255, message: "Email cannot exceed 255 characters." }

  validates :password, presence: { message: "Password is required." },
                      length: { minimum: 8, message: "Password must be at least 8 characters long." },
                      if: -> { new_record? || !password.nil? }

  validate :password_complexity, if: -> { password.present? && (new_record? || !password.nil?) }
  validate :password_confirmation_match, if: -> { password.present? && password_confirmation.present? }

  validates :role, inclusion: { in: %w[client coach admin], message: "Invalid role selected." }

  validates :gender, inclusion: { in: %w[male female other prefer_not_to_say], message: "Please select a valid gender option." },
                    allow_blank: true

  # Phone validation - required for new signups
  validates :mobile_number, presence: { message: "Phone number is required." }, if: :phone_required?
  validates :country_code, presence: { message: "Country code is required." }, if: :phone_required?
  validates :phone_e164, presence: { message: "Phone number must be in valid format." },
                        uniqueness: { message: "This phone number is already registered." },
                        if: -> { mobile_number.present? }
  validates :phone_country_iso2, presence: true, if: -> { mobile_number.present? }
  validate :phone_number_valid, if: -> { mobile_number.present? }

  before_validation :format_phone_e164, if: -> { mobile_number.present? && country_code.present? }

  before_save :downcase_email
  after_update :handle_coach_change, if: :saved_change_to_coach_id?

  # Scopes
  scope :coaches, -> { where(role: "coach") }
  scope :clients, -> { where(role: "client") }
  scope :active, -> { where(deactivated: false) }
  scope :inactive, -> { where(deactivated: true) }

  enum :rest_level, {
    rest_resident: 0,
    sleep_scholar: 1,
    circadian_champion: 2,
    chief_rest_officer: 3,
    recovery_luminary: 4
  }, prefix: true

  # Returns the coach's designation or a default value
  def designation
    self[:designation].presence || "Sleep Specialist Coach"
  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    else
      email
    end
  end

  def full_phone
    phone_e164.presence || [ country_code, mobile_number ].compact.join(" ")
  end

  def today_reflection
    daily_reflections.find_by(reflection_date: Date.today)
  end

  def gamify?
    role == "client"
  end

  def level_name
    rest_level.humanize
  end

  # Returns initials from first and last name, or email if missing
  def initials
    if first_name.present? && last_name.present?
      "#{first_name.first.upcase}#{last_name.first.upcase}"
    elsif first_name.present?
      first_name.first.upcase
    elsif last_name.present?
      last_name.first.upcase
    else
      email[0, 2].upcase
    end
  end

  def unread_messages_count(viewer)
    return 0 if viewer.nil? || self == viewer

    Message.joins(conversation: :users)
      .where(users: { id: [ id, viewer.id ] })
      .where.not(user_id: self.id) # exclude viewer's own messages
      .where(read_at: nil).uniq
      .count
  end

  def mark_messages_as_read(viewer)
    return if self == viewer

    Message.joins(conversation: :users)
      .where(users: { id: [ id, viewer.id ] })
      .where.not(user_id: self.id)
      .where(read_at: nil)
      .update_all(read_at: Time.current)
  end

  def client?
    role == "client"
  end

  def coach?
    role == "coach"
  end

  def admin?
    role == "admin"
  end

  def self.user_role(user_id)
    find_by(id: user_id)&.role
  end

  # Password Reset OTP Methods
  def generate_reset_password_otp
    otp = SecureRandom.random_number(100000..999999).to_s
    self.reset_password_otp_digest = BCrypt::Password.create(otp)
    self.reset_password_sent_at = Time.current
    self.reset_password_attempts = 0
    save!
    otp
  end

  def reset_password_otp_valid?(otp_input)
    return false if reset_password_otp_digest.blank? || reset_password_sent_at.blank?
    return false if reset_password_sent_at < 10.minutes.ago # OTP expired
    return false if reset_password_attempts >= 5 # Too many attempts

    BCrypt::Password.new(reset_password_otp_digest) == otp_input
  end

  def increment_reset_password_attempts!
    increment!(:reset_password_attempts)
  end

  def clear_reset_password_otp!
    update!(
      reset_password_otp_digest: nil,
      reset_password_sent_at: nil,
      reset_password_attempts: 0
    )
  end

  def reset_password_otp_expired?
    return true if reset_password_sent_at.blank?
    reset_password_sent_at < 10.minutes.ago
  end

  def reset_password_attempts_exceeded?
    reset_password_attempts >= 5
  end

  # Round-robin coach assignment
  def self.assign_coach_to_client(client)
    return unless client.client? && client.coach.nil?

    # Get all coaches with their client counts, sorted by count ascending, then by ID
    coaches_with_counts = User.coaches.map do |coach|
      { coach: coach, client_count: coach.clients.count }
    end.sort_by { |c| [ c[:client_count], c[:coach].id ] }

    # Assign to the coach with the fewest clients
    if coaches_with_counts.any?
      coach = coaches_with_counts.first[:coach]
      client.update!(coach: coach)
      Conversation.new_conversation(sender_id: coach.id, recipient_id: client.id)
      coach
    else
      nil
    end
  end

  def online?
    last_seen_at && last_seen_at > 5.minutes.ago
  end

  def generate_email_verification_token!
    self.email_verification_token = SecureRandom.hex(16)
    save(validate: false)
  end

  private

  def handle_coach_change
    return unless client? && coach_id_previously_changed?

    old_coach_id = coach_id_previous_change[0]
    new_coach_id = coach_id_previous_change[1]
    if new_coach_id
      Conversation.new_conversation(sender_id: new_coach_id, recipient_id: id)
    end
  end

  def downcase_email
    self.email = email.downcase
  end

  def phone_required?
    # Require phone for new signups (clients and coaches)
    new_record? && %w[client coach].include?(role)
  end

  def password_complexity
    return unless password.present?

    errors.add(:password, "Password must include at least one uppercase letter.") unless password.match(/[A-Z]/)
    errors.add(:password, "Password must include at least one lowercase letter.") unless password.match(/[a-z]/)
    errors.add(:password, "Password must include at least one number.") unless password.match(/\d/)
    errors.add(:password, "Password must include at least one special character (@$!%*?&).") unless password.match(/[@$!%*?&]/)
  end

  def password_confirmation_match
    return unless password_confirmation.present?

    errors.add(:password_confirmation, "Passwords do not match.") unless password == password_confirmation
  end

  def format_phone_e164
    return if mobile_number.blank? || country_code.blank?

    # Extract dial code and ISO code from combined format
    if country_code.include?("|")
      dial_code, iso2 = country_code.split("|")
    else
      dial_code = country_code
      iso2 = nil
    end

    # Remove country code prefix from mobile_number if present
    clean_number = mobile_number.gsub(/^\+?#{Regexp.escape(dial_code.sub('+', ''))}/, "")
    full_number = "#{dial_code}#{clean_number}"

    parsed = Phonelib.parse(full_number)
    if parsed.valid?
      self.phone_e164 = parsed.e164
      self.phone_country_iso2 = iso2 || parsed.country
    end
  end

  def phone_number_valid
    return if mobile_number.blank? || country_code.blank?

    # Extract dial code and ISO code from combined format
    if country_code.include?("|")
      dial_code, iso2 = country_code.split("|")
    else
      dial_code = country_code
      iso2 = nil
    end

    # Remove country code prefix from mobile_number if present
    clean_number = mobile_number.gsub(/^\+?#{Regexp.escape(dial_code.sub('+', ''))}/, "")
    full_number = "#{dial_code}#{clean_number}"

    parsed = Phonelib.parse(full_number)
    unless parsed.valid?
      country_name = iso2 ? get_country_name_by_iso(iso2) : "the selected country"
      errors.add(:mobile_number, "Enter a valid phone number for #{country_name}.")
    end
  end

  def get_country_name_by_iso(iso2)
    country_map = {
      "US" => "United States",
      "GB" => "United Kingdom",
      "CA" => "Canada",
      "AU" => "Australia",
      "DE" => "Germany",
      "FR" => "France",
      "IN" => "India",
      "CN" => "China",
      "JP" => "Japan"
      # Add more as needed
    }
    country_map[iso2] || "the selected country"
  end
end
