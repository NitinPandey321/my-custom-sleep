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

  def country_code_options
    [
      { name: "United States", iso2: "US", dial_code: "+1", flag: "🇺🇸" },
      { name: "Canada", iso2: "CA", dial_code: "+1", flag: "��" },
      { name: "United Kingdom", iso2: "GB", dial_code: "+44", flag: "��" },
      { name: "Australia", iso2: "AU", dial_code: "+61", flag: "🇦🇺" },
      { name: "Germany", iso2: "DE", dial_code: "+49", flag: "🇩🇪" },
      { name: "France", iso2: "FR", dial_code: "+33", flag: "🇫🇷" },
      { name: "Italy", iso2: "IT", dial_code: "+39", flag: "🇮🇹" },
      { name: "Spain", iso2: "ES", dial_code: "+34", flag: "🇪🇸" },
      { name: "Netherlands", iso2: "NL", dial_code: "+31", flag: "🇳🇱" },
      { name: "Belgium", iso2: "BE", dial_code: "+32", flag: "🇧🇪" },
      { name: "Switzerland", iso2: "CH", dial_code: "+41", flag: "🇨🇭" },
      { name: "Austria", iso2: "AT", dial_code: "+43", flag: "🇦🇹" },
      { name: "Sweden", iso2: "SE", dial_code: "+46", flag: "🇸🇪" },
      { name: "Norway", iso2: "NO", dial_code: "+47", flag: "🇳🇴" },
      { name: "Denmark", iso2: "DK", dial_code: "+45", flag: "🇩🇰" },
      { name: "Finland", iso2: "FI", dial_code: "+358", flag: "🇫🇮" },
      { name: "India", iso2: "IN", dial_code: "+91", flag: "🇮🇳" },
      { name: "China", iso2: "CN", dial_code: "+86", flag: "🇨🇳" },
      { name: "Japan", iso2: "JP", dial_code: "+81", flag: "🇯🇵" },
      { name: "South Korea", iso2: "KR", dial_code: "+82", flag: "🇰🇷" },
      { name: "Singapore", iso2: "SG", dial_code: "+65", flag: "🇸🇬" },
      { name: "Malaysia", iso2: "MY", dial_code: "+60", flag: "🇲🇾" },
      { name: "Thailand", iso2: "TH", dial_code: "+66", flag: "🇹🇭" },
      { name: "Indonesia", iso2: "ID", dial_code: "+62", flag: "🇮🇩" },
      { name: "Philippines", iso2: "PH", dial_code: "+63", flag: "🇵🇭" },
      { name: "Vietnam", iso2: "VN", dial_code: "+84", flag: "🇻🇳" },
      { name: "Brazil", iso2: "BR", dial_code: "+55", flag: "🇧🇷" },
      { name: "Mexico", iso2: "MX", dial_code: "+52", flag: "🇲🇽" },
      { name: "Argentina", iso2: "AR", dial_code: "+54", flag: "🇦🇷" },
      { name: "Chile", iso2: "CL", dial_code: "+56", flag: "🇨🇱" },
      { name: "Colombia", iso2: "CO", dial_code: "+57", flag: "🇨🇴" },
      { name: "Peru", iso2: "PE", dial_code: "+51", flag: "🇵🇪" },
      { name: "South Africa", iso2: "ZA", dial_code: "+27", flag: "🇿🇦" },
      { name: "Nigeria", iso2: "NG", dial_code: "+234", flag: "🇳🇬" },
      { name: "Kenya", iso2: "KE", dial_code: "+254", flag: "🇰🇪" },
      { name: "Egypt", iso2: "EG", dial_code: "+20", flag: "🇪🇬" },
      { name: "Turkey", iso2: "TR", dial_code: "+90", flag: "🇹🇷" },
      { name: "Israel", iso2: "IL", dial_code: "+972", flag: "🇮🇱" },
      { name: "United Arab Emirates", iso2: "AE", dial_code: "+971", flag: "🇦🇪" },
      { name: "Saudi Arabia", iso2: "SA", dial_code: "+966", flag: "🇸🇦" },
      { name: "Russia", iso2: "RU", dial_code: "+7", flag: "🇷🇺" },
      { name: "Poland", iso2: "PL", dial_code: "+48", flag: "🇵🇱" },
      { name: "Czech Republic", iso2: "CZ", dial_code: "+420", flag: "🇨🇿" },
      { name: "Hungary", iso2: "HU", dial_code: "+36", flag: "🇭🇺" },
      { name: "Romania", iso2: "RO", dial_code: "+40", flag: "🇷🇴" },
      { name: "Bulgaria", iso2: "BG", dial_code: "+359", flag: "🇧🇬" },
      { name: "Greece", iso2: "GR", dial_code: "+30", flag: "🇬🇷" },
      { name: "Portugal", iso2: "PT", dial_code: "+351", flag: "🇵🇹" },
      { name: "Ireland", iso2: "IE", dial_code: "+353", flag: "🇮🇪" },
      { name: "Iceland", iso2: "IS", dial_code: "+354", flag: "🇮🇸" },
      { name: "Luxembourg", iso2: "LU", dial_code: "+352", flag: "🇱🇺" },
      { name: "New Zealand", iso2: "NZ", dial_code: "+64", flag: "🇳🇿" }
    ]
  end

  def default_country_code
    # Default to United States
    "+1"
  end

  def default_country_iso2
    "US"
  end

  def format_phone_number(phone_e164)
    return "" if phone_e164.blank?
    
    parsed = Phonelib.parse(phone_e164)
    parsed.valid? ? parsed.international : phone_e164
  end

  def format_phone_national(phone_e164)
    return "" if phone_e164.blank?
    
    parsed = Phonelib.parse(phone_e164)
    parsed.valid? ? parsed.national : phone_e164
  end
end
