class User < ApplicationRecord
  has_many :sleep_records
  has_many :follows
  # setup following so can direct access to following attributes
  has_many :following, through: :follows, source: :followed
end
