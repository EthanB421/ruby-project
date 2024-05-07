require 'nokogiri'
require 'httparty'
require 'json'

def scraper(page_number)
  url = "https://scrapeme.live/shop/page/#{page_number}"
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

  products = []  # Stores product info

  items = parsed_page.css('main ul.products li.product')  #Gets each item

  if items.empty?
    puts "No items found on page #{page_number}"
  else
    items.each do |item|
      name = item.css('h2').text.strip  #Extract name
      price = item.css('span.price').text.strip  #Extract price
      
      #Second url to add quantity since it was on another page
      second_url = "https://scrapeme.live/shop/#{name}"
      unparsed_second_page = HTTParty.get(second_url)
      parsed_second_page = Nokogiri::HTML(unparsed_second_page)
      
      # Extract additional information from the second page
      quantity_string = parsed_second_page.css('div.summary p.stock').text.strip  # Extractquantity as string

      #Convert to integer
      quantity = quantity_string.scan(/\d+/).first.to_i 

      product = { name: name, price: price, quantity: quantity }  #Create a hash representing the product
      products << product  # Add product to array
    end
  end

  products
end

# Scrape multiple pages and collect the data
all_products = []
(1..2).each do |page_number|
  all_products.concat(scraper(page_number))
end

# Convert the array of product hashes to JSON
json_data = JSON.pretty_generate(all_products)

# Write the JSON data to a file
File.open("output.json", "w") do |file|
  file.write(json_data)
end
