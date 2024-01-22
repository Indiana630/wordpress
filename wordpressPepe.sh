#!/bin/bash
#Realizado por Pepe Cabeza
# Actualizar la lista de paquetes
sudo apt update

# Instalar Nginx
sudo apt install nginx -y

# Instalar MariaDB
sudo apt install mariadb-server mariadb-client -y

# Asegurar la instalación de MariaDB
sudo mysql_secure_installation

# Instalar PHP y los módulos necesarios
sudo apt install php-fpm php-mysql -y

# Descargar y extraer la última versión de WordPress
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/

# Establecer los permisos correctos
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Crear una nueva base de datos y usuario para WordPress
echo "Por favor, introduce el nombre de la base de datos de WordPress:"
read dbname
echo "Por favor, introduce el nombre de usuario de la base de datos de WordPress:"
read dbuser
echo "Por favor, introduce la contraseña de la base de datos de WordPress:"
read dbpass
sudo mysql -u root -p << EOF
CREATE DATABASE $dbname;
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Configurar Nginx
sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-available/wordpress
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo bash -c 'cat << EOF > /etc/nginx/sites-available/wordpress
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/wordpress;
    index index.php index.html index.htm;
    server_name localhost;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }
}
EOF'


# Configurar WordPress
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/$dbname/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/$dbuser/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/$dbpass/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/127.0.0.1/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/\/\/define('FS_METHOD', 'direct');/define('FS_METHOD', 'direct');/g" /var/www/html/wordpress/wp-config.php

# Probar la configuración de Nginx
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
