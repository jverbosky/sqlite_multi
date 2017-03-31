require 'sinatra'
require_relative 'sqlite_ops.rb'

class PersonalDetailsSQLiteApp < Sinatra::Base

  get '/' do
    names = get_names()  # get an array of all of the user names in SQLite db
    erb :list_users, locals: {names: names}
  end

  get '/user_info' do
    name = params[:name]  # get the specified name from the url in list_users.erb (url = "/user_info?name=" + name)
    user_hash = get_data(name)  # get the hash of info for the specified user
    file = get_image(name)  # get the image for the specified user
    erb :user_info, locals: {user_hash: user_hash, file: file}
  end

end