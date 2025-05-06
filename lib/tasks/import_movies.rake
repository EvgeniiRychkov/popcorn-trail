require "csv"

namespace :import do
  desc "Import movies from movies.csv"
  task movies: :environment do
    filepath = Rails.root.join("db", "movies.csv")

    puts "Import start..."

    count = 0
    CSV.foreach(filepath, headers: true) do |row|
      raw_title = row["title"]

      if raw_title =~ /\((\d{4})\)\s*$/
        year = $1.to_i
        title = raw_title.sub(/\s*\(\d{4}\)\s*$/, "").strip
      else
        year = 0
        title = raw_title
      end

      genre_names = row["genres"].split("|")

      movie = Movie.create!(id: row["movieId"], title: title, year: year)

      genre_names.each do |genre_name|
        genre = Genre.find_or_create_by!(name: genre_name)
        movie.genres << genre unless movie.genres.include?(genre)
      end

      count += 1
    end

    puts "Imported #{count} movies."
  end
end
