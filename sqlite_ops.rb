require 'sqlite3'
require 'base64'

# Method to open and return the contents of SQLite database
def read_db()
  if File.exist?('public/personal_details.db')
    db = SQLite3::Database.open './public/personal_details.db'
  else
    db = []
  end
end

# Method to determine if value is too long or if user in current user hash is already in JSON file
def check_values(user_hash)
  db = read_db()  # open database for review
  flag = 0
  feedback = ""
  detail = ""
  user_hash.each do |key, value|
    flag = 2 if key == "age" && value.to_i > 120
    (flag = 3; detail = key) if value.length > 20
    flag = 4 if key == "name" && value =~ /[^a-zA-Z ]/
    (flag = 5; detail = key) if key =~ /age|n1|n2|n3/ && value =~ /[^0-9.,]/
  end
  users = db.execute("select name from details order by name").flatten
  users.each { |user| flag = 1 if user == user_hash["name"]}
  case flag
    when 1 then feedback = "We already have details for that person - please enter a different person."
    when 2 then feedback = "I don't think you're really that old - please try again."
    when 3 then feedback = "The value for '#{detail}' is too long - please try again with a shorter value."
    when 4 then feedback = "Your name should only contain letters - please try again."
    when 5 then feedback = "The value for '#{detail}' should only have numbers - please try again."
  end
  return feedback
end

# Method to add current user hash to SQLite db
def write_db(user_hash)
  feedback = check_values(user_hash)
  if feedback == ""
    db = read_db() # open database for updating
    db.results_as_hash  # determine current max index (id) in details table
    max_id = db.execute('select max("id") from details')[0][0]
    max_id == nil ? id = 1 : id = max_id + 1  # set index variable based on current max index value
    name = user_hash["name"]  # prepare data from user_hash for database insert
    age = user_hash["age"]
    n1 = user_hash["n1"]
    n2 = user_hash["n2"]
    n3 = user_hash["n3"]
    quote = user_hash["quote"]
    file_open = File.binread(user_hash["image"][:tempfile])  # prepare image for database insertion
    image = Base64.strict_encode64(file_open)   # use strict base64 encoding
    blob = SQLite3::Blob.new image
    db.execute('insert into details (id, name, age, num_1, num_2, num_3, quote)
                values(?, ?, ?, ?, ?, ?, ?)', [id, name, age, n1, n2, n3, quote])
    db.execute('insert into images (id, details_id, image)
                values(?, ?, ?)', [id, id, blob])
  end
end

# Method to rearrange names for (top > down) then (left > right) column population
def rotate_names(names)
  quotient = names.count/3  # baseline for number of names per column
  names.count % 3 > 0 ? remainder = 1 : remainder = 0  # remainder to ensure no names dropped
  max_column_count = quotient + remainder  # add quotient & remainder to get max number of names per column
  matrix = names.each_slice(max_column_count).to_a    # names divided into three (inner) arrays
  results = matrix[0].zip(matrix[1], matrix[2]).flatten   # names rearranged (top > bottom) then (left > right) in table
  results.each_index { |name| results[name] ||= "" }  # replace any nils (due to uneven .zip) with ""
end

# Method to return array of sorted/transposed names from SQLite db for populating /list_users table
def get_names()
  db = read_db()
  names = []
  query = db.execute("select name from details order by name")
  query.each { |name| names.push(name[0])}
  names
  sorted = names.count > 3 ? rotate_names(names) : names  # rerrange names if more than 3 names
end

# Method to return user hash from SQLite db for specified user
def get_data(user_name)
  db = read_db()
  db.results_as_hash = true
  user_hash = db.execute("select * from details join images on details.id = images.details_id where details.name = '#{user_name}'")
  return user_hash[0]  # get hash from array
end

# Method to return (strict) base64-encoded image for the specified user
def get_image(user_name)
  user_hash = get_data(user_name)
  image = user_hash["image"]
end

# Method to return the sum of favorite numbers
def sum(n1, n2, n3)
  sum = n1.to_i + n2.to_i + n3.to_i
end

# Method to compare the sum of favorite numbers against the person's age
def compare(sum, age)
  comparison = (sum < age.to_i) ? "less" : "greater"
end

p get_data("Jim")