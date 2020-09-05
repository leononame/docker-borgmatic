#!/bin/bash

mkdir -p data/{borgmatic.d,ssh}

echo "Generate a configuration"
read -p "Name: " NAME
read -s -p "Borg Passphrase: " PASSPHRASE
echo ""
read -p "Repo (user@host.example.com:repo): " REPO
read -p "[H]ourly/[d]aily: " HOURLY
read -p "Folder [/mnt/source/${NAME}]: " FOLDER

# if no crontab, generate everything
if [[ ! -f data/borgmatic.d/crontab.txt ]]; then
	rm -f .env
	read -p "Email: " MAIL
	read -p "TZ [Europe/Berlin]: " USERTIME
	read -p "Mail Host: " MAIL_RELAY_HOST
	read -p "Mail Port: " MAIL_PORT
	read -p "Mail From: " MAIL_FROM
	read -p "Mail User: " MAIL_USER
	read -s -p "Mail Password: " MAIL_PASSWORD
	echo ""
	ssh-keygen -t ed25519 -f data/ssh/borg -N ""
	echo "MAILTO=${MAIL}" > data/borgmatic.d/crontab.txt
	echo "TZ=${USERTIME:-Europe/Berlin}" >> .env
	echo "BORG_RSH=ssh -i ~/.ssh/borg" >> .env
	echo "MAIL_RELAY_HOST=${MAIL_RELAY_HOST}" >> .env
	echo "MAIL_PORT=${MAIL_PORT}" >> .env
	echo "MAIL_FROM=${MAIL_FROM}" >> .env
	echo "MAIL_USER=${MAIL_USER}" >> .env
	echo "MAIL_PASSWORD=${MAIL_PASSWORD}" >> .env
fi

if [[ "$HOURLY" == "d" ]]; then
	echo "$((RANDOM % 60)) 3 * * * backup bmr ${NAME}" >> data/borgmatic.d/crontab.txt
else
	echo "$((RANDOM % 60)) * * * * backup bmr ${NAME}" >> data/borgmatic.d/crontab.txt
fi

UPPERNAME=$(printf '%s\n' "$NAME" | awk '{ print toupper($0) }')
echo "BORG_PASSPHRASE_${UPPERNAME}=${PASSPHRASE}" >> .env

cat > data/borgmatic.d/${NAME}.yaml << EOF
location:
  source_directories:
    - ${FOLDER:-/mnt/source/${NAME}}
  repositories:
    - ${REPO}

storage:
  compression: lz4
  archive_name_format: "${NAME}-{now}"

retention:
  keep_hourly: 24
  keep_daily: 7
  keep_weekly: 4
  keep_monthly: 12
  keep_yearly: 10
  prefix: "${NAME}-"

consistency:
  checks:
    - repository
    - archives
  check_last: 10
  prefix: "${NAME}-"

hooks:
  on_error:
    - echo "Error while creating a backup for ${NAME}."

EOF
