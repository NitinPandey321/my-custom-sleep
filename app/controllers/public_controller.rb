class PublicController < ApplicationController
  # Google requires this page to be accessible without login
  skip_before_action :authenticate_user!, raise: false

  def account_deletion
  end

  def request_account_deletion
    email = params[:email]

    if email.blank?
      redirect_to account_deletion_path, alert: "Email is required"
      return
    end
    AccountDeletionRequest.create!(email: email)

    redirect_to account_deletion_confirmation_path
  end

  def account_deletion_confirmation
  end
end
