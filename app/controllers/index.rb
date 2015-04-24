require 'json'

get '/' do
  erb :login
end


get '/login-via-github' do
  session['github_oauth_state'] = SecureRandom.uuid
  scopes_desired = "user:email,public_repo,gist,repo,read:repo_hook"

  url = URI.parse('https://github.com/login/oauth/authorize')
  url.query = {
    client_id: ENV['GITHUB_CLIENT_ID'],
    # redirect_uri: to('/github/oauth/callback'),
    redirect_uri: ('/github/oauth/callback'),
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

  parsed_body = JSON.parse(user_info.body)
  user_github_id = parsed_body['id']
  username = parsed_body['login']
  p avatar_url_from_github = parsed_body['avatar_url']
  p inquiring_user = User.find_by(github_id: user_github_id)
  if inquiring_user
    session[:user_id] = inquiring_user.id
    session[:github_token] = user_token
    session[:github_id] = user_github_id
    session[:username] = username
    p "$" * 100
    # p inquiring_user[:user_avatar_url] = avatar_url_from_github
    p "*" * 100
    # inquiring_user.save
  else
    User.create(
      github_id:      user_github_id,
      username:       username,
      auth_token:     user_token,
      user_avatar_url:     avatar_url_from_github,
      )
    session[:github_token] = user_token
    session[:github_id] = user_github_id
    session[:username] = username
  end

  redirect '/projects'
end

post '/login' do
  if User.find_by(name: params[:name])
    redirect '/projects'
  else
    "incorrect name"
  end
end

get '/projects' do
  # params.inspect
  @tags = Tag.all
  # @total_votes = @tag.votes.map(&:value).reduce(:+-=) #some shit like that
  if request.xhr?
    @tags = Tag.fuzzy_search(params[:query]).includes(:projects => :user)
    @all_projects = @tags.map(&:projects).flatten.uniq
    p "$" * 100
    p @all_projects
    @users = @all_projects.map(&:user)
    erb :projects_bare_bones, layout: false
  else
    @tags
    @all_projects = Project.all
    erb :projects
  end
end

get '/projects/new' do
  erb :projects_new
end

#   Append to beginning of url: https://api.github.com/repos/EclecticKlos/BootBase
#   #From copy button:          BootBase/source/app/controllers/index.rb
#   #Needed for API:            BootBase/contents/source/app/controllers/index.rb
# "https://api.github.com/repos/EclecticKlos/BootBase/contents/source/app/controllers/index.rb"

post '/projects' do
  project_code_url_array = params[:code_url].split('/')
  project_owner = User.find_by(github_id: session[:github_id])
  formatted_code_url = "https://api.github.com/repos/" + project_owner.username + "/" + project_code_url_array.shift + "/contents/" + project_code_url_array.join("/")
  repo_content = HTTParty.get( formatted_code_url, {
    :headers => {
      "User-Agent" => "BootBase",
      "Authorization" => "token #{session[:github_token]}"
    }
  })
  p repo_content.body

  parsed_content = JSON.parse(repo_content.body)["content"]
  decoded_content = Base64.decode64(parsed_content)

  # p decoded_content.to_html

  new_project = Project.create(
    title: params[:project_title],
    description: params[:project_description],
    user_id: project_owner.id,
    user_project_code: decoded_content
    )
  if new_project.save
    redirect '/projects/' + new_project.id.to_s
  else
    "There was an error creating your project"
  end
end

get '/html_code_example' do
  project_code_url_array = params[:code].split('/')
  project_owner = User.find_by(github_id: session[:github_id])
  formatted_code_url = "https://api.github.com/repos/" + project_owner.username + "/" + project_code_url_array.shift + "/contents/" + project_code_url_array.join("/")
  # p project_code_url_array
  repo_content = HTTParty.get( formatted_code_url, {
    :headers => {
      "User-Agent" => "BootBase",
      "Authorization" => "token #{session[:github_token]}"
    }
  })

  parsed_content = JSON.parse(repo_content.body)["content"]
  decoded_content = Base64.decode64(parsed_content)
  p "$" * 100
  decoded_content.to_json
end

get '/projects/:id' do
  @user_id = session[:user_id]
  @this_project = Project.find(params[:id])
  @this_projects_tags = @this_project.tags
  # @html = CodeRay.scan(@this_project.user_project_code, :ruby).div(:line_numbers => :table)
  @html = @this_project.user_project_code

  erb :project_id
end

post '/projects/:id' do
  @this_project = Project.find(params[:id])
  @this_project.tags.create(name: params[:new_tag])

  redirect "/projects/#{@this_project.id}"
end

post '/tags/:id/votes' do
  this_vote = Vote.where(tag_id: params[:id], user_id: session[:user_id])
  if this_vote.count == 0
    Vote.create(tag_id: params[:id], user_id: session[:user_id])
  else
    this_vote.first.destroy
  end
  totes_votes_mcgoats = Vote.where(tag_id: params[:id])
  return_hash = {vote_count: totes_votes_mcgoats.count}
  return_hash.to_json
end

get '/logout' do
  session.clear
  redirect '/'
end


################## ATTEMPTING TO UNFUCK MY FUCKING AJAX

  # tag = Tag.find(params[:id])
  # p tag.votes
  # p "*" * 100
  # p tag.votes #.where(user_id: session[:user_id]).length
  # p "USER USER USER USER USER"
  # p session[:user_id]
  # if tag.votes.where(user_id: session[:user_id]).length > 0
  #   delete_me = Vote.find(tag_id: tag.id)
  #   p "&" * 100
  #   p delete_me
  #   p "BEFORE THE DELETE"
  #   p delete_me
  #   Vote.destroy(delete_me)
  #   p "AFTER THE DELETE"
  #   p delete_me
  # else
  #   Vote.create(tag_id: tag.id, user_id: session[:user_id])
  #   # User.find(session[:user_id].tag.votes)
  # end
  # p "$" * 100
  # p tag.votes.count
  # p "$" * 100
  # return_hash = {count: tag.votes.count}
  # return_hash.to_json



####################### ATTEMPTING TO UNFUCK MY FUCKING AJAX









  # response = HTTParty.post(url)
  # # "access_token=cb86bf5604102c8497c0d7843c6c71e0aa14a877&scope=&token_type=bearer"

  # data = Hash[response.body.split('&').map{|pair| pair.split('=')}]
  # # {"access_token"=>"cb86bf5604102c8497c0d7843c6c71e0aa14a877", "scope"=>nil, "token_type"=>"bearer"}

  # p data['access_token']

############################ vv CHRISTINE'S SUGGESTION FOR TAG VOTING

# post '/votes/:tag_id/:value' do

#   @tag = Tag.find(params[:tag_id])
#   @user = User.find(session[:id]) #find user in session
#   if @tag.votes.map(&:user_id).excludes?(@user.id)
#     #some code here that will create a vote
#     Vote.create(tag_id: @tag.id, user_id: @user.id, value: params[:value]) # params[:value] == 1 or -1
#   end

# end

############################ ^^ CHRISTINE'S SUGGESTION FOR TAG VOTING




