require 'sinatra'
require_relative 'sqlite_ops.rb'

class PersonalDetailsSQLiteApp < Sinatra::Base

  get '/' do
    user_hash = get_data("name", "John")
    # user = "John"
    file = get_image("name", "John")
    erb :user_info, locals: {user_hash: user_hash, file: file}
  end

end