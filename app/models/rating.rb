class Rating < ActiveRecord::Base
  belongs_to :post, required: true

  validates :value, presence: true
  validates :value, allow_blank: true, inclusion: { in: 1..5 }
end
