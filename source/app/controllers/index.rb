get '/' do
########## implement with bcrypt
  # if session[:user_id]
  #   erb :project_list
  # else
  #   erb :login
  erb :login
end

post '/login' do
  if User.find_by(name: params[:name])
    redirect '/projects'
  else
    "incorrect name"
  end
end

get '/projects' do
  @all_projects = Project.all

  erb :projects
end

get '/projects/new' do
  erb :projects_new
end

post '/projects' do
  new_project = Project.create(title: params[:project_title], description: params[:project_description])
  if new_project.save
    redirect '/projects'
  else
    "There was an error creating your project"
  end
end


########################Implement signup
# post 'signup' do
# end




