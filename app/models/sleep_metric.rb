class SleepMetric < ApplicationRecord
  belongs_to :user

  def baseline_duration
    human_duration(baseline_start, baseline_end)
  end

  def current_duration
    human_duration(current_start, current_end)
  end

  def improvement_display
    "#{improvement.positive? ? '+' : ''}#{improvement}%"
  end

  private

  def human_duration(start_date, end_date)
    days = (end_date - start_date).to_i

    case days
    when 0..30
      "#{days} days"
    when 31..364
      months = (days / 30.0).round(1)
      "#{months} months"
    else
      years = (days / 365.0).round(1)
      "#{years} years"
    end
  end
end
