#!/bin/sh

docker-compose run --rm web bundle exec rails db:drop db:create
# Cloud_SQL_Export.sqlをscirpt/database配下へおいて実行する
# cat ./script/database/Cloud_SQL_Export.sql | docker exec -i ad-scraping-postgres psql -U ad_scraping -d ad_scraping_development
docker-compose run --rm web bundle exec rails db:migrate
