#!/bin/bash
if [ -n "$1" ]; then
    cfg=$1
else
    cfg="../dumbdog.json"
fi
php -r "use DumbDog\DumbDog;$dd = new DumbDog('$cfg', null, null, true);$dd->runMigrations();";