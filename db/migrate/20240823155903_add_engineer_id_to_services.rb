class AddEngineerIdToServices < ActiveRecord::Migration[7.1]
  def change
    add_reference :services, :engineer, null: true, foreign_key: true
  end
end
