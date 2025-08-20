<div class="navbar">
  <div class="navbar-left">
    <%= link_to root_path, class: "logo-link" do %>
      <div class="logo">
        <%= image_tag "my-custom-logo.jpeg", alt: "My Custom Sleep Journey", class: "brand-logo navbar-logo" %>
      </div>
    <% end %>
  </div>

  <div class="navbar-right">
    <nav class="nav-menu">
      <div class="user-info">
        <span class="welcome-text">
          Welcome, <%= current_user&.email.to_s.split('@').first.capitalize %>
        </span>

        <div class="profile-container">
          <% if current_user&.profile_picture&.attached? %>
            <img id="profile-pic"
                 src="<%= rails_blob_url(current_user.profile_picture, disposition: 'inline') %>"
                 alt="Profile picture"
                 class="profile-picture" />
          <% else %>
            <%= image_tag "default-avatar.svg",
                          alt: "Default profile picture",
                          id: "profile-pic",
                          class: "profile-picture" %>
          <% end %>

          <label for="profile-upload-input" class="edit-icon" title="Change profile picture">✎</label>
          <input id="profile-upload-input"
                 type="file"
                 accept="image/jpeg,image/jpg,image/png,image/webp"
                 hidden />
        </div>

        <%= button_to "Logout", logout_path,
            method: :delete,
            class: "logout-btn",
            data: { turbo: true, confirm: "Are you sure you want to logout?" } %>
      </div>
    </nav>
  </div>
</div>
