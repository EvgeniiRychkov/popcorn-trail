class MoviesController < ApplicationController
  def index
    @movies = Movie
      .includes(:genres)
      .left_joins(:reviews)
      .select("movies.*, AVG(reviews.rating) AS average_rating, COUNT(reviews.id) AS reviews_count")
      .group("movies.id")
      .order(Arel.sql("average_rating DESC NULLS LAST"))
  end

  def show
    @movie = Movie.find(params[:id])
    @rating_breakdown = @movie.reviews.group(:rating).order(rating: :desc).count
    @average_rating = @movie.reviews.average(:rating)&.round(1)

    @reviews = @movie.reviews
    .includes(:user)
    .order(created_at: :desc)
  end
end
