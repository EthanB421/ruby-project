require 'gruff'
require 'json'

json_data = File.read('output.json')

data = JSON.parse(json_data)

# Extract labels and values from the parsed data
values = data.map { |item| item['weight'] }
# puts labels.inspect

# Create a bar chart with Gruff
g = Gruff::Bar.new
g.title = 'Data from JSON'

g.data('Weight', values)
g.labels()
g.write('bar_chart_from_json.png')