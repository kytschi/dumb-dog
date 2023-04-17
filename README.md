# Dumb Dog
The dumbest dog on the CMS block you'll ever see!

## Some screens of it
![Snapshot](https://github.com/kytschi/dumb-dog/blob/main/screen-1.jpg)
![Snapshot](https://github.com/kytschi/dumb-dog/blob/main/screen-2.jpg)
![Snapshot](https://github.com/kytschi/dumb-dog/blob/main/screen-3.jpg)

## Requirements

* PHP 7+
* Your favourite SQL database
* Webserver (Nginx recommended)

## Installation

Download or clone the repository.

Copy the module located in the ext/modules folder to your PHP modules folder on your server.
https://github.com/kytschi/dumb-dog/blob/main/ext/modules/dumbdog.so

Now create an ini to load the module in your PHP modules ini folder.
```
; configuration for php to enable dumb dog
extension=dumbdog.so
```

You can also just create the ini and point the `extension` to the folder with the `dumbdog.so`.

And don't forget to restart your webserver.

Create yourself a database and run the SQL located in the setup folder.
https://github.com/kytschi/dumb-dog/blob/main/setup/database.sql

Once the database is setup and the SQL installed, go to the `index.php` in the public folder and configure the database connection.

```
/**
 * database => the database cfg.
 */
new DumbDog(
    [
        'database' => [
            'type' => 'mysql',
            'host' => 'localhost',
            'port' => '3306',
            'db' => 'dumb_dog',
            'username' => 'dumbdog',
            'password' => 'dumbdog'
        ]
    ]
);
```

That's it, now you can access Dumb Dog via whatever url you've setup for the project by adding `/dumb-dog` to the url.

Default login is username `dumbdog` and password is `woofwoof`.

**DONT FORGET TO CREATE YOUR OWN USER AND DELETE THE DEFAULT ONE OR CHANGE ITS PASSWORD!**

## Credits
Many thanks to laimuilin18 for the art work.\
https://www.vecteezy.com/members/laimuilin18

Moon Flower font\
FONT BY DENISE BENTULAN (c) 2013\
http://deathmunkey.deviantart.com

Yummy Cupcakes font\
http://bythebutterfly.com

Icons from\
https://icons8.com

Jquery\
https://jquery.com/

Trumbowyg\
https://alex-d.github.io/Trumbowyg/