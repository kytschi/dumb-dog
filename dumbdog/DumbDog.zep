/**
 * Dumb Dog - A different type of CMS
 *
 * @package     DumbDog\DumbDog
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1 alpha
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
 namespace DumbDog;

use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;
use DumbDog\Controllers\Pages;

class DumbDog
{
    private cfg = [];
    private version = "0.0.1 alpha";

    private routes = [
        "/dumb-dog"
    ];

    public function __construct(array cfg = [])
    {
        let this->cfg = cfg;
        define("VERSION", this->version);

        var parsed, path, controller, output, code;
        let parsed = parse_url(_SERVER["REQUEST_URI"]);
        let path = "/" . trim(parsed["path"], "/");

        let code = 200;

        if (strpos(path, "/dumb-dog") !== false) {
            let path = "/" . ltrim(parsed["path"], "/dumb-dog/");
            if (path == "/") {
                let output = this->dashboard();
            } elseif (strpos(path, "/pages/add") !== false) {
                let controller = new Pages(cfg);
                let output = controller->add();
            } elseif (strpos(path, "/pages") !== false) {
                let controller = new Pages(cfg);
                let output = controller->index();
            } else {
                let code = 404;
                let output = this->notFound();
            }
            this->ddHead(code);
            echo output;
            this->ddFooter();
            //this->login();
        } else {
            echo "front end";
        }
    }
    
    private function dashboard()
    {
        return "<p>Dashboard</p>";
    }

    private function ddFooter()
    {
        var javascript;
        let javascript = new Javascript();

        echo "</main><div id='quick-menu' style='display: none'>
            <a href='/dumb-dog/pages/add' class='button' title='Add a page'>
                <img src='/assets/add-page.png'>
            </a>
            <a href='/dumb-dog/pages' class='button' title='Managing the pages'>
                <img src='/assets/pages.png'>
            </a>
        </div>
        <div id='quick-menu-button' onclick='showQuickMenu()'>
            <div class='button'>
                <img src='/assets/dumbdog.png'>
            </div>
        </div></body>" . javascript->common() . "</html>";
    }

    private function ddHead(int code = 200)
    {
        if (code == 404) {
            header("HTTP/1.1 404 Not Found");
        }

        var head;
        let head = new Head(this->cfg);

        echo "<!DOCTYPE html><html lang='en'>" . head->build() . "<body><div id='bk'><img src='/assets/bk.png'></div><main>";
    }

    private function login()
    {
        return "
        <div class='box'>
            <div class='box-title'>
                <img src='/assets/dumbdog.png'>
                <span>Welcome to Dumb Dog</span>
            </div>
            <form>
                <div class='box-body'>
                    <div class='input-group'>
                        <span>username</span>
                        <input type='text' placeholder='your username doopy'>
                    </div>
                    <div class='input-group'>
                        <span>password</span>
                        <input type='text' placeholder='your secret password...sssshhh!'>
                    </div>
                </div>
                <div class='box-footer'>
                    <button type='submit' name='go'>login</button>
                </div>
            </form>
        </div>
        ";
    }

    private function notFound(bool backend = true)
    {
        if (backend) {
            return "
            <div class='box'>
                <div class='box-title'>
                    <img src='/assets/dumbdog.png'>
                    <span>dang it!</span>
                </div>
                <div class='box-body'>
                    <h1>page is not found</h1>
                </div>
                <div class='box-footer'>
                    <button type='button'>back</button>
                </div>
            </div>
            ";
        } else {
            return "not found";
        }
    }
}