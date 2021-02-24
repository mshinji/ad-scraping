Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  puts "#{seed} start"
  load seed
  puts "#{seed} end"
end
