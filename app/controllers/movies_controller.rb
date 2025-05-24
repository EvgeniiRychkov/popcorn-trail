class MoviesController < ApplicationController
  def index
    @movies = Movie
    .includes(:genres)
    .order(average_rating: :desc)
    .limit(100)
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
