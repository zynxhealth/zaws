#! /bin/bash
cp Gemfile.lock.linux Gemfile.lock
git add -A
git commit -m"$1"
git push
cp Gemfile.lock.windows Gemfile.lock
