FROM ruby:2.5.3-stretch

RUN gem install -v 5.2.1 rails
RUN apt-get update && \
    apt-get install -y nodejs mysql-client vim git



######################################## RDSとの接続
RUN cd /app/src && rails new .

COPY ./bind/Gemfile /app/src/Gemfile
COPY ./bind/Gemfile.lock /app/src/Gemfile.lock
RUN cd /app/src && bundle install

COPY ./bind/database.yml /app/src/config/database.yml
# mysql -u root -h RDS_endpoint -pで確認
RUN cd /app/src && rails db:create
# http://ip:3000で表示確認

COPY ./bind/seeds.rb app/src/db/seeds.rb
RUN cd /app/src && rails g scaffold article title:string body:text
RUN cd /app/src && rails db:migrate && rails db:seed

######################################## Redis設定
COPY ./bind/development.rb /app/src/config/environments/development.rb
COPY ./bind/articles_controller.rb /app/src/app/controllers/articles_controller.rb
COPY ./bind/redis.rb app/src/config/initializers/redis.rb

# 毎回DBから読み込んでしまう！！設定ミスがあると思われる

# docker ps
# docker exec -it コンテナ /bin/bash

# rails s -b 0.0.0.0

# http://ip:3000
# http://ip:3000/articles