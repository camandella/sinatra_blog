require 'resolv'

class Post < ActiveRecord::Base
  belongs_to :user, required: true
  has_many :ratings, dependent: :destroy

  validates :title, :content, :author_ip, presence: true
  validates :author_ip, allow_blank: true, format: { with: Resolv::IPv4::Regex }

  scope :top, ->(n) do
    joins(:ratings)
    .select('post_id, title, content, avg(value) as average_rating')
    .group(:post_id, :title, :content)
    .order('average_rating desc')
    .limit(n)
  end

  def as_json(*)
    super.except('created_at', 'updated_at')
  end
end 
