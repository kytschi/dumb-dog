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

Once the database is setup and the SQL installed, go to the `dumbdog-example.json` in the root folder and copy it to a file called `dumbdog.json`. This is where you can configure Dumb Dog. Now set the database connection details to that of your newly created database.

```
"database":
{
    "type": "mysql",
    "host": "localhost",
    "port": "3306",
    "db": "dumb_dog",
    "username": "dumbdog",
    "password": "dumbdog"
}
```

Next point your webserver to the `public` folder of Dumb Dog where the `index.php` is located.

Make sure that the `public/website/files` folder has permission to write to by your webserver's user. This folder is used to store any files you upload via Dumb Dog.

That's it, now you can access Dumb Dog via whatever url you've setup for the project by adding `/dumb-dog` to the url.

Default login is username `dumbdog` and password is `woofwoof`.

**DONT FORGET TO CREATE YOUR OWN USER AND DELETE THE DEFAULT ONE OR CHANGE ITS PASSWORD!**

## Getting started

Once the module is installed and you've got your webserver all setup pointing to the `index.php` your ready to start building.

The front-end website is held in the `public\website` folder. This is where you'll keep all your `templates` and your `themes`.

Have a look at the `example` website in the repository to show you a way of building using Dumb Dog.

**NOW, HAVE FUN!**

## More information

I've knocked up a demo website running the `example` in this repository and there's more information located there to help you get going and under Dumb Dog.\
https://dumbdog.kytschi.com

## Credits
Many thanks to laimuilin18 for the art work. They make the app mate!\
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