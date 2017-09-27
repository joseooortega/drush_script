function edit_files(){

  subdirectorio=$2
  nombre=$1

  if [ "$2" == "" ]; then
    subdirectorio='dev'
  fi

  if [ "$2" == "git" ]; then
    c='-projects'
  else
    c=''
  fi

  # FICHERO HOSTS
  primera_parte="127.0.0.1       $subdirectorio.$nombre"
  echo $primera_parte >> /private/etc/hosts

  # FICHERO VHOSTS
  primera_parte="<VirtualHost *>
      ServerName $subdirectorio."
  segunda_parte="
      DocumentRoot /Applications/XAMPP/xamppfiles/htdocs/$subdirectorio$c/"
  tercera_parte="
</VirtualHost>
"
  echo "$primera_parte$nombre$segunda_parte$nombre$tercera_parte" >> /Applications/XAMPP/xamppfiles/etc/extra/httpd-vhosts.conf

  # FICHERO DRUSH
  primera_parte='$aliases["'
  segunda_parte='"] = array("uri" => "'
  tercera_parte="$subdirectorio."
  cuarta_parte='","root" => $root."/'
  quinta_parte='",);'
  echo "$primera_parte$nombre$segunda_parte$tercera_parte$nombre$cuarta_parte$quinta_parte" >> /Users/jose/drush/aliases.drushrc.php
}







cd /Applications/XAMPP/xamppfiles/htdocs
while true
do
clear
echo ''
echo '******************************'
echo "Opción 1: Crear nuevo drupal 7 (requiere sudo)"
echo "Opción 2: Limpiar caches"
echo "Opción 3: Instalar y activar modulo"
echo "Opción 5: Editar script"
echo "Opción 6: Reiniciar servicios Xampp"
echo "Opción 7: Modificar archivos para nueva web"
echo "Opción 0: Salir"
echo '******************************'
echo ''
echo "Your option -> "
read option
echo ''

if [ "$option" == "1" ]; then
  echo -n 'Escribe el nombre de la nueva web'
  read nombre
  echo -n 'Escribe el nombre del subdirectorio - htdocs por defecto'
  read subdirectorio

  edit_files $nombre $subdirectorio

  if [ "$subdirectorio" != "" ]; then
    subdirectorio=$subdirectorio/
  fi

  drush dl --drupal-project-rename=$nombre

  if [ -d "/Applications/XAMPP/xamppfiles/htdocs/$subdirectorio" ]; then echo '';
  else mkdir "/Applications/XAMPP/xamppfiles/htdocs/$subdirectorio"; fi

  mv "/Applications/XAMPP/xamppfiles/htdocs/$nombre" "/Applications/XAMPP/xamppfiles/htdocs/$subdirectorio$nombre"

  sh /Applications/XAMPP/xamppfiles/xampp restart
  cd "/Applications/XAMPP/xamppfiles/htdocs/$subdirectorio$nombre/sites/default/"
  mkdir ../../private
  chmod 777 ../../private
  mkdir files
  chmod 777 files
  cp default.settings.php settings.php
  chmod 777 settings.php

  primera_parte='$databases = array (
    "default" =>
    array (
      "default" =>
      array (
        "database" => "'

  segunda_parte=$nombre'",
  "username" => "root",
  "password" => "",
  "host" => "172.0.0.1",
  "port" => "",
  "driver" => "mysql",
  "prefix" => "",
  ),
  ),
  );'

  #/Applications/xampp/xamppfiles/bin/mysql --user=root --password=qFJDGqhPTzMxbBIA -e "CREATE DATABASE $nombre"

  echo $primera_parte$segunda_parte >> settings.php
  chmod 444 settings.php

  echo -n 'FIN ejecución (enter)'
  read blank
elif [ "$option" == "3" ]; then
  echo -n 'Escribe el nombre maquina del módulo'
  read nombre
  echo -n 'Escribe el alias de la web'
  read sa
  drush @$sa dl $nombre -y
  drush @$sa en $nombre -y
  echo -n 'FIN ejecución (enter)'
  read blank
elif [ "$option" == "2" ]; then
  echo -n 'Escribe el alias de la web'
  read sa
  drush @$sa cc all
  echo -n 'FIN ejecución (enter)'
  read blank
elif [ "$option" == "5" ]; then
  open /Applications/atom.app /Users/jose/custom_scripts/drush_script.sh
elif [ "$option" == "6" ]; then
  sh /Applications/XAMPP/xamppfiles/xampp restart
elif [ "$option" == "7" ]; then
  echo -n 'Escribe el nombre de la nueva web'
  read nombre
  echo -n 'Escribe el nombre del subdirectorio - dev por defecto'
  read subdirectorio
  edit_files $nombre $subdirectorio
elif [ "$option" == "0" ]; then
  exit 0
fi


done
