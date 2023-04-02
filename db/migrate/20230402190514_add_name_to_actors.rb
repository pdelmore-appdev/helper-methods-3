class AddNameToActors < ActiveRecord::Migration[6.1]
  def change
    add_column :actors, :name, :string
  end
end
