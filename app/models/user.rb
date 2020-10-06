class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy

  validates :login, presence: true, uniqueness: true

  scope :multiple_logins_by_ip, -> do
    joins(:posts)
    .select('author_ip, array_agg(distinct login) as logins')
    .group(:author_ip)
    .having('count(distinct login) > 1')
  end
end
