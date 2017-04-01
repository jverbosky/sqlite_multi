require 'sinatra'
require_relative 'sqlite_ops.rb'

class PersonalDetailsSQLiteApp < Sinatra::Base

  get "/" do
    name = ""
    age = ""
    n1 = ""
    n2 = ""
    n3 = ""
    quote = ""
    avatar = ""
    # variables used in /post_info route, passing empty string to view to avoid error message
    erb :get_info, locals: {name: name, age: age, n1: n1, n2: n2, n3: n3, quote: quote, avatar: avatar}
  end

  post '/post_info' do
    user_hash = params[:user]  # assign the user hash to the user_hash variable
    # tempfile = params[:user][:image][:tempfile]
    # File.open('public/' + params[:user][:image][:filename], "w") do |f|
    #   f.write(params[:user][:image][:tempfile].read)
    # end
    # tempfile = File.binread(params[:user][:image][:tempfile])
    # filename = params[:user][:filename]
    # "#{user_hash}"  # {"name"=>"Bob Wiley", "age"=>"30", "n1"=>"21", "n2"=>"22", "n3"=>"23", "quote"=>"Here it is!", "image"=>{:filename=>"upload_1.png", :type=>"image/png", :name=>"user[image]", :tempfile=>#, :head=>"Content-Disposition: form-data; name=\"user[image]\"; filename=\"upload_1.png\"\r\nContent-Type: image/png\r\n"}}
    # update_user(user_hash)  # if not, add user info to SQLite db
    # update_image(tempfile)
    write_db(user_hash)
    # "DB updated - hopefully!"
    # name = user_hash["name"]  # user name from the resulting hash
    # age = user_hash["age"]  # user age from the resulting hash
    # n1 = user_hash["n1"]  # favorite number 1 from the resulting hash
    # n2 = user_hash["n2"]  # favorite number 2 from the resulting hash
    # n3 = user_hash["n3"]  # favorite number 3 from the resulting hash
    # total = sum(n1, n2, n3)
    # comparison = compare(total, age)
    # quote = user_hash["quote"]  # quote from the resulting hash
    # avatar = get_image(name)  # get the image for the specified user
    # erb :get_more_info, locals: {name: name, age: age, n1: n1, n2: n2, n3: n3, total: total, comparison: comparison, quote: quote, avatar: avatar}
    # erb :get_more_info, locals: {name: name, age: age, n1: n1, n2: n2, n3: n3, total: total, comparison: comparison, quote: quote}
  end

  get '/list_users' do
    names = get_names()  # get an array of all of the user names in SQLite db
    erb :list_users, locals: {names: names}
  end

  get '/user_info' do
    name = params[:name]  # get the specified name from the url in list_users.erb (url = "/user_info?name=" + name)
    user_hash = get_data(name)  # get the hash of info for the specified user
    avatar = get_image(name)  # get the image for the specified user
    erb :user_info, locals: {user_hash: user_hash, avatar: avatar}
  end

end