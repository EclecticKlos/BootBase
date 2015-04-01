GET '/' do
######################## implement with bcrypt
  # if session[:user_id]
  #   erb :project_list
  # else
  #   erb :login
  # erb :login
  erb :git_login
end

######################## Implement signup
# post 'signup' do
# end

GET 'git_login' do
redirect 'https://github.com/login/oauth/authorize'

git_request = .ajax({
  url:        'https://github.com/login/oauth.authorize'
  type:       'POST'
  dataType:   'json'
  data: {
    client_id=    '76e09f72b75dbea43129'
    redirect_uri= 'http://127.0.0.1:9393/projects'
    scope=        user:email,user:follow,repo,repo_deployment,red:repo_hook
    state=
  }
  })

end

POST '/login' do
  if User.find_by(name: params[:name])
    redirect '/projects'
  else
    "incorrect name"
  end
end

GET '/projects' do
  @all_projects = Project.all

  erb :projects
end

GET '/projects' do
  new_project = Project.create(title: params[:project_title], description: params[:project_description])
  if new_project.save
    redirect '/projects'
  else
    "There was an error creating your project"
  end
end

GET '/projects/new' do
  erb :projects_new
end

GET '/projects/:id' do
  @this_project = Project.find(params[:id])
  p @this_project

  erb :project_id
end






