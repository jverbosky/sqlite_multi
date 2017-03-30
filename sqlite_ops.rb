require 'sqlite3'
require 'base64'

# begin

    def get_data(column, value)

      info = []

      db = SQLite3::Database.open './public/personal_details.db'
      db.results_as_hash = true

      # example of getting column names
      # d_columns = db.execute2("select * from details join images on details.id = images.details_id")[0]
      # p d_columns  # ["id", "name", "age", "num_1", "num_2", "num_3", "quote", "id", "details_id", "image"]

      # example of getting all data from both tables in personal_details.db
      # p db.execute('select * from details join images on details.id = images.details_id')

      user_hash = db.execute("select * from details join images on details.id = images.details_id where details.#{column} = '#{value}'")

      # prepare data for iteration
      # d_query = db.prepare("select * from details join images on details.id = images.details_id where name = #{name}")
      # d_rows = d_query.execute

      # iterate through each row for user data and image
      # d_rows.each do |row|

      #   # output user data to console
      #   puts "Details ID: #{row['id']}"
      #   puts "Images ID: #{row['details_id']}"
      #   puts "Name: #{row['name']}"
      #   puts "Age: #{row['age']}"
      #   puts "Favorite number 1: #{row['num_1']}"
      #   puts "Favorite number 2: #{row['num_2']}"
      #   puts "Favorite number 3: #{row['num_3']}"
      #   puts "Quote: #{row['quote']}"

      #   # output user image to current directory, named based on user name and ID
      #   image = row['image']
      #   f = File.new "#{row['name']}_#{row['id']}_output.png", "wb"
      #   f.write image
      #   f.close if f
      # end

      return user_hash[0]

    end

    def get_image(column, value)
      user_hash = get_data(column, value)
      image = user_hash["image"]
      # cleaned = image_string.gsub("\u0000", '')
      # file = StringIO.new(image_string)
      # file = File.new(cleaned)
      # file = File.binread(cleaned, "rb").read
      # file = IO.binread(cleaned)
      # file = File.open(image_string, "rb").read
      # return file
    end


      # image = row['image']
      # f = File.new "#{row['name']}_#{row['id']}_output.png", "wb"
      # f.write(Base64.decode64(image))



# user_hash = get_data("name", "John")
# # p user_hash["image"]
# image = get_image("name", "John")
# p image


    # --- Example data ---
    # Details ID: 1
    # Images ID: 1
    # Name: John
    # Age: 41
    # Favorite number 1: 7
    # Favorite number 2: 11
    # Favorite number 3: 3
    # Quote: Research is what I'm doing when I don't know what I'm doing.
    # --------------------

# rescue SQLite3::Exception, SystemCallError => e

#     puts "Exception occurred"
#     puts e

# ensure

#     db.close if db

# end