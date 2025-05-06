require "csv"

namespace :import do
  desc "Import reviews from ratings.csv"
  task reviews: :environment do
    filepath = Rails.root.join("db", "ratings.csv")

    puts "Import reviews..."

    CSV.foreach(filepath, headers: true) do |row|
      user_id = row["userId"].to_i
      movie_id = row["movieId"].to_i
      rating = row["rating"].to_f * 2

      user = User.find_by(id: user_id)
      unless user
        user = User.create!(
          id: user_id,
          name: "User_#{user_id}",
          email: "user_#{user_id}@example.com",
          password: "fdkasjfjdoaij3290ufaFafds"
        )
      end

      movie = Movie.find_by(id: movie_id)
      unless movie
        puts "Skipped review with movie id #{movie_id}"
        next
      end

      Review.create!(
        text: "",
        rating: rating,
        user_id: user.id,
        movie_id: movie.id
      )
    end

    puts "Import completed."
  end
end
