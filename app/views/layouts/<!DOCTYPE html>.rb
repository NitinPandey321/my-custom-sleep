<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for(:title) || "My Sleep Journey" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= yield :head %>

    <%# Enable PWA manifest if needed: %>
    <%#= tag.link rel: "manifest", href: pwa_manifest_path(format: :json) %>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>

    <!-- Profile Picture Upload Script -->
    <script src="<%= asset_path('profile_picture.js') %>" defer></script>
  </head>

  <body>
    <header class="app-header">
      <div class="container">
        <%= render 'shared/navbar' if user_signed_in? %>
      </div>
    </header>

    <main class="main-content">
      <%= render 'shared/flash_messages' if flash.any? %>
      <%= yield %>
    </main>
  </body>
</html>
