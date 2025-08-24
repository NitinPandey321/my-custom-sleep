module AdminHelper
  def active_admin_link(link_path)
    "active" if request.path.start_with?(link_path)
  end
end
