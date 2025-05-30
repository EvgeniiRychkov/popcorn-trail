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

    @reviews = @movie.reviews
    .includes(:user)
    .where.not(user: current_user)
    .order(created_at: :desc)

    @my_review = @movie.reviews.find_by(user: current_user)
  end
end
