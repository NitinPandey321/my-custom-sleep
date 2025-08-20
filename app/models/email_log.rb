class EmailLog < ApplicationRecord
  belongs_to :user

  validates :email_type, presence: true
  validates :subject, presence: true
  validates :status, presence: true, inclusion: { in: %w[sent failed] }

  scope :sent, -> { where(status: 'sent') }
  scope :failed, -> { where(status: 'failed') }
  scope :welcome_emails, -> { where(email_type: 'welcome') }
end
