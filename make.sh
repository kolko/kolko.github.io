#!/bin/bash

mkdir -p ./opencarbon_kolko
for page in ./data/blog/*; do
    cp -a "$page" ./opencarbon_kolko/${page##*/}
done