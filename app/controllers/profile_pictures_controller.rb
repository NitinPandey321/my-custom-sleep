class ProfilePicturesController < ApplicationController
  before_action :require_login
  
  def show
    if current_user.profile_picture.attached?
      redirect_to rails_blob_url(current_user.profile_picture, disposition: "inline")
    else
      # Return a default avatar image path or 404
      head :not_found
    end
  end

  def create
    if params[:profile_picture].present?
      if current_user.profile_picture.attach(params[:profile_picture])
        render json: { 
          success: true, 
          message: 'Profile picture updated successfully!',
          image_url: rails_blob_url(current_user.profile_picture, disposition: "inline")
        }
      else
        render json: { 
          success: false, 
          message: 'Failed to upload profile picture. Please try again.'
        }, status: :unprocessable_entity
      end
    else
      render json: { 
        success: false, 
        message: 'No image file provided.'
      }, status: :bad_request
    end
  end

  def destroy
    if current_user.profile_picture.attached?
      current_user.profile_picture.purge
      render json: { 
        success: true, 
        message: 'Profile picture removed successfully!'
      }
    else
      render json: { 
        success: false, 
        message: 'No profile picture to remove.'
      }, status: :not_found
    end
  end

  private

  def profile_picture_params
    params.permit(:profile_picture)
  end

  def require_login
    unless user_signed_in?
      render json: { success: false, message: 'Please log in to continue.' }, status: :unauthorized
    end
  end
end
