#!/bin/sh

for i in `seq 1 $1`
do
  echo "=======================$i回目======================="
  bundle exec rails amazon_scraping:check_reseller[$2]
  echo "===================================================="
done
