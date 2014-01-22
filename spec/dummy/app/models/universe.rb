class Universe < ActiveRecord::Base
  has_many :users

  validates :light_years, :entropy, :name, presence: true
end
