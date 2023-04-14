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

use DumbDog\Controllers\Dashboard;
use DumbDog\Controllers\Database;
use DumbDog\Controllers\Pages;
use DumbDog\Controllers\Settings;
use DumbDog\Controllers\Templates;
use DumbDog\Controllers\Themes;
use DumbDog\Controllers\Users;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;
use DumbDog\Ui\Gfx\Titles;

class DumbDog
{
    private cfg = [];
    private version = "0.0.1 alpha";

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
                var location, url, route;
                let backend = true;
                let path = "/" . trim(str_replace("/dumb-dog", "", parsed["path"]), "/");

                if (path == "/") {
                    let path = "/dashboard";
                }

                var controllers = [
                    "Dashboard": new Dashboard(cfg),
                    "Pages": new Pages(cfg),
                    "Settings": new Settings(cfg),
                    "Templates": new Templates(cfg),
                    "Themes": new Themes(cfg),
                    "Users": new Users(cfg)
                ];

                var routes = [
                    "/dashboard": [
                        "Dashboard",
                        "index",
                        "dashboard"
                    ],
                    "/the-pound": [
                        "Dashboard",
                        "login",
                        "login"
                    ],
                    "/give-up": [
                        "Dashboard",
                        "logout",
                        "logout"
                    ],
                    "/pages/add": [
                        "Pages",
                        "add",
                        "create a page"
                    ],
                    "/pages/edit": [
                        "Pages",
                        "edit",
                        "edit the page"
                    ],
                    "/pages": [
                        "Pages",
                        "index",
                        "pages"
                    ],
                    "/templates/add": [
                        "Templates",
                        "add",
                        "add a template"
                    ],
                    "/templates/edit": [
                        "Templates",
                        "edit",
                        "edit the template"
                    ],
                    "/templates": [
                        "Templates",
                        "index",
                        "templates"
                    ],
                    "/themes/add": [
                        "Themes",
                        "add",
                        "add a theme"
                    ],
                    "/themes/edit": [
                        "Themes",
                        "edit",
                        "edit the theme"
                    ],
                    "/themes": [
                        "Themes",
                        "index",
                        "themes"
                    ],
                    "/settings": [
                        "Settings",
                        "index",
                        "settings"
                    ],
                    "/users/add": [
                        "Users",
                        "add",
                        "add a user"
                    ],
                    "/users/edit": [
                        "Users",
                        "edit",
                        "edit the user"
                    ],
                    "/users": [
                        "Users",
                        "index",
                        "users"
                    ]
                ];                                

                for url, route in routes {
                    if (strpos(path, url) !== false) {
                        let controller = controllers[route[0]];
                        let location = route[1];
                        let output = controller->{location}(path);
                        let location = route[2];
                        break;
                    }
                }

                if (empty(location)) {
                    let code = 404;
                    let output = this->notFound();
                }

                this->secure(path);

                this->ddHead(code, location);
                echo output;
                this->ddFooter(isset(_SESSION["dd"]) ? true : false);
            } else {
                var database, data = [], page;

                let database = new Database(this->cfg);
                let data["url"] = path;

                let page = database->get("SELECT
                        pages.*, file 
                    FROM pages 
                    JOIN templates ON templates.id=pages.template_id 
                    WHERE url=:url AND status='live'", data);
                if (page) {
                    var settings;
                    let settings = database->get("SELECT settings.*,themes.folder AS theme FROM settings JOIN themes ON themes.id=settings.theme_id LIMIT 1");
                    if (file_exists("./website/" . page->file)) {
                        let settings->theme = "/website/themes/" . settings->theme . "/theme.css";
                        eval("$dd_site=json_decode('" . json_encode(settings) . "');$dd_page=json_decode('" . json_encode(page) . "');");
                        require_once("./website/" . page->file);
                    } else {
                        throw new Exception("template not found");
                    }
                } else {
                    this->notFound(false);
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
    
    private function ddFooter(bool menu = true)
    {
        var javascript;
        let javascript = new Javascript();

        echo "</main>";
        if (menu) {
            this->quickMenu();
        }
        echo "</body>" . javascript->common() . "</html>";
    }

    private function ddHead(int code = 200, string location)
    {
        if (code == 404) {
            header("HTTP/1.1 404 Not Found");
        }

        var head, javascript;
        let head = new Head(this->cfg);        
        let javascript = new Javascript();

        echo "<!DOCTYPE html><html lang='en'>" . head->build(location) . "<body><div id='bk'><img src='/assets/bk.png'></div><main>";
        echo javascript->logo();
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
            var titles;
            let titles = new Titles();

            this->ddHead(404, "page not found");
            echo titles->page("page not found");
            this->ddFooter(false);
        }
    }

    private function quickMenu()
    {
        echo "<div id='quick-menu' style='display: none'>
            <a href='/dumb-dog/pages/add' class='button' title='Add a page'>
                <img src='/assets/add-page.png'>
            </a>
            <a href='/dumb-dog/pages' class='button' title='Managing the pages'>
                <img src='/assets/pages.png'>
            </a>
            <a href='/dumb-dog' class='button' title='Go to the dashboard'>
                <img src='/assets/dashboard.png'>
            </a>
            <a href='/dumb-dog/settings' class='button' title='Site wide settings'>
                <img src='/assets/settings.png'>
            </a>
            <a href='/dumb-dog/give-up' class='button' title='Log me out'>
                <img src='/assets/logout.png'>
            </a>
        </div>
        <div id='quick-menu-button' onclick='showQuickMenu()'>
            <div class='button'>
                <img src='/assets/dumbdog.png'>
            </div>
        </div>";
    }

    public function secure(string path)
    {
        if (!isset(_SESSION["dd"])) {
            if (path != "/the-pound") {
                header("Location: /dumb-dog/the-pound");
                die();
            }
        }
    }
}