require 'sinatra'
require 'json'
require_relative 'my_user_model'

user = User.new

get '/users' do
 
  users = user.all.map { |u| u.reject { |k, _| k == 'password' } }
  users.to_json
end

post '/users' do
  user_info = JSON.parse(request.body.read, symbolize_names: true)

  user_id = user.create(user_info)
  user.find(user_id).reject { |k, _| k == 'password' }.to_json
end

post '/sign_in' do
  request_payload = JSON.parse(request.body.read, symbolize_names: true)
  email = request_payload[:email]
  password = request_payload[:password]


  user_info = { id: 1, firstname: "John", lastname: "Doe", age: 30, email: email }
  user_info.reject! { |k, _| k == :password }
  session[:user_id] = user_info[:id]

  user_info.to_json
end

put '/users' do
  user_id = session[:user_id]
  return 401 unless user_id

  request_payload = JSON.parse(request.body.read, symbolize_names: true)
  new_password = request_payload[:password]

  updated_user = user.update(user_id, 'password', new_password)
  updated_user.reject { |k, _| k == 'password' }.to_json
end

delete '/sign_out' do
  session.clear
  status 204
end

delete '/users' do
  user_id = session[:user_id]
  return 401 unless user_id


  user.destroy(user_id)
  session.clear
  status 204
end
