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

use DumbDog\Controllers\Database;
use DumbDog\Controllers\Pages;
use DumbDog\Controllers\Templates;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;

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

        var parsed, path, controller, output, code, backend = false, err;
        let parsed = parse_url(_SERVER["REQUEST_URI"]);
        let path = "/" . trim(parsed["path"], "/");

        let code = 200;

        try {
            if (strpos(path, "/dumb-dog") !== false) {
                let backend = true;
                let path = "/" . ltrim(parsed["path"], "/dumb-dog/");
                if (path == "/") {
                    let output = this->dashboard();
                } elseif (strpos(path, "/pages/add") !== false) {
                    let controller = new Pages(cfg);
                    let output = controller->add();
                } elseif (strpos(path, "/pages/edit") !== false) {
                    let controller = new Pages(cfg);
                    let output = controller->edit(path);
                } elseif (strpos(path, "/pages") !== false) {
                    let controller = new Pages(cfg);
                    let output = controller->index();
                } elseif (strpos(path, "/templates/add") !== false) {
                    let controller = new Templates(cfg);
                    let output = controller->add();
                } elseif (strpos(path, "/templates/edit") !== false) {
                    let controller = new Templates(cfg);
                    let output = controller->edit(path);
                } elseif (strpos(path, "/templates") !== false) {
                    let controller = new Templates(cfg);
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
                var database, data = [], page;

                let database = new Database(this->cfg);
                let data["url"] = path;

                let page = database->get("SELECT pages.*, file FROM pages JOIN templates ON templates.id=pages.template_id WHERE url=:url", data);
                if (page) {
                    if (file_exists("./website/" . page->file)) {                        
                        eval("$page=json_decode('" . json_encode(page) . "');");
                        require_once("./website/" . page->file);
                    } else {
                        throw new Exception("template not found");
                    }
                } else {
                    this->ddHead(404);
                    echo this->notFound(false, err->getMessage());
                    this->ddFooter();
                }
            }
        } catch NotFoundException, err {
            this->ddHead(404);
            echo this->notFound(backend, err->getMessage());
            this->ddFooter();
        } catch \Exception, err {
            throw err;
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
            <a href='/dumb-dog/templates' class='button' title='Managing the templates'>
                <img src='/assets/templates.png'>
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

        var head, javascript;
        let head = new Head(this->cfg);        
        let javascript = new Javascript();

        echo "<!DOCTYPE html><html lang='en'>" . head->build() . "<body><div id='bk'><img src='/assets/bk.png'></div><main>";
        echo javascript->logo();
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

    private function notFound(bool backend = true, string message = "page is not found")
    {
        if (backend) {
            return "
            <div class='box'>
                <div class='box-title'>
                    <img src='/assets/dumbdog.png'>
                    <span>dang it!</span>
                </div>
                <div class='box-body'>
                    <h1>" . message . "</h1>
                </div>
                <div class='box-footer'>
                    <button type='button' onclick='window.history.back()'>back</button>
                </div>
            </div>
            ";
        } else {
            return "not found";
        }
    }
}