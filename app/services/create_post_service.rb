class CreatePostService
  attr_reader :errors, :post

  def initialize
    reset_instance_variables
  end

  def perform(login, title, content, author_ip)
    user = User.find_or_initialize_by(login: login)
    unless user.persisted?
      user.valid? ? user.save : @errors[:user] = user.errors.messages
    end
    post = user.posts.new(title: title, content: content, author_ip: author_ip)
    @errors[:post] = post.errors.messages unless post.valid?
    return false if @errors.any?

    @post = post.tap { |post| post.save }
    true
  end

  private

  def reset_instance_variables
    @errors = {}
    @post = nil
  end
end
