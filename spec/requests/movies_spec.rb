require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  describe 'GET /movies' do
    context 'movies exist' do
      before do
        genre1 = Genre.create!(name: 'Action')
        genre2 = Genre.create!(name: 'Drama')

        movie1 = Movie.create!(title: 'Movie 1', year: 2024)
        movie2 = Movie.create!(title: 'Movie 2', year: 2025)

        movie1.genres << genre1
        movie2.genres << [ genre1, genre2 ]

        user = User.create!(name: 'Evgenii', email: 'evgenii@gmail.com', password: 'password')
        Review.create!(movie: movie1, rating: 4, user: user, text: 'Great movie!')
        Review.create!(movie: movie1, rating: 5, user: user, text: 'Loved it!')
      end

      it 'displays movies with their details' do
        get '/movies'

        expect(response.body).to include('Movies')
        expect(response.body).to include('Movie 1')
        expect(response.body).to include('Movie 2')
        expect(response.body).to include('2024')
        expect(response.body).to include('2025')
        expect(response.body).to include('Action')
        expect(response.body).to include('Action / Drama')
        expect(response.body).to include('4.5 (2)')
        expect(response.body).to include('N/A (0)')
      end
    end

    context 'no movies exist' do
      it 'displays only the header without any movie rows' do
        get '/movies'

        expect(response.body).to include('Movies')
        expect(response.body).not_to include('<td>')
      end
    end
  end

  describe 'GET /movies/:id' do
    context 'movie exists with reviews' do
      let(:user) { User.create!(name: 'Evgenii', email: 'evgenii@gmail.com', password: 'password') }
      let(:movie) { Movie.create!(title: 'The Matrix', year: 1999) }

      before do
        Review.create!(movie: movie, user: user, rating: 10, text: 'Amazing!')
        Review.create!(movie: movie, user: user, rating: 8, text: 'Great!')
      end

      it 'renders the movie show page with rating breakdown and reviews' do
        get "/movies/#{movie.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('← Back')
        expect(response.body).to include('The Matrix (1999)')
        expect(response.body).to include('Average Rating:')
        expect(response.body).to include('9.0 (2)')
        expect(response.body).to include('Rating Breakdown')
        expect(response.body).to include('50%')
        expect(response.body).to include('Evgenii')
        expect(response.body).to include('Amazing!')
        expect(response.body).to include('Write a Review')
      end
    end

    context 'movie exists without reviews' do
      let(:movie) { Movie.create!(title: 'Untitled', year: 2025) }

      it 'renders the movie show page with N/A average rating and no reviews' do
        get "/movies/#{movie.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Untitled (2025)')
        expect(response.body).to include('Average Rating:')
        expect(response.body).to include('N/A')
        expect(response.body).to include('Rating Breakdown')
        expect(response.body).to include('0%')
        expect(response.body).to include('Write a Review')
      end
    end

    context 'movie does not exist' do
      it 'returns 404 not found' do
        get '/movies/999999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
