user = { name: "Alice", age: 30 }

print user[:name]

user.each do |key, value|
  puts "#{key}: #{value}"
end

