#!/bin/bash

read -p "Project Name (slug): " DOMAIN_NAME
if [ ! $DOMAIN_NAME ]; then
  printf "Error: Project Name is Required! \nExit\n"
  exit
fi

read -p "PHP Version (Default - 7.4): " PHP_VERSION

if [ ! $PHP_VERSION ]; then
  PHP_VERSION="7.4"
fi

cat >.env <<EOF
IP=127.0.0.1
APP_NAME=$DOMAIN_NAME
DOMAIN=$DOMAIN_NAME.local
DB_HOST=mysql
DB_NAME=$DOMAIN_NAME
DB_ROOT_PASSWORD=123456
DB_USER=$DOMAIN_NAME
DB_PASSWORD=123456
DB_TABLE_PREFIX=wp_
EOF

USER=$(whoami)
sudo chown -R $USER: .env

source ".env"

sudo -- sh -c -e "echo '127.0.0.1  ${DOMAIN_NAME}.local' >> /private/etc/hosts"

#cat /private/etc/hosts \;

echo
echo "Enable SSL?"
echo "1. Yes"
echo "2. No"
read -p "Enter 1 or 2 (Default - 1) : " ENABLE_SSL

if [ ! $ENABLE_SSL ]; then
  ENABLE_SSL=1
fi

if [ 1 == $ENABLE_SSL ]; then
  mkcert -install "${DOMAIN_NAME}.local"
  mkdir -p certs
  find . -type f -name "*.pem" -exec mv {} certs \;
fi

docker-compose up

echo

if [ 1 == $ENABLE_SSL ]; then
  echo "https://$DOMAIN_NAME.local/"
  exit
fi

echo "http://$DOMAIN_NAME.local/"
exit
