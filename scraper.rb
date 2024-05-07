require 'nokogiri'
require 'httparty'
require 'json'

def scraper
  url = "https://scrapeme.live/shop/"
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

  products = []  #Stores product info

  items = parsed_page.css('main ul.products li.product')  #Gets each item on the page

  if items.empty?
    puts "No items found"
  else
    items.each do |item|
      name = item.css('h2').text.strip  #Extract product name
      price = item.css('span.price').text.strip  #Extract product price
      product = { name: name, price: price }  #Create a hash representing the product
      products << product  #Add the product to array
    end
  end

  # Convert the array of product hashes to JSON
  json_data = JSON.pretty_generate(products)

  # Write the JSON data to a file
  File.open("output.json", "w") do |file|
    file.write(json_data)
  end
end

scraper 
