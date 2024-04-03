require 'sinatra'
require 'json'
require_relative 'my_user_model'

user_model = User.new  # Assuming User class exists

# Session management (replace with secure library)
use Rack::Session::Cookie, :secret => 'your_secret_key'

# Error handling middleware (optional)
# use MyErrorHandler  # Implement custom error handling

# Authentication logic (replace with actual implementation)
def logged_in?
  session[:user_id]  # Simplistic example, replace with proper authentication
end

get '/users' do
  # Authorization check (optional)
  return 401 unless logged_in?  # Example authorization check

  users = user_model.all.map { |u| u.reject { |k, _| k == 'password' } }
  users.to_json
end

post '/users' do
  user_info = JSON.parse(request.body.read, symbolize_names: true)
  # Validate user information before creating

  user_id = user_model.create(user_info)
  user_model.find(user_id).reject { |k, _| k == 'password' }.to_json
end

post '/sign_in' do
  # Implement authentication logic with email and password (bcrypt)

  # Replace with actual user lookup and authorization check
  user_info = { id: 1, firstname: "John", lastname: "Doe", age: 30, email: email }
  user_info.reject! { |k, _| k == :password }
  session[:user_id] = user_info[:id]  # Simplistic example, replace with secure session management

  user_info.to_json
end

put '/users' do
  halt 401 unless logged_in?  # Require logged-in user

  request_payload = JSON.parse(request.body.read, symbolize_names: true)
  new_password = request_payload[:password]

  # Implement authorization check for updating user (ensure logged in user can update themself)
  updated_user = user_model.update(session[:user_id], 'password', new_password)
  updated_user.reject { |k, _| k == 'password' }.to_json
end

delete '/sign_out' do
  halt 401 unless logged_in?  # Require logged-in user

  session.clear
  status 204
end

delete '/users' do
  halt 401 unless logged_in?  # Require logged-in user

  # Implement authorization check for deleting user (ensure logged in user can delete themself)
  user_model.destroy(session[:user_id])
  session.clear
  status 204
end
