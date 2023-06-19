#!/bin/bash
if [ -n "$1" ]; then
    cfg=$1
else
    cfg="../dumbdog.json"
fi

php -r "use DumbDog\DumbDog;new DumbDog('$cfg', null, true);";