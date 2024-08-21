class CreateServiceEngineers < ActiveRecord::Migration[7.1]
  def change
    create_table :service_engineers do |t|
      t.references :service, null: false, foreign_key: true
      t.references :engineer, null: false, foreign_key: true
      t.timestamps
    end
  end
end
