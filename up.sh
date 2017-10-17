#!/bin/bash

cd /root/kolko.github.io
git pull origin master
chown -R apache:apache /root/kolko.github.io/opencarbon_kolko/
for f in /root/kolko.github.io/opencarbon_kolko/*; do
 cp -a $f /var/www/html/data/pages/участники/kolko/${f##*/}
done

