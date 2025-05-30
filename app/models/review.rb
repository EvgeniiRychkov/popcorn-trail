class Review < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :rating, presence: true, inclusion: { in: 1..10 }

  after_create :increment_movie_rating!
  after_update :update_movie_rating!

  def increment_movie_rating!
    movie.increment!(:ratings_count)
    movie.increment!(:ratings_sum, rating)
    movie.update_column(:average_rating, (movie.ratings_sum.to_f / movie.ratings_count).round(2))
  end

  def update_movie_rating!
    if saved_change_to_rating?
      old_rating = rating_before_last_save
      diff = rating - old_rating
      movie.increment!(:ratings_sum, diff)
      movie.update_column(:average_rating, (movie.ratings_sum.to_f / movie.ratings_count).round(2))
    end
  end
end
