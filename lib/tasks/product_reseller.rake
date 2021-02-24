namespace :product_reseller do
  desc 'ステータスを既存データから移行'
  task replace_status: :environment do
    puts "#{Time.zone.now} Start ProductReseller Replace Status"
    # 引き下げ fine に更新
    ProductReseller.active.where(status: [3, 4, 7, 9]).update_all(status: 0)
    # 転売あり resale に更新
    ProductReseller.active.where(status: [6, 8, 10]).update_all(status: 1)
    # 買取済 bought に更新
    ProductReseller.active.where(status: 5).update_all(status: 3)

    puts "#{Time.zone.now} Finished ProductReseller Replace Status"
  end

  desc 'FirstFlgの初回データの更新'
  task first_flg_seed: :environment do
    puts "#{Time.zone.now} Start ProductReseller FirstFlg Seed"
    # 既存データのfirst_flgをすべてuncheckに更新
    ProductReseller.active.update_all(first_flg: 'uncheck')
    # ステータスが１回目のデータをすべてcheckedに更新
    ProductReseller.active.where(status: 'warning').update_all(first_flg: 'checked')

    puts "#{Time.zone.now} Finished ProductReseller FirstFlg Seed"
  end
end
