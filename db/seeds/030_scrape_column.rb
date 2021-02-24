Product.where(is_scrape: 'stop').update_all(scrape: 'stopped')
Product.where(is_scrape: 'run').update_all(scrape: 'running')
