<?php
/**
 * DumbDog example index
 *
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */
use DumbDog\DumbDog;
use DumbDog\Exceptions\Exception;

try {
    /**
     * I'm needed for the session handling for logins etc.
     */
    if (session_status() === PHP_SESSION_NONE) {
        session_name("dd");
        session_start();
    }
    /**
     * No template engine.
     */
    $engine = null;

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
    new DumbDog("../dumbdog.json", $engine);
} catch (\Exception $err) {
    (new Exception($err->getMessage()))->fatal();
}
