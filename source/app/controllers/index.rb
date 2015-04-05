require 'byebug'
require 'rubygems'
require 'json'

get '/' do
######################## implement with bcrypt
  # if session[:user_id]
  #   erb :project_list
  # else
  #   erb :login
  # erb :login
  erb :login
end

######################## Implement signup
# post 'signup' do
# end


get '/login-via-github' do
  session['github_oauth_state'] = SecureRandom.uuid
  scopes_desired = "user:email,public_repo,gist,repo,read:repo_hook"

  url = URI.parse('https://github.com/login/oauth/authorize')
  url.query = {
    client_id: ENV['GITHUB_CLIENT_ID'],
    # redirect_uri: to('/github/oauth/callback'),
    redirect_uri: ('http://127.0.0.1:9393/github/oauth/callback'),
    scope: scopes_desired,
    state: session['github_oauth_state'],
  }.to_param
  redirect url.to_s
end

get '/github/oauth/callback' do
  state = params["state"]
  code = params["code"]
  if (session['github_oauth_state'] != state) || (state.empty?)
    "Bad request"
  end
  # {"code"=>"f44844e0c8173c56f442", "state"=>"d8513d55-fd64-4592-acdc-5d37502ffce0"}
  # params.inspect

  response = HTTParty.post('https://github.com/login/oauth/access_token', {
    :headers => {
      "User-Agent" => "BootBase",
      "Accept" => "application/json"
    },
    :body => {
      client_id: ENV['GITHUB_CLIENT_ID'],
      client_secret: ENV['GITHUB_CLIENT_SECRET'],
      code: code,
      redirect_uri: to('/projects'),
    },
  })
                        #See Sherif's alternative below
  user_token = response['access_token']

  user_info = HTTParty.get('https://api.github.com/user', {
    :headers => {
      "User-Agent" => "BootBase",
      "Authorization" => "token #{user_token}"
    }
  })
  JSON.parse(user_info.body)['id']
  p "*" * 80
end


post '/login' do
  if User.find_by(name: params[:name])
    redirect '/projects'
  else
    "incorrect name"
  end
end

get '/projects' do
  params.inspect
  # @all_projects = Project.all

  erb :projects
end

get '/projects' do
  new_project = Project.create(title: params[:project_title], description: params[:project_description])
  if new_project.save
    redirect '/projects'
  else
    "There was an error creating your project"
  end
end

get '/projects/new' do
  erb :projects_new
end

get '/projects/:id' do
  @this_project = Project.find(params[:id])
  p @this_project

  erb :project_id
end

  # response = HTTParty.post(url)
  # # "access_token=cb86bf5604102c8497c0d7843c6c71e0aa14a877&scope=&token_type=bearer"

  # data = Hash[response.body.split('&').map{|pair| pair.split('=')}]
  # # {"access_token"=>"cb86bf5604102c8497c0d7843c6c71e0aa14a877", "scope"=>nil, "token_type"=>"bearer"}

  # p data['access_token']






