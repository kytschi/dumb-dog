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
} catch (\Exception $err) {
    (new Exception($err->getMessage()))->fatal();
}