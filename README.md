# lnmp
lnmp环境

# centos-php7.2-nginx
Docker image with centos, php7.2 and nginx

Build:
docker build -t vagranttiger/php7-nginx .

Run docker container:
docker run -d --name php7-nginx -p 80:80 --restart=always -v /path/to/project:/var/www/app vagranttiger/php7-nginx