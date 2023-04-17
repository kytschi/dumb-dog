/**
 * Dumb Dog controller helper
 *
 * @package     DumbDog\Controllers\Controller
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
namespace DumbDog\Controllers;

use DumbDog\Exceptions\ValidationException;

class Controller
{   
    protected system_uuid = "00000000-0000-0000-0000-000000000000";

    public function consoleLogError(string message)
    {
        return "<script type='text/javascript'>console.log('DUMB DOG ERROR:', '" . str_replace(["\n", "\r\n"], "", strip_tags(message)) . "');</script>";
    }

    public function deletedState(string message)
    {
        return "<div class='deleted alert'><span>deleted</span></div>";
    }

    public function getPageId(string path)
    {
        var splits;

        let splits = explode("/", path);
        return array_pop(splits);
    }

    public function getUserId()
    {
        return this->system_uuid;
    }

    public function missingRequired(string message = "Missing required fields")
    {
        return "<div class='error box wfull'>
        <div class='box-title'>
            <span>double check your inputs</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function redirect(string url)
    {
        header("Location: " . url);
        die();
    }

    public function saveFailed(string message)
    {
        return "<div class='error box wfull'>
        <div class='box-title'>
            <span>save error</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function saveSuccess(string message)
    {
        return "<div class='success box wfull'>
        <div class='box-title'>
            <span>save all done</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function validate(array data, array checks)
    {
        var iLoop = 0;
        while (iLoop < count(checks)) {
            if (!isset(data[checks[iLoop]])) {
                return false;
            }
            let iLoop = iLoop + 1;
        }
        return true;
    }
}