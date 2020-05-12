#!/bin/bash

mkdir -p /root/.ssh
ssh-keyscan -H "$2" >>/root/.ssh/known_hosts

echo $'\n' "------ CHECKING FOR CONFIGURATION KEYS! ----------------" $'\n'

if [ -z "$DEPLOY_KEY" ]; then
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
fi

if [ -z "$USER" ]; then
	echo $'\n' "------ USER IS NOT SET YET! ----------------" $'\n'
	exit 1
fi

if [ -z "$HOST" ]; then
	echo $'\n' "------ HOST IS NOT SET YET! ----------------" $'\n'
	exit 1
fi

if [ -z "$PATH" ]; then
	echo $'\n' "------ PATH IS NOT SET YET! ----------------" $'\n'
	exit 1
fi

#deploy ssh key
printf '%b\n' "$DEPLOY_KEY" >/root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'


#Test the connection
ssh -i /root/.ssh/id_rsa -q $USER@$HOST
if [ $? -eq 0 ]; then
	echo $'\n' "------ CONNECTION SUCCESSFUL! -----------------------" $'\n'
else
	echo $'\n' "------ CONNECTION FAILED! -----------------------" $'\n'
	exit 1
fi

#PULL
ssh -i /root/.ssh/id_rsa -t $USER@$HOST "git --git-dir=$PATH pull"
if [ $? -ne 0 ]; then
	echo $'\n' "------ UNABLE TO PULL CODE! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ CODE PULLED! -----------------------" $'\n'

#composer
ssh -i /root/.ssh/id_rsa -t $USER@$HOST "composer install -q -n -d=$PATH"
if [ $? -ne 0 ]; then
	echo $'\n' "------ COMPOSER INSTALL! FAILED! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ COMPOSER INSTALL! -----------------------" $'\n'

#composer dump autoload
ssh -i /root/.ssh/id_rsa -t $USER@$HOST "composer dump-autoload -o -q -n -d=$PATH"
echo $'\n' "------ COMPOSER INSTALL! -----------------------" $'\n'

#config cache
ssh -i /root/.ssh/id_rsa -t $USER@$HOST "php $PATH/artisan config:cache"
if [ $? -ne 0 ]; then
	echo $'\n' "------ CACHE CONFIG FAILED! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ CONFIG CACHE CLEARED AND UPDATED! -----------------------" $'\n'

#run migrations
ssh -i /root/.ssh/id_rsa -t $USER@$HOST "php $PATH/artisan migrate"
if [ $? -ne 0 ]; then
	echo $'\n' "------ MIGRATIONS FAILED! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ MIGRATIONS COMPLETED! -----------------------" $'\n'

echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
exit 0
