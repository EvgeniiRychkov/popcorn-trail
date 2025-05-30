class AddRatingFieldsToMovies < ActiveRecord::Migration[8.0]
  def up
    add_column :movies, :average_rating, :float, default: 0.0, null: false
    add_column :movies, :ratings_count, :integer, default: 0, null: false
    add_column :movies, :ratings_sum, :integer, default: 0, null: false

    total = Movie.count
    processed = 0
    puts "Processing #{total} movies..."
    Movie.reset_column_information

    Movie.find_each do |movie|
      ratings = Review.where(movie_id: movie.id).pluck(:rating)
      count = ratings.size
      sum = ratings.sum
      avg = count > 0 ? sum.to_f / count : 0.0

      movie.update_columns(
        ratings_count: count,
        ratings_sum: sum,
        average_rating: avg
      )

      processed += 1
      puts "Processed: #{processed}/#{total}"
    end
  end

  def down
    remove_column :movies, :average_rating
    remove_column :movies, :ratings_count
    remove_column :movies, :ratings_sum
  end
end
