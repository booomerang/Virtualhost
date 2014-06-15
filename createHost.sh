#!/bin/bash
# Скрипт создает конф. файл для виртуального хоста
# Принимает 2 параметра
# 1-ый - название файла + хоста
# 2-ой - путь до папки проекта
# Пример запуска: ./createHost.sh medvedica /home/alex/htdocs/medvedica

# TODO: ошибку не заполненных параметров!

VERSION=$(apache2 -v | grep Apache.*); # get apache version
VERS=${VERSION#S*/}; # get version but not clear
VER=${VERS:0:5}; # get clear version
#echo $VERSION;
echo $VER;

# Apache version 2.4.7
# split each digit
D1=${VER%%.*};
D2=${VER%.*};
D2=${D2#*.};
D3=${VER##*.};

echo $D1;
echo $D2;
echo $D3;

if [ "$D1$D2$D3" -gt '220' ]
then
    echo "Greater than 2 version"

    fileName=$1;

    if [ "$2" != "" ]
    then

    	path=$2;
    	len=${#path}; #Получаем длину строки
    	lastChar=${path:$len-1}; #Получаем последний символ

		if [ $lastChar != '/' ]
        then
            path="$path/";
        fi

STR="<VirtualHost *:80>
    ServerName $fileName.local
    ServerAlias www.$fileName.local
    DocumentRoot \"$path\"
        <Directory />
            Require all granted
            #AllowOverride FileInfo
            Options Indexes FollowSymLinks Includes ExecCGI
            AllowOverride All
            Order allow,deny
            Allow from all
        </Directory>
</VirtualHost>";

    else

STR="<VirtualHost *:80>
    ServerName $fileName.local
    ServerAlias www.$fileName.local
    DocumentRoot \"$(pwd)\"
        <Directory />
            Require all granted
            #AllowOverride FileInfo
            Options Indexes FollowSymLinks Includes ExecCGI
            AllowOverride All
            Order allow,deny
            Allow from all
        </Directory>
</VirtualHost>";

    fi
        echo "$STR" > /etc/apache2/sites-available/$fileName.conf;
        echo $(a2ensite $fileName);
        echo $(/etc/init.d/apache2 restart);

        echo "127.0.0.1	$fileName.local www.$fileName.local" > tempfile;
        cat tempfile /etc/hosts > tempHostFile;
        cat tempHostFile > /etc/hosts;
        rm tempfile;
        rm tempHostFile;
else
    echo "Not greater than 2 version"
fi
