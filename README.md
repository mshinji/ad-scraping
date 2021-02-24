OSX ユーザーは Vagrant up/Vagrant ssh してから実行すること

## setting docker

```
$ docker-compose build
```

## start server

```
$ docker-compose up

or

$ docker-compose up -d
```

## setting database

```

# 下記が出来なければ docker-compose run --rm web bundle exec rails db:create db:migrate
$ docker-compose exec web bundle exec rails db:create db:migrate
```

### 初期データ(dump)を入れたい場合

```
$ docker-compose up

# 下記が出来なければ docker-compose run --rm web bundle exec rails db:create
$ docker-compose exec web bundle exec rails db:create

$ cat <ダンプファイル> | docker exec -i ad-reseller-postgres psql -U amazon_reseller_ban -d ad_scraping_development
```

## drop database

```
$ docker-compose run --rm web bundle exec rails db:drop
```

## import dump file

```
$ cat <ダンプファイル> | docker exec -i ad-reseller-postgres psql -U amazon_reseller_ban -d ad_scraping_development
```
