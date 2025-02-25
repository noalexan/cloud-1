#!/bin/bash

if [ -f ".env" ]; then
  echo ".env already exist"
  printf "overwrite? (y/N) "; read -n 1 DoIOverwrite; printf "\n"

  if [ "${DoIOverwrite,,}" != "y" ]; then
    exit
  fi

fi

cp .env.example .env

printf "DigitalOcean Token: " && read token
printf "Domain name: " && read domain_name
printf "Administrator email: " && read cb_email
printf "Database :\n"
printf "    host: " && read host
printf "    name: " && read db
printf "    user: " && read user
passwd="$(openssl rand -hex 32)"

sed -i "s/^DIGITALOCEAN_TOKEN:$/DIGITALOCEAN_TOKEN: \"$token\"/g; s/^DOMAIN:$/DOMAIN: \"$domain_name\"/g; s/^CERTBOT_EMAIL:$/CERTBOT_EMAIL: \"$cb_email\"/g; s/^MYSQL_HOST:$/MYSQL_HOST: \"$host\"/g; s/^MYSQL_DATABASE:$/MYSQL_DATABASE: \"$db\"/g; s/^MYSQL_USER:$/MYSQL_USER: \"$user\"/g; s/^MYSQL_PASSWORD:$/MYSQL_PASSWORD: \"$passwd\"/g" .env

printf "DigitalOcean:\n  hosts:\n" > inventory.yml

curl -sSL -H "Authorization: Bearer $token" 'https://api.digitalocean.com/v2/droplets' | jq -r '.droplets[] | "\(.id) \(.name) \(.networks.v4[] | select(.type == "public") | .ip_address)"' | \
while read -r id name ip_address; do
  printf "    $name:\n      ansible_host: $ip_address\n" >> inventory.yml
done

printf "  vars:\n    ansible_user: root\n" >> inventory.yml
