class AddReleasedOnToMovies < ActiveRecord::Migration[6.1]
  def change
    add_column :movies, :released_on, :date
  end
end
