class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review_and_movie, only: [ :edit, :update ]
  before_action :authorize_user!, only: [ :edit, :update ]
  def new
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.new
  end

  def create
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.new(review_params)
    @review.user = current_user

    if @review.save
      redirect_to movie_path(@movie), notice: "Review created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to movie_path(@movie), notice: "Review updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:text, :rating)
  end

  def set_review_and_movie
    @review = Review.find(params[:id])
    @movie = @review.movie
  end

  def authorize_user!
    unless @review.user == current_user
      redirect_to movie_path(@movie), alert: "You are not authorized to edit this review."
    end
  end
end
