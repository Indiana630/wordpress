#!/bin/bash
# Creado por Pepe Cabeza
# Actualizar el sistema
sudo apt update
sudo apt upgrade -y

# Instalar Nginx
sudo apt install nginx -y

# Instalar MySQL
sudo apt install mysql-server -y

# Instalar PHP
sudo apt install php-fpm php-mysql -y

# Descargar WordPress
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

# Crear la base de datos de WordPress
sudo mysql -u root -p << EOF
CREATE DATABASE wordpress;
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
FLUSH PRIVILEGES;
EOF

# Configurar Nginx
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
sudo touch /etc/nginx/sites-available/default
sudo chmod 666 /etc/nginx/sites-available/default
echo "server {
    listen 80;
    listen [::]:80;

    root /var/www/html/wordpress;
    index index.php index.html index.htm;

    server_name example.com www.example.com;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}" >> /etc/nginx/sites-available/default
sudo chmod 644 /etc/nginx/sites-available/default

# Mover WordPress a la carpeta de Nginx
sudo mv /tmp/wordpress /var/www/html/

# Configurar WordPress
cd /var/www/html/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpress/g" wp-config.php
sudo sed -i "s/username_here/wordpress/g" wp-config.php
sudo sed -i "s/password_here/wordpress/g" wp-config.php


# Reiniciar Nginx
sudo systemctl restart nginx

#Mensaje de finalización
echo "Wordpress instalado correctamente."
echo "Realizado por Pepe Cabeza"
