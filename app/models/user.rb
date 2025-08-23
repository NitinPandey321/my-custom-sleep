  # Returns the coach's designation or a default value
  def designation
    self[:designation].presence || "Sleep Specialist Coach"
  end
class User < ApplicationRecord
  # Returns the coach's designation or a default value
  def designation
    self[:designation].presence || "Sleep Specialist Coach"
  end
  has_secure_password

  enum :status, { on_track: 0, needs_attention: 1, falling_behind: 2 }, prefix: true

  has_many :email_logs, dependent: :destroy
  has_many :plans, dependent: :destroy

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
  scope :coaches, -> { where(role: "coach") }
  scope :clients, -> { where(role: "client") }

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_phone
    [ country_code, mobile_number ].compact.join(" ")
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
      .where.not(user_id: self.id) # exclude viewer’s own messages
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

  # Returns full name or email if missing
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
  def client?
    role == "client"
  end

  def coach?
    role == "coach"
  end

  def admin?
    role == "admin"
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

  private

  def downcase_email
    self.email = email.downcase
  end
end
