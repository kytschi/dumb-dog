#!/bin/bash
version="8.2"
printf "Building Dumb Dog for PHP $version\n"
./vendor/bin/zephir fullclean
./vendor/bin/zephir build
cp ext/modules/dumbdog.so compiled/php$version-dumbdog.so
sudo service php$version-fpm restart
echo "Dumb Dog build complete"