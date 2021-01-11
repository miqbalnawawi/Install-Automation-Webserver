#!/bin/bash

echo "============update repo================"
#update 
sudo apt-get update -y

echo "===========install package nginx , mysql , php , git =================="
#install package nginx , mysql , php dan git
sudo apt-get install -y nginx php-mysqli mysql-server php-fpm git	

echo "===================create config nginx file pesbuk==============="
#create config nginx file pesbuk
sudo tee /etc/nginx/sites-available/pesbuk <<EOF
server {
        
        listen 80;
        root /var/www/html;
        # Add index.php to the list if you are using PHP
        index index.php index.html index.htm index.nginx-debian.html;
        server_name localhost;
        location / {
        #index.php index.html index.htm;
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$uri \$uri/ =404;
        }
        location ~ \.php$ {
          include snippets/fastcgi-php.conf;
          fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        }
}
EOF

echo "=======Hapus file Html dan clone pesbuk dari github"
#setup application
sudo rm -rf /var/www/html/*
cd /var/www/html && sudo git clone https://github.com/miqbalnawawi/sosial-media.git && sudo mv sosial-media/* .


echo "samakan site available dan site enable"
#samakan site available dan site enable
sudo ln -s /etc/nginx/sites-available/pesbuk /etc/nginx/sites-enabled/pesbuk

echo "unlink default"
#unlink default
sudo unlink /etc/nginx/sites-enabled/default
sudo unlink /etc/nginx/sites-available/default


echo "==============create database=========="
#create database
cd /var/www/html/ 
sudo mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS dbsosmed;
CREATE USER IF NOT EXISTS 'iqbal'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON * . * TO 'iqbal'@'localhost';
FLUSH PRIVILEGES;   
EOF


echo "samakan database"
#dump / samakan database
sudo mysql dbsosmed < dump.sql

echo "=========================restart service====================="
#restart service
sudo nginx -t
sudo systemctl restart nginx
