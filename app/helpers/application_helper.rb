module ApplicationHelper
  def format_response_time(seconds)
    return "—" if seconds.nil? || seconds.zero?

    if seconds < 60
      "#{seconds}s"
    elsif seconds < 3600
      "#{seconds / 60}m #{seconds % 60}s"
    else
      "#{seconds / 3600}h #{(seconds % 3600) / 60}m"
    end
  end
end
