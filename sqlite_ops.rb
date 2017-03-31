require 'sqlite3'
require 'base64'

# Method to return the contents of SQLite database
def read_db()
  if File.exist?('public/personal_details.db')
    db = SQLite3::Database.open './public/personal_details.db'
  else
    db = []
  end
end

# Method to rearrange names for (top > down) then (left > right) column population
def rotate_names(names)
  quotient = names.count/3  # baseline for number of names per column
  names.count % quotient > 0 ? remainder = 1 : remainder = 0  # remainder to ensure no names dropped
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