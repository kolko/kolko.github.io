#!/bin/bash

mkdir -p ./opencarbon_kolko
for page in ./data/blog/*; do
    cp -a "$page" ./opencarbon_kolko/${page##*/}.txt
    echo '{{indexmenu_n>1000}}' > ./opencarbon_kolko/start.txt
done

echo "<html><body><h1>Статьи:</h1>" > ./index.html
for page in ./data/blog/*; do
    echo "<p><a href='https://kolko.github.io/data/blog/${page##*/}'>${page##*/}</a>" >> ./index.html
done