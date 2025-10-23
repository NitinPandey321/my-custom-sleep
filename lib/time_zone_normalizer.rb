# lib/time_zone_normalizer.rb
module TimeZoneNormalizer
  TIMEZONE_MAP = {
    # IANA legacy / aliases
    "Asia/Calcutta" => "Asia/Kolkata",
    "US/Eastern" => "America/New_York",
    "US/Central" => "America/Chicago",
    "US/Mountain" => "America/Denver",
    "US/Pacific" => "America/Los_Angeles",

    # Windows names
    "Pacific Standard Time" => "America/Los_Angeles",
    "Eastern Standard Time" => "America/New_York",
    "Central Standard Time" => "America/Chicago",
    "Mountain Standard Time" => "America/Denver",
    "India Standard Time" => "Asia/Kolkata",
    "GMT Standard Time" => "Europe/London",

    # Other UTC aliases
    "Etc/UTC" => "UTC",
    "GMT" => "UTC",
    "Coordinated Universal Time" => "UTC"
  }.freeze

  FALLBACK_TIMEZONE = "America/Los_Angeles"

  def self.normalize(name)
    return "UTC" if name.blank?

    mapped = TIMEZONE_MAP[name] || name
    ActiveSupport::TimeZone[mapped] ? mapped : FALLBACK_TIMEZONE
  rescue
    FALLBACK_TIMEZONE
  end
end
