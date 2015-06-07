#!/bin/bash

set -o errexit -o nounset

rev=$(git rev-parse --short HEAD)

cd website/_site

git init
git config user.name "Nicholas E. Rabenau"
git config user.email "nerab@gmx.at"

git remote add upstream "https://$GH_TOKEN@github.com/nerab/dropcaster.git"
git fetch upstream
git reset upstream/gh-pages

# echo "dropcaster.net" > CNAME

touch .

git add -A .
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages
