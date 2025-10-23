# lib/time_zone_normalizer.rb
module TimeZoneNormalizer
  TIMEZONE_MAP = {
    # Common legacy aliases
    "Asia/Calcutta" => "Asia/Kolkata",
    "US/Eastern" => "America/New_York",
    "US/Central" => "America/Chicago",
    "US/Mountain" => "America/Denver",
    "US/Pacific" => "America/Los_Angeles",
    "Etc/UTC" => "UTC",
    "GMT" => "UTC",
    "Coordinated Universal Time" => "UTC"
  }.freeze

  def self.normalize(name)
    return "UTC" if name.blank?

    # Direct match or alias
    mapped = TIMEZONE_MAP[name] || name

    # If invalid, fallback to UTC
    ActiveSupport::TimeZone[mapped] ? mapped : "UTC"
  rescue
    "UTC"
  end
end
