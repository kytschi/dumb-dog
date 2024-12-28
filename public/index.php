<?php

/**
 * DumbDog example index
 *
 * @author      Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 */

use DumbDog\DumbDog;
use DumbDog\Exceptions\Exception;

try {
    /**
     * No template engine.
     */
    $engine = null;

    /**
     * No libs.
     */
    $libs = null;

    // Include the autoload file when using composer.
    //require_once "../vendor/autoload.php";

    /**
     * Twig template engine.
     */
    /*
    // Define the template folder for Twig.
    $loader = new \Twig\Loader\FilesystemLoader("./website");

    // Define the Twig engine.
    $engine = new \Twig\Environment(
        $loader,
        [
            "cache" => "../cache"
        ]
    );*/

    /**
     * Smarty template engine.
     */
    /*
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
    */

    /**
     * Volt template engine.
     */
    /*$engine = new Phalcon\Mvc\View\Engine\Volt\Compiler();
    $engine->setOptions(
        [
            'path' => '../cache/'
        ]
    );*/

    /**
     * Blade template engine.
     */
    /*$engine = new eftec\bladeone\BladeOne(
        './website',
        '../cache',
        eftec\bladeone\BladeOne::MODE_DEBUG
    );*/

    /**
     * Plates template engine.
     */
    //$engine = new League\Plates\Engine('./website');

    /**
     * Mustache template engine.
     */
    /*$engine = new Mustache_Engine([
        'cache' => '../cache',
        'loader' => new Mustache_Loader_FilesystemLoader(dirname(__FILE__) . '/website')
    ]);*/
    new DumbDog("../.dumbdog.json", $libs, $engine);
} catch (\Exception $err) {
    (new Exception($err->getMessage()))->fatal();
}
