class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.integer :monitoring_shift
      t.references :company, null: false, foreign_key: true
      t.timestamps
    end
  end
end
