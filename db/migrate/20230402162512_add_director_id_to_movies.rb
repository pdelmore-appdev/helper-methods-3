class AddDirectorIdToMovies < ActiveRecord::Migration[6.1]
  def change
    add_column :movies, :director_id, :integer
  end
end
