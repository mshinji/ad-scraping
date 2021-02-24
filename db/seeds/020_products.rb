hugkumi = Company.find_by(name: 'はぐくみプラス')

Product.where(asin_code: 'B073PY47QP').first_or_create! do |row|
  row.company_id = hugkumi.id
  row.asin_code = 'B073PY47QP'
  row.name = 'はぐくみオリゴ'
  row.status = 1
  row.resale_number = 1
  row.deleted = false
end

Product.where(asin_code: 'B017PGCGV2').first_or_create! do |row|
  row.company_id = hugkumi.id
  row.asin_code = 'B017PGCGV2'
  row.name = 'ハグクミの恵み'
  row.status = 1
  row.resale_number = 1
  row.deleted = false
end

Product.where(asin_code: 'B01GNZB3BK').first_or_create! do |row|
  row.company_id = hugkumi.id
  row.asin_code = 'B01GNZB3BK'
  row.name = 'はぐくみ葉酸'
  row.status = 1
  row.resale_number = 1
  row.deleted = false
end
