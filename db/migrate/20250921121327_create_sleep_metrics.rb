class CreateSleepMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_metrics do |t|
      t.references :user, null: false, foreign_key: true
      t.float :baseline_score
      t.float :current_avg_score
      t.float :improvement
      t.datetime :calculated_at
      t.date :baseline_start
      t.date :baseline_end
      t.date :current_start
      t.date :current_end

      t.timestamps
    end
  end
end
