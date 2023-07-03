#!/bin/bash
if [ -n "$1" ]; then
    cfg=$1
else
    cfg="../dumbdog.json"
fi
dir="$(dirname "$0")"
php -r "use DumbDog\DumbDog;new DumbDog('$cfg', null, '$dir');";