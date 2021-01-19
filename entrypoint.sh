#!/bin/bash

echo $'\n' "------ CHECKING FOR CONFIGURATION KEYS! ----------------" $'\n'

if [ -z "$DEPLOY_KEY" ] 
then 
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
fi

if [ -z "$DEPLOY_USER" ]; then
	echo $'\n' "------ DEPLOY_USER IS NOT SET YET! ----------------" $'\n'
	exit 1
fi

if [ -z "$DEPLOY_HOST" ]; then
	echo $'\n' "------ DEPLOY_HOST IS NOT SET YET! ----------------" $'\n'
	exit 1
fi

if [ -z "$DEPLOY_PATH" ]; then
	echo $'\n' "------ DEPLOY_PATH IS NOT SET YET! ----------------" $'\n'
	exit 1
fi

echo $'\n' "------ DEPLOYMENT KEYS CHECK COMPLETE ----------------" $'\n'


#update known hosts
mkdir -p /root/.ssh
ssh-keyscan -H "$DEPLOY_HOST" >>/root/.ssh/known_hosts

#deploy ssh key
printf '%b\n' "$DEPLOY_KEY" >/root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

echo $'\n' "------ SSH KEY DEPLOYED SUCCESSFUL! ---------------------" $'\n'

#Test the connection
ssh -q -i /root/.ssh/id_rsa $DEPLOY_USER@$DEPLOY_HOST
if [ $? -eq 0 ]; then
	echo $'\n' "------ CONNECTION TEST SUCCESSFUL! -----------------------" $'\n'
else
	echo $'\n' "------ CONNECTION TEST FAILED! -----------------------" $'\n'
	exit 1
fi


#PULL
ssh -i /root/.ssh/id_rsa -t $DEPLOY_USER@$DEPLOY_HOST "cd $DEPLOY_PATH && git pull"
if [ $? -ne 0 ]; then
	echo $'\n' "------ UNABLE TO PULL CODE! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ CODE PULLED! -----------------------" $'\n'

#composer
ssh -i /root/.ssh/id_rsa -t $DEPLOY_USER@$DEPLOY_HOST "composer install -q -n -d $DEPLOY_PATH"
if [ $? -ne 0 ]; then
	echo $'\n' "------ COMPOSER INSTALL! FAILED! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ COMPOSER INSTALL SUCCESSFUL! -----------------------" $'\n'

#composer dump autoload
ssh -i /root/.ssh/id_rsa -t $DEPLOY_USER@$DEPLOY_HOST "composer dump-autoload -o -q -n -d $DEPLOY_PATH"
echo $'\n' "------ COMPOSER DUMPAUTOLOAD SUCCESSFUL! -----------------------" $'\n'


#config cache
ssh -i /root/.ssh/id_rsa -t $DEPLOY_USER@$DEPLOY_HOST "cd $DEPLOY_PATH && php artisan config:cache"
if [ $? -ne 0 ]; then
	echo $'\n' "------ CACHE CONFIG FAILED! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ CONFIG CACHE CLEARED AND UPDATED! -----------------------" $'\n'

#routes cache
ssh -i /root/.ssh/id_rsa -t $DEPLOY_USER@$DEPLOY_HOST "cd $DEPLOY_PATH && php artisan route:cache"
if [ $? -ne 0 ]; then
	echo $'\n' "------ ROUTES CACHE FAILED! -----------------------" $'\n'
	exit 1
fi
echo $'\n' "------ ROUTES CACHE SUCCESS! -----------------------" $'\n'

#run migrations
ssh -i /root/.ssh/id_rsa -t $DEPLOY_USER@$DEPLOY_HOST "cd $DEPLOY_PATH && php artisan migrate"
if [ $? -ne 0 ]; then
	echo $'\n' "------ MIGRATIONS FAILED! -----------------------" $'\n'
	exit 1
fi

echo $'\n' "------ MIGRATIONS COMPLETED! -----------------------" $'\n'

echo $'\n' "------ CONGRATULATIONS! THE DEPLOYMENT WAS SUCCESSFUL!!! ---------" $'\n'


exit 0;