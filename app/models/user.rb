class User < ApplicationRecord
  has_secure_password

  enum :status, { on_track: 0, needs_attention: 1, falling_behind: 2 }, prefix: true

  has_many :email_logs, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :daily_reflections, dependent: :destroy
  has_many :messages, dependent: :destroy

  # ActiveStorage association for profile picture
  has_one_attached :profile_picture

  # Coach-Client relationships
  belongs_to :coach, class_name: "User", optional: true
  has_many :clients, class_name: "User", foreign_key: "coach_id"

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :role, inclusion: { in: %w[client coach admin] }

  before_save :downcase_email

  # Scopes
  scope :coaches, -> { where(role: "coach", deactivated: false) }
  scope :clients, -> { where(role: "client", deactivated: false) }
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
    [ country_code, mobile_number ].compact.join(" ")
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
    return 0 if self == viewer

    Message.joins(:conversation)
      .where(conversations: { sender_id: [ id, viewer.id ], recipient_id: [ id, viewer.id ] })
      .where.not(user_id: self.id) # exclude viewer's own messages
      .where(read_at: nil).uniq
      .count
  end

  def mark_messages_as_read(viewer)
    return if self == viewer

    Message.joins(:conversation)
      .where(conversations: { sender_id: [ id, viewer.id ], recipient_id: [ id, viewer.id ] })
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
      Conversation.find_or_create_by!(
        sender_id: coach.id,
        recipient_id: client.id
      )
      coach
    else
      nil
    end
  end

  def online?
    last_seen_at && last_seen_at > 5.minutes.ago
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
