get '/' do
########## implement with bcrypt
  # if session[:user_id]
  #   erb :project_list
  # else
  #   erb :login
  erb :login
end

get '/project_list' do
  erb :project_list
end

post '/login' do
  if User.find_by(name: params[:name])
    redirect '/project_list'
  else
    "incorrect name"
  end
end

########################Implement signup
# post 'signup' do
# end




