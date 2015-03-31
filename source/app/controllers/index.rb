get '/' do
########## implement with bcrypt
  # if session[:user_id]
  #   erb :project_list
  # else
  #   erb :login
  erb :login
end

post '/login' do
  if User.find(name: params[:name])
    erb :project_list
  else
    "incorrect name"
  end
end

########################Implement signup
# post 'signup' do
# end




