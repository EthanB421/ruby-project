require 'nokogiri'
require 'httparty'
require 'json'

def clean_string(original_text)
  # Remove "Categories:", commas, and the word "Pokemon"
  cleaned_text = original_text.gsub(/Categories:|,|Pokemon|kg/i, '')
  
  # Remove extra spaces
  cleaned_text = cleaned_text.strip.squeeze(' ')
  
  cleaned_text
end


def scraper(page_number)
  url = "https://scrapeme.live/shop/page/#{page_number}"
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

  products = []  # Stores product info

  items = parsed_page.css('main ul.products li.product')  # Gets each item

  if items.empty?
    puts "No items found on page #{page_number}"
  else
    items.each do |item|
      name = item.css('h2').text.strip  # Extract name
      price = item.css('span.price').text.strip  # Extract price
      
      # Second url to add quantity since it was on another page
      second_url = "https://scrapeme.live/shop/#{name}"
      unparsed_second_page = HTTParty.get(second_url)
      parsed_second_page = Nokogiri::HTML(unparsed_second_page)
      
      # Extract additional information from the second page
      quantity_string = parsed_second_page.css('div.summary p.stock').text.strip  # Extract quantity as string
      categories_string = parsed_second_page.css('div.summary span.posted_in').text.strip # Extract categories as string
      weight_string = parsed_second_page.css('div.woocommerce-tabs td.product_weight').text.strip # Extract weight as string
      dimensions = parsed_second_page.css('div.woocommerce-tabs td.product_dimensions').text.strip # Extract dimensions as string

      # Convert to integer
      quantity = quantity_string.scan(/\d+/).first.to_i 

      # Remove unwanted words from categories
      categories = clean_string(categories_string)

      # Remove unwanted words from weight
      weight = clean_string(weight_string)

      product = { name: name, price: price, quantity: quantity, categories: categories, weight: weight, dimensions: dimensions}  # Create a hash representing the product
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