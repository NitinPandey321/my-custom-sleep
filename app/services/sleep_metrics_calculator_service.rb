class SleepMetricsCalculatorService
  def initialize(user)
    @user = user
  end

  def calculate!
    sleep_records = @user.sleep_records.order(:date)
    return if sleep_records.empty?

    # baseline → first 14 days
    baseline_records = sleep_records.limit(14)
    baseline_score   = baseline_records.average(:score).to_f.round(2)

    # current → all available data
    current_score = sleep_records.average(:score).to_f.round(2)

    # % improvement
    improvement_pct  = if baseline_score.positive?
                         (((current_score - baseline_score) / baseline_score) * 100).round(2)
    else
                         0.0
    end

    metric = SleepMetric.find_or_initialize_by(user: @user)

    metric.update!(
      baseline_score: baseline_score,
      baseline_start: baseline_records.first.date,
      baseline_end: baseline_records.last.date,
      current_avg_score: current_score,
      current_start: sleep_records.first.date,
      current_end: sleep_records.last.date,
      improvement: improvement_pct,
      calculated_at: Time.current
    )
  end
end
