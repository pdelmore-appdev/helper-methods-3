class CreateActors < ActiveRecord::Migration[6.1]
  def change
    create_table :actors do |t|
      t.date :dob
      t.text :bio

      t.timestamps
    end
  end
end
