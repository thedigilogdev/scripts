#!/bin/bash

echo "##################################################"
printf "\n\n## Update & Upgrade \n\n"
apt update && apt -y upgrade

printf "\n\n## Installation of required items\n\n"
apt install -y nginx php8.2-fpm php8.2-gd php-json php8.2-mysql php8.2-curl php8.2-mbstring php8.2-intl php-imagick php8.2-xml php8.2-zip php8.2-redis php8.2-bcmath php8.2-soap composer 

printf "\n\n## php-fprm \n\n"
cd /etc/php/8.2/fpm/pool.d/
sed -i "s/\;slowlog\ \=\ log\/\$pool\.log\.slow/slowlog\ \=\ \/var\/log\/php82-fpm\/www-slow\.log/g" www.conf
sed -i 's/\;request\_slowlog\_timeout\ \=\ 0/request\_slowlog\_timeout\ \=\ 10s/g' www.conf
sed -i 's/\;request\_terminate\_timeout\ \=\ 0/request\_terminate\_timeout\ \=\ 1200/g' www.conf
sed -i 's/\;catch\_workers\_output\ \=\ yes/catch\_workers\_output = yes/g' www.conf
sed -i 's/user\ \=\ www-data/user\ \=\ admin/g' www.conf
sed -i 's/group\ \=\ www-data/group\ \=\ admin/g' www.conf

mkdir /var/log/php82-fpm
service php8.2-fpm start

printf "\n\n## php.ini \n\n"
cd /etc/php/8.2/fpm/
#sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Asia\/Seoul/g' php.ini
sed -i 's/post\_max\_size\ \=\ 8M/post\_max\_size\ =\ 50M/g' php.ini
sed -i 's/upload\_max\_filesize\ \=\ 2M/upload\_max\_filesize\ \=\ 50M/g' php.ini
sed -i 's/memory\_limit\ \=\ 128M/memory\_limit\ \=\ 512M/g' php.ini

printf "\n\n## nginx \n\n"
cd /etc/nginx/
sed -i 's/user\ www\-data\;/user\ admin\;/g' nginx.conf

rm /etc/nginx/sites-enabled/default


printf "\n\n## Web Base Dir Setting\n\n"

mkdir -p /home/admin/web/public
mkdir -p /home/admin/log/
mkdir -p /home/admin/ssl/
mkdir -p /home/admin/conf/

wget https://raw.githubusercontent.com/thedigilogdev/scripts/main/united-producers-shop/opencart.conf -O /home/admin/conf/opencart-nginx.conf

ln -s /home/admin/conf/opencart-nginx.conf /etc/nginx/sites-enabled/opencart.conf

echo "<?php phpinfo(); ?>" > /home/admin/web/public/index.php
chown -R admin:admin /home/admin/web



## OPENSSL key
printf "\n\n## Create SSL key\n\n"

cd /home/admin/ssl/

openssl genrsa -out rootCA.key 2048
echo -ne "\n\n\n\n\n\n\n\n\n" | openssl req -new -key rootCA.key -out rootCA.csr
openssl x509 -req -in rootCA.csr -signkey rootCA.key -out rootCA.crt
openssl genrsa -out server.key 2048
echo -ne "\n\n\n\n\n\n\n\n\n" | openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt

service nginx restart
service php8.2-fpm restart



# bash -c "$(wget -qLO - https://raw.githubusercontent.com/thedigilogdev/scripts/main/united-producers-shop/opencart_deb12.sh )"

