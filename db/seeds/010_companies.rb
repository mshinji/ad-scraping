Company.where(name: 'はぐくみプラス').first_or_create! do |row|
  row.name = 'はぐくみプラス'
  row.email = 'hugkumiyoshiro@gmail.com'
  row.password = 'hug0214'
  row.password_confirmation = 'hug0214'
  row.address = '福岡県福岡市中央区 薬院1-5-6ハイヒルズ７階'
  row.status = 0
  row.notification_status = true
  row.seller_id = 'A14G6FT26TR5V7'
end
