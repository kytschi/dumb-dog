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

Copy the module located in the compiled folder to your PHP modules folder on your server.
https://github.com/kytschi/dumb-dog/blob/main/compiled

Now create an ini to load the module in your PHP modules ini folder.
```
; configuration for php to enable dumb dog
extension=dumbdog.so
```

You can also just create the ini and point the `extension` to the folder with the `dumbdog.so`.

**And don't forget to restart your webserver.**

If you have issues with the module you may need to compile it yourself. 
See https://docs.zephir-lang.com/0.12/en/installation for more information on installing Zephir and compiling.

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

Generate a random key for the encryption part of Dumb Dog, can use a command like the following and save that to the
`encryption` variable in the `dumbdog.json` file.

```
openssl rand -base64 32
```

Next point your webserver to the `public` folder of Dumb Dog where the `index.php` is located.

Make sure that the `public/website/files` folder has permission to write to by your webserver's user. This folder is used to store any files you upload via Dumb Dog.

**NOTE**
If your using a template engine please make sure that the `cache` folder has write permissions by the webserver user.

That's it, now you can access Dumb Dog via whatever url you've setup for the project by adding `/dumb-dog` to the url.

Default login is username `dumbdog` and password is `woofwoof`.

**DONT FORGET TO CREATE YOUR OWN USER AND DELETE THE DEFAULT ONE OR CHANGE ITS PASSWORD!**

## Getting started

Once the module is installed and you've got your webserver all setup pointing to the `index.php` your ready to start building.

The front-end website is held in the `public\website` folder. This is where you'll keep all your `templates` and your `themes`.

Have a look at the `example` website in the repository to show you a way of building using Dumb Dog.

**NOW, HAVE FUN!**

## Template engines

Dumb Dog does support some of the major templating engines out there should you want to use. Personally I'd just stick with PHP "templates" over using an engine as it's much much faster. But people love to complicate things ;-)

### Twig

See [Twig installation](https://twig.symfony.com/doc/3.x/installation.html) on how to install Twig into your project/website.

Now in your index.php define the Twig template engine and include it in Dumb Dog.

```php
// Include the autoload file.
require_once "../vendor/autoload.php";

// Define the template folder for Twig.
$loader = new \Twig\Loader\FilesystemLoader("./website");

// Define the Twig engine.
$engine = new \Twig\Environment(
        $loader,
        [
            "cache" => "../cache"
        ]
);
```

### Smarty

See [Smarty installation](https://smarty-php.github.io/smarty/4.x/getting-started/) on how to install Smarty into your project/website.

Now in your index.php define the Smarty template engine and include it in Dumb Dog.

```php
// Include the autoload file.
require_once "../vendor/autoload.php";
// Define the Smarty template engine.
$engine = new Smarty();
// Set the Template folder.
$engine->setTemplateDir('./website');
// Set the compile folder.
$engine->setCompileDir('../cache');
// Set Cache folder if you like, speeds stuff up a lot.
$engine->setCacheDir('../cache');
```

### Volt

See [Phalcon installation](https://docs.phalcon.io/4.0/en/volt) on how to install Volt into your project/website.

Now in your index.php define the Volt template engine and include it in Dumb Dog.
```php
$engine = new Phalcon\Mvc\View\Engine\Volt\Compiler();
$engine->setOptions(
    [
        'path' => '../cache/'
    ]
);
```

### Blade

See [Blade installation](https://github.com/EFTEC/BladeOne) on how to install Blade into your project/website.

Now in your index.php define the Blade template engine and include it in Dumb Dog.
```php
$engine = new eftec\bladeone\BladeOne(
    './website',
    '../cache',
    eftec\bladeone\BladeOne::MODE_DEBUG
);
```

### Plates

See [Plates installation](https://platesphp.com/getting-started/installation/) on how to install Plates into your project/website.

Now in your index.php define the Plates template engine and include it in Dumb Dog.
```php
$engine = new League\Plates\Engine('./website');
```

### Mustache

See [Mustache installation](https://github.com/bobthecow/mustache.php) on how to install Mustache into your project/website.

Now in your index.php define the Mustache template engine and include it in Dumb Dog.
```php
$engine = new Mustache_Engine([
    'cache' => '../cache',
    'loader' => new Mustache_Loader_FilesystemLoader(dirname(__FILE__) . '/website')
]);
```

## More information

I've knocked up a demo website running the `example` in this repository and there's more information located there to help you get going and under Dumb Dog.\
[See it live](https://dumb-dog.kytschi.com)

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

Tagify\
https://github.com/yairEO/tagify