#! /bin/bash

sudo apt-get update 
sudo apt-get install -y apache2 php
sudo cd /var/www/html
sudo rm index.html -f
sudo rm index.php -f
sudo wget https://storage.googleapis.com/networking101-lab/index.php
sudo META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
sudo REGION=`echo "$META_REGION_STRING" | awk -F/ '{print $4}'`
sudo sed -i "s|region-here|$REGION|" index.php
