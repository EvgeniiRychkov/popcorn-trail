require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  let!(:user) { User.create!(name: "User", email: "user@example.com", password: "password") }
  let!(:other_user) { User.create!(name: "Other", email: "other@example.com", password: "password") }
  let!(:movie) { Movie.create!(title: "Test Movie", year: 2024) }

  describe "GET /movies/:movie_id/reviews/new" do
    context "when signed in" do
      before do
        sign_in user
        get new_movie_review_path(movie)
      end

      it "renders the new form" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Submit Review")
      end
    end

    context "when not signed in" do
      it "redirects to the login page" do
        get new_movie_review_path(movie)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /movies/:movie_id/reviews" do
    let(:valid_params) { { review: { rating: 8, text: "Nice movie!" } } }
    let(:invalid_params) { { review: { rating: 20, text: "" } } }

    context "when signed in" do
      before { sign_in user }

      it "creates a review with valid params" do
        expect {
          post movie_reviews_path(movie), params: valid_params
        }.to change(Review, :count).by(1)

        expect(response).to redirect_to(movie_path(movie))
        follow_redirect!
        expect(response.body).to include("Review created successfully").or include("successfully")
      end

      it "does not create a review with invalid params" do
        expect {
          post movie_reviews_path(movie), params: invalid_params
        }.not_to change(Review, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("error").or include("prohibited")
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        post movie_reviews_path(movie), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /movies/:movie_id/reviews/:id/edit" do
    let!(:review) { Review.create!(movie: movie, user: user, rating: 7, text: "Cool") }

    context "when signed in as owner" do
      before do
        sign_in user
        get edit_movie_review_path(movie, review)
      end

      it "renders the edit form" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit Review")
      end
    end

    context "when signed in as another user" do
      before do
        sign_in other_user
        get edit_movie_review_path(movie, review)
      end

      it "redirects with alert" do
        expect(response).to redirect_to(movie_path(movie))
        follow_redirect!
        expect(response.body).to include("You are not authorized to edit this review.")
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        get edit_movie_review_path(movie, review)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /movies/:movie_id/reviews/:id" do
    let!(:review) { Review.create!(movie: movie, user: user, rating: 7, text: "Old Text") }

    context "when signed in as owner with valid data" do
      before do
        sign_in user
        patch movie_review_path(movie, review), params: { review: { text: "Updated", rating: 9 } }
      end

      it "updates the review" do
        expect(response).to redirect_to(movie_path(movie))
        expect(review.reload.text).to eq("Updated")
        expect(review.rating).to eq(9)
      end
    end

    context "when signed in as owner with invalid data" do
      before do
        sign_in user
        patch movie_review_path(movie, review), params: { review: { text: "", rating: 100 } }
      end

      it "renders the edit template with error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("error").or include("prohibited")
      end
    end

    context "when signed in as another user" do
      before do
        sign_in other_user
        patch movie_review_path(movie, review), params: { review: { text: "Hacked!", rating: 1 } }
      end

      it "does not allow updating the review" do
        expect(response).to redirect_to(movie_path(movie))
        expect(review.reload.text).not_to eq("Hacked!")
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        patch movie_review_path(movie, review), params: { review: { text: "Trying", rating: 5 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
