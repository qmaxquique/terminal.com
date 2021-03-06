#!/bin/bash
# Script to deploy Wallabag at Terminal.com

INSTALL_PATH="/var/www"

# Includes
wget https://raw.githubusercontent.com/terminalcloud/apps/master/terlib.sh
source terlib.sh || (echo "cannot get the includes"; exit -1)

install(){
	# Basics
	pkg_update
	system_cleanup
	basics_install

	# Procedure: 
	php5_install
	mysql_install sugArfr33
	cd $INSTALL_PATH
	wget -q https://raw.githubusercontent.com/terminalcloud/apps/master/others/SugarCE.zip
	unzip SugarCE.zip
	rm SugarCE.zip
	chown -R www-data:www-data SugarCE
	apache_install
	apache_default_vhost sugarcrm.conf $INSTALL_PATH/SugarCE
	sed -i 's/upload_max_filesize\ \=\ 2M/upload_max_filesize\ \=\ 20M/g' /etc/php5/apache2/php.ini
	sed -i 's/post_max_size\ \=\ 8M/post_max_size\ \=\ 24M/g' /etc/php5/apache2/php.ini
	echo "*    *    *    *    *     cd /var/www/sugarcrm; php -f cron.php > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
}

show(){
	# Get the startup script
	wget -q -N https://raw.githubusercontent.com/terminalcloud/apps/master/others/sugarcrm_hooks.sh
	mkdir -p /CL/hooks/
	mv sugarcrm_hooks.sh /CL/hooks/startup.sh
	# Execute startup script by first to get the common files
	chmod 777 /CL/hooks/startup.sh && /CL/hooks/startup.sh
}

if [[ -z $1 ]]; then
	install && show
elif [[ $1 == "show" ]]; then 
	show
else
	echo "unknown parameter specified"
fi