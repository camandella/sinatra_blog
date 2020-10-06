require 'spec_helper'
require 'rack/test'

RSpec.describe 'MainController' do
  include Rack::Test::Methods

  def app
    MainController.new
  end

  let(:response) { JSON.parse(last_response.body) }

  describe 'POST posts' do

    context 'Unsuccessful' do

      context 'Invalid login' do

        let(:params) do
          { login: '', title: 'title', content: 'content', author_ip: '1.1.1.1' }
        end

        it 'Should be 422 status' do
          post '/posts', params
          expect(last_response.status).to eq 422
        end

        it 'Should not create new user' do
          expect { post '/posts', params }.not_to change(User, :count)
        end

        it 'Should not create new post' do
          expect { post '/posts', params }.not_to change(Post, :count)
        end

      end

      context 'Invalid post' do

        let(:params) do
          { login: 'login', title: '', content: '', author_ip: '' }
        end

        it 'Should be 422 status' do
          post '/posts', params
          expect(last_response.status).to eq 422
        end

        it 'Should create new user' do
          expect { post '/posts', params }.to change(User, :count).by(1)
        end

        it 'Should not create new post' do
          expect { post '/posts', params }.not_to change(Post, :count)
        end

      end

    end

    context 'Successful' do

      let(:login) { 'login' }
      let(:params) do
        { login: login, title: 'title', content: 'content', author_ip: '1.1.1.1' }
      end

      context 'New login' do

        it 'Should be 200 status' do
          post '/posts', params
          expect(last_response.status).to eq 200
        end

        it 'Should has `post` key in response' do
          post '/posts', params
          expect(response.key?('post')).to be true
        end

        it 'Should match params' do
          post '/posts', params
          expect(response['post'].tap { |post| post.delete('id') }.symbolize_keys).to eq(
            user_id: User.find_by(login: login).id, **params.tap { |params| params.delete(:login) }
          )
        end

        it 'Should create new user' do
          expect { post '/posts', params }.to change(User, :count).by(1)
        end

        it 'Should create new post' do
          expect { post '/posts', params }.to change(Post, :count).by(1)
        end

      end

      context 'Existing login' do

        let!(:user) { User.create(login: login) }

        it 'Should be 200 status' do
          post '/posts', params
          expect(last_response.status).to eq 200
        end

        it 'Should has `post` key in response' do
          post '/posts', params
          expect(response.key?('post')).to be true
        end

        it 'Should match params' do
          post '/posts', params
          expect(response['post'].tap { |post| post.delete('id') }.symbolize_keys).to eq(
            user_id: user.id, **params.tap { |params| params.delete(:login) }
          )
        end

        it 'Should not create new user' do
          expect { post '/posts', params }.not_to change(User, :count)
        end

        it 'Should create new post' do
          expect { post '/posts', params }.to change(Post, :count).by(1)
        end

      end

    end

  end

  describe 'POST ratings' do

    let(:user1) { User.create(login: 'login1') }
    let(:post1) { Post.create(user: user1, title: 'title1', content: 'content1', author_ip: '1.1.1.1') }
    let!(:rate1) { Rating.create(post: post1, value: 3) }

    context 'Successful' do

      let(:params) do
        { post_id: post1.id, value: 5 }
      end

      it 'Should be 200 status' do
        post '/ratings', params
        expect(last_response.status).to eq 200
      end

      it 'Should has `average_rating` key in response' do
        post '/ratings', params
        expect(response.key?('average_rating')).to be true
      end

      it 'Should has right `average_rating` value' do
        post '/ratings', params
        expect(response['average_rating'].to_f).to eq (rate1.value + params[:value]) / 2.0
      end

      it 'Should create new rating' do
        expect { post '/ratings', params }.to change(Rating, :count).by(1)
      end

    end

    context 'Unsuccessful' do

      context 'Missing post_id' do

        let(:params) do
          { post_id: (Post.maximum(:id) + 1), value: 5 }
        end

        it 'Should be 422 status' do
          post '/ratings', params
          expect(last_response.status).to eq 422
        end

        it 'Should not create new rating' do
          expect { post '/ratings', params }.not_to change(Rating, :count)
        end

      end

      context 'Invalid value' do

        let(:params) do
          { post_id: post1.id, value: 6 }
        end

        it 'Should be 422 status' do
          post '/ratings', params
          expect(last_response.status).to eq 422
        end

        it 'Should not create new rating' do
          expect { post '/ratings', params }.not_to change(Rating, :count)
        end

      end

    end

  end

  describe 'GET top_posts' do

    let(:user1) { User.create(login: 'login1') }
    let(:post1) { Post.create(user: user1, title: 'title1', content: 'content1', author_ip: '1.1.1.1') }
    let(:post2) { Post.create(user: user1, title: 'title2', content: 'content2', author_ip: '1.1.1.1') }
    let!(:rate1) { Rating.create(post: post1, value: 3) }
    let!(:rate2) { Rating.create(post: post2, value: 4) }
    let!(:rate3) { Rating.create(post: post2, value: 5) }

    context 'Successful' do

      before(:each) do
        get '/top_posts', n: 2
      end

      it 'Should be 200 status' do
        expect(last_response.status).to eq 200
      end

      it 'Should has `top_posts` key in response' do
        expect(response.key?('top_posts')).to be true
      end

      it 'Should has right count of `top_posts` elements' do
        expect(response['top_posts'].count).to eq 2
      end

      it 'Should has right `post_id` value in first `top_posts` element' do
        expect(response.dig('top_posts', 0, 'post_id')).to eq post2.id
      end

      it 'Should has right `average_rating` value in first `top_posts` element' do
        expect(response.dig('top_posts', 0, 'average_rating').to_f).to eq (rate2.value + rate3.value) / 2.0
      end

      it 'Should has right `post_id` value in second `top_posts` element' do
        expect(response.dig('top_posts', 1, 'post_id')).to eq post1.id
      end

      it 'Should has right `average_rating` value in second `top_posts` element' do
        expect(response.dig('top_posts', 1, 'average_rating').to_f).to eq rate1.value.to_f
      end

    end

  end

  describe 'GET multiple_logins_by_ip' do

    let(:user1) { User.create(login: 'login1') }
    let(:user2) { User.create(login: 'login2') }
    let!(:post1) { Post.create(user: user1, title: 'title1', content: 'content1', author_ip: '1.1.1.1') }
    let!(:post2) { Post.create(user: user2, title: 'title2', content: 'content2', author_ip: '1.1.1.1') }
    let!(:post3) { Post.create(user: user2, title: 'title3', content: 'content3', author_ip: '2.2.2.2') }

    context 'Successful' do

      before(:each) do
        get '/multiple_logins_by_ip'
      end

      it 'Should be 200 status' do
        expect(last_response.status).to eq 200
      end

      it 'Should has `multiple_logins_by_ip` key in response' do
        expect(response.key?('multiple_logins_by_ip')).to be true
      end

      it 'Should has right count of `multiple_logins_by_ip` elements' do
        expect(response['multiple_logins_by_ip'].count).to eq 1
      end

      it 'Should has right `author_ip` value in second `multiple_logins_by_ip` element' do
        expect(response.dig('multiple_logins_by_ip', 0, 'author_ip')).to eq post1.author_ip
      end

      it 'Should has right `logins` value in second `multiple_logins_by_ip` element' do
        expect(response.dig('multiple_logins_by_ip', 0, 'logins').sort).to eq [user1.login, user2.login].sort
      end

    end

  end

end
