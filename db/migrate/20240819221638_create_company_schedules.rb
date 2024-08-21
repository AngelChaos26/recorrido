class CreateCompanySchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :company_schedules do |t|
      t.integer :week_number
      t.time :start_time
      t.time :end_time
      t.references :company, null: false, foreign_key: true
      t.timestamps
    end
  end
end
