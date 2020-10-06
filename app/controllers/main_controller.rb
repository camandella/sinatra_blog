class MainController < Sinatra::Base
  before do
    content_type :json
  end

  post '/posts' do
    service = CreatePostService.new
    if service.perform(params[:login], params[:title], params[:content], params[:author_ip])
      { post: service.post }.to_json
    else
      status 422
      { errors: service.errors }.to_json
    end
  end

  post '/ratings' do
    service = CreateRatingService.new
    if service.perform(params[:post_id], params[:value])
      { average_rating: service.average_rating }.to_json
    else
      status 422
      { errors: service.errors }.to_json
    end
  end

  get '/top_posts' do
    top_posts = Post.top(params[:n].to_i).as_json(only: %i[post_id title content average_rating])
    { top_posts: top_posts }.to_json
  end

  get '/multiple_logins_by_ip' do
    multiple_logins_by_ip = User.multiple_logins_by_ip.as_json(only: %i[author_ip logins])
    { multiple_logins_by_ip: multiple_logins_by_ip }.to_json
  end
end
