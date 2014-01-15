class User < ActiveRecord::Base
  belongs_to :universe

  accepts_nested_attributes_for :universe
end
