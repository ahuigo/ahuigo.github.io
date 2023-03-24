---
title: Docker build node 速度
date: 2019-12-02
private: true
---
# 构建方法
以ant design pro 为例

## node dockerfile

### dockerfile.base: node_modules

    # dockerfile.base
    From node:13.3.0-stretch-slim
    COPY package.json /app/
    WORKDIR /app
    RUN yarn config set registry https://registry.npm.taobao.org && yarn

### dokerfile: app

    From registry.ahuigo.com/proj-base:latest
    ENV NODE_OPTIONS=--max_old_space_size=4096
    EXPOSE 8000
    COPY . /app
    WORKDIR /app
    RUN yarn config set registry 'https://registry.npm.taobao.org' &&  yarn  && npm run build

## nginx docker
nginx.conf

    server {
        listen 80;
        gzip on;
        gzip_vary on;
        gzip_disable "MSIE [1-6]\.";

        root /usr/share/nginx/html;
        include /etc/nginx/mime.types;
        location / {
            try_files $uri $uri/ /index.html;
        }
    }

dockerfile 直接用: `nginx:1.16.1`


## compose
参考： https://github.com/ant-design/ant-design-pro/blob/master/docker/docker-compose.yml

    version: '3.5'

    services:
      dist:
        build: ./
        container_name: 'antbear-ui-dist'
        volumes:
          - dist:/app/dist

      nginx:
        image: nginx:1.16.1
        ports:
          - 8000:8000
        container_name: 'antbear-ui-nginx'
        restart: unless-stopped
        volumes:
          - dist:/usr/share/nginx/html:ro
          - ./nginx.conf:/etc/nginx/conf.d/default.conf

    volumes:
      dist: