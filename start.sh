#!/bin/bash -e


GREEN='\033[0;32m'
NC='\033[0m' # No Color


clear
echo "${GREEN}"
echo "+---------------------+"
echo "| Instalador Wordpress|"
echo "+---------------------+"
echo "Realizado por Pepe Cabeza"
echo "${NC}"

read -r -p $'\e[34mDatabase Name: \e[0m' dbname
read -r -p $'\e[34mDatabase Username: \e[0m' dbuser
read -r -s -p $'\e[34mDatabase Password: \e[0m' dbpass; echo
stty echo
read -r -p $'\e[34mDatabase Hostname: \e[0m' dbhost
read -r -p $'\e[34mTheme name (e.g. My WP Theme): \e[0m' theme_name
read -r -p $'\e[34mTheme author: \e[0m' theme_author
read -r -p $'\e[34mTheme author URI: \e[0m' theme_author_uri
read -r -p $'\e[34mTheme description: \e[0m' theme_description
read -r -p $'\e[34mCorrer instalador? (Y/n) \e[0m' runº

if [ "$run" == n ] ; then
exit

else
printf '\n'
echo "Descargando última vesión de wordpress... "
curl --remote-name --silent --show-error https://wordpress.org/latest.tar.gz
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

echo "Descomprimiendo archivos... "
tar --extract --gzip --file latest.tar.gz
rm latest.tar.gz
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

echo "Poniendo archivos en su sitio... "
cp -R -f wordpress/* .
rm -R wordpress
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

echo "Configurando WordPress... "
cp wp-config-sample.php wp-config.php
sed -i "" "s/database_name_here/$dbname/g" wp-config.php
sed -i "" "s/username_here/$dbuser/g" wp-config.php
sed -i "" "s/password_here/$dbpass/g" wp-config.php
sed -i "" "s/localhost/$dbhost/g" wp-config.php

#   Set authentication unique keys and salts in wp-config.php
perl -i -pe '
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

echo "Aplicando permisos a los archivos y carpetas... "
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#
#   Install plugins
#   ------------------
#

#   ACF
echo "Obteniendo el Advanced Custom Fields plugin...";
wget --quiet https://downloads.wordpress.org/plugin/advanced-custom-fields.zip;
unzip -q advanced-custom-fields.zip;
mv advanced-custom-fields/ wp-content/plugins/
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#   ACF for Yoast SEO
echo "Obteniendo análisis de contenido ACF para el complemento Yoast SEO...";
wget --quiet https://downloads.wordpress.org/plugin/acf-content-analysis-for-yoast-seo.zip;
unzip -q acf-content-analysis-for-yoast-seo.zip;
mv acf-content-analysis-for-yoast-seo/ wp-content/plugins/
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#   Wordfence Security
echo "Obteniendo el complemento de seguridad de Wordfence...";
wget --quiet https://downloads.wordpress.org/plugin/wordfence.zip;
unzip -q wordfence.zip;
mv wordfence/ wp-content/plugins/
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#   WordPress SEO a.k.a. Yoast
echo "Obteniendo el complemento SEO de WordPress (también conocido como Yoast)...";
wget --quiet https://downloads.wordpress.org/plugin/wordpress-seo.zip;
unzip -q wordpress-seo.zip;
mv wordpress-seo/ wp-content/plugins/
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#
#   Remove default WP plugins
#   ------------------
#
echo "Eliminar complementos predeterminados de WordPress..."
rm -rf wp-content/plugins/akismet
rm -rf wp-content/plugins/hello.php
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#
#   Remove older WordPress default themes
#   ------------------
#
echo "Eliminando default WordPress themes..."
rm -rf wp-content/themes/twentyfifteen
rm -rf wp-content/themes/twentysixteen
rm -rf wp-content/themes/twentyseventeen
rm -rf wp-content/themes/twentynineteen
rm -rf wp-content/themes/twentytwenty
rm -rf wp-content/themes/twentytwentyone
rm -rf wp-content/themes/twentytwentytwo
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#
#   Instalando boilerplate theme (packaged with Gulp.js)
#
#   ------------------
#
theme_slug=$(echo "${theme_name}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '-' | tr '[:upper:]' '[:lower:]')

echo "Descargando boilerplate theme packaged with Gulp.js..."
curl -LOk --silent https://github.com/jasewarner/gulp-wordpress/archive/master.zip
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

echo "Descomprimiendo y moviendo el zip..."
unzip -q master.zip
mv gulp-wordpress-master/ wp-content/themes/"${theme_slug}"
echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

echo "Updateando el theme..."

#   remove theme git files
rm wp-content/themes/"${theme_slug}"/.gitignore

#   style.css
sed -i "" "s?<Theme_Name>?$theme_name?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Author>?$theme_author?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Author_URI>?$theme_author_uri?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Description>?$theme_description?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Text_Domain>?$theme_slug?g" wp-content/themes/"${theme_slug}"/style.css

#   gulp.js
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/assets/gulpfile.js
sed -i "" "s?package-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/assets/package.json
sed -i "" "s?package-description?$theme_description?g" wp-content/themes/"${theme_slug}"/assets/package.json
sed -i "" "s?author-name?$theme_author?g" wp-content/themes/"${theme_slug}"/assets/package.json

#   wp script handle
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/functions/func-script.php

#   wp style handle
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/functions/func-style.php

#   php theme files
sed -i "" "s?<Author>?$theme_author?g" wp-content/themes/"${theme_slug}"/*.php
sed -i "" "s?<Package>?$theme_slug?g" wp-content/themes/"${theme_slug}"/*.php
sed -i "" "s?<Author>?$theme_author?g" wp-content/themes/"${theme_slug}"/functions/*.php
sed -i "" "s?<Package>?$theme_slug?g" wp-content/themes/"${theme_slug}"/functions/*.php

#   add author admin credit to backend
sed -i "" "s?http://author.com?$theme_author_uri?g" wp-content/themes/"${theme_slug}"/functions/func-admin.php
sed -i "" "s?Author Name?$theme_author?g" wp-content/themes/"${theme_slug}"/functions/func-admin.php

echo "${GREEN}Hecho! ✅${NC}"
printf '\n'

#
#   Tidy up
#   ------------------
#

#   Pasos finales
echo "Ahora los pasos finales:"

#   Cleanup
printf '\n'
echo "Limpiando los archivos temporales...";
rm -- *.zip

#   Remove installation script file
rm -rf wordpress.sh;

#   Disable the built-in file editor
echo "Deshabilitando el editor de archivos...";
echo "
/** Disable the file editor */
define( 'DISALLOW_FILE_EDIT', true );" >> wp-config.php

#   Define the default theme
echo "Definiendo el tema default...";
echo "
/** Define the default theme */
define( 'WP_DEFAULT_THEME', '${theme_slug}' );" >> wp-config.php

#   Remove wp-config-sample.php
echo "Eliminando wp-config-sample.php..."
rm -rf wp-config-sample.php

printf '\n'
echo "${GREEN}Fantástico! Todo listo 🙌${NC}";

fi
