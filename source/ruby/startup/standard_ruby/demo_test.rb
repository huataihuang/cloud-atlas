def calculate_score(name, score)
  puts 'Processing user: ' + name

  return 'Excellent' if score > 90

  'Good'
end

user_name = 'John'
final_score = 95

# 这里故意留了很多空行和混乱的缩进

puts calculate_score(user_name, final_score)
