#!/bin/bash
versions=("7.4" "8.0" "8.1" "8.2")
for version in ${versions[@]}; do
    printf " Building Dumb Dog for PHP $version\n"
    if [ -f "/usr/bin/php$version" ]; then
        sudo update-alternatives --set php /usr/bin/php$version
        sudo update-alternatives --set php-config /usr/bin/php-config$version
        sudo update-alternatives --set phpize /usr/bin/phpize$version
        rm -R vendor
        rm composer.lock
        composer install
        ./vendor/bin/zephir fullclean
        ./vendor/bin/zephir build
        cp ext/modules/dumbdog.so compiled/php$version-dumbdog.so
        sudo service php$version-fpm restart
    else
        echo " PHP $version not installed\n"
    fi
done
echo " Dumb Dog build complete"