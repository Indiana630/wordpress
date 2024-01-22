#!/bin/bash

print_green() {
  echo -e "\e[32m$1\e[0m"
}
print_red() {
  echo -e "\e[31m$1\e[0m"
}
if [[ $EUID -ne 0 ]]; then
  print_red "El script debe ejecutarse como administrador."
  exit 1
fi

print_green "Actualizando index de los paquetes y descargando estos..."
sudo apt-get update && sudo apt-get upgrade -y

# Instalacion de Wordpress MySQL y apache
print_green "Instalando requisitos previos (Wordpress, servidor web y php)"
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php # Ultima version PHP
sudo apt-get update
sudo apt-get install -y php7.4 php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-zip php7.4-xmlrpc

# Instalando MYSQL y configurando este (reemplaza 'your_mysql_password' con tu contraseña deseada)
sudo print_green "Instalando base de datos..."
apt-get install -y mysql-server
mysql_secure_installation

print_green "Instalando servidor web..."
apt-get install -y apache2
a2enmod rewrite
systemctl restart apache2

# Descarga y extrae wordpress
print_green "Descargando y desempaquetando wordpress..."
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz -C /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

print_green "Instalación de wordpress completada"
rm /tmp/latest.tar.gz

print_green "IMPORTANTE: Recuerda anotar la contraseña root de MySQL por si hiciera falta acceder a la base de datos"
print_blue "Creado por Pepe Cabeza"
