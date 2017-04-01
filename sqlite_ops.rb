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

# Method to add current user hash to SQLite db
def write_db(user_hash)

  # open database for updating
  db = read_db()

  # determine current max index (id) in details table
  db.results_as_hash
  max_id = db.execute('select max("id") from details')[0][0]

  # set index variable based on current max index value
  max_id == nil ? id = 1 : id = max_id + 1

  # prepare data from user_hash for database insert
  name = user_hash["name"]
  age = user_hash["age"]
  n1 = user_hash["n1"]
  n2 = user_hash["n2"]
  n3 = user_hash["n3"]
  quote = user_hash["quote"]

  # prepare image for database insertion (use strict base64 encoding)
  file_open = File.binread(user_hash["image"][:tempfile])
  image = Base64.strict_encode64(file_open)
  blob = SQLite3::Blob.new image

  # insert user data into details table
  db.execute('insert into details (id, name, age, num_1, num_2, num_3, quote)
              values(?, ?, ?, ?, ?, ?, ?)', [id, name, age, n1, n2, n3, quote])

  # insert user image into images table
  db.execute('insert into images (id, details_id, image)
              values(?, ?, ?)', [id, id, blob])

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