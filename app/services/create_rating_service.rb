class CreateRatingService
  attr_reader :errors, :average_rating

  def initialize
    reset_instance_variables
  end

  def perform(post_id, value)
    unless post = Post.find_by_id(post_id)
      @errors[:post] = "no post with id=#{post_id}"
      return false
    end

    post.with_lock do
      rating = post.ratings.new(value: value)
      unless rating.valid?
        @errors[:rating] = rating.errors.messages
        return false
      end

      rating.save
      @average_rating = post.ratings.average(:value)
    end
    true
  end

  private

  def reset_instance_variables
    @errors = {}
    @average_rating = nil
  end
end
