class Review < ActiveRecord
  belongs_to :user
  belongs_to :movie
end
