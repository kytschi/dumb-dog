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
use DumbDog\Controllers\Files;
use DumbDog\Controllers\Pages;
use DumbDog\Controllers\Settings;
use DumbDog\Controllers\Templates;
use DumbDog\Controllers\Themes;
use DumbDog\Controllers\Users;
use DumbDog\Engines\Blade;
use DumbDog\Engines\Mustache;
use DumbDog\Engines\Plates;
use DumbDog\Engines\Smarty;
use DumbDog\Engines\Twig;
use DumbDog\Engines\Volt;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;
use DumbDog\Ui\Gfx\Titles;

class DumbDog
{
    private cfg;
    private template_engine = null;
    private version = "0.0.1 alpha";

    public function __construct(string cfg_file, template_engine = null)
    {
        var cfg;
        let cfg = new \stdClass();

        if (!file_exists(cfg_file)) {
            throw new Exception("Failed to load the config file");
        }
        let cfg = json_decode(file_get_contents(cfg_file));
        if (!property_exists(cfg, "save_mode")) {
            let cfg->save_mode = true;
        }
        let this->cfg = cfg;
        let this->template_engine = template_engine;

        define("VERSION", this->version);

        var parsed, path, controller, output, code, backend = false, err;
        let parsed = parse_url(_SERVER["REQUEST_URI"]);
        let path = "/" . trim(parsed["path"], "/");

        let code = 200;

        if (template_engine) {
            this->setTemplateEngine(template_engine);
        }

        try {
            if (strpos(path, "/dumb-dog") !== false) {
                var location, url, route;
                let backend = true;
                let path = "/" . trim(str_replace("/dumb-dog", "", parsed["path"]), "/");

                if (path == "/") {
                    let path = "/dashboard";
                }

                this->secure(path);

                var controllers = [
                    "Dashboard": new Dashboard(cfg),
                    "Files": new Files(cfg),
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
                    "/pages/delete": [
                        "Pages",
                        "delete",
                        "delete the page"
                    ],
                    "/pages/edit": [
                        "Pages",
                        "edit",
                        "edit the page"
                    ],
                    "/pages/recover": [
                        "Pages",
                        "recover",
                        "recover the page"
                    ],
                    "/pages": [
                        "Pages",
                        "index",
                        "pages"
                    ],
                    "/files/add": [
                        "Files",
                        "add",
                        "create a file"
                    ],
                    "/files/delete": [
                        "Files",
                        "delete",
                        "delete the file"
                    ],
                    "/files/edit": [
                        "Files",
                        "edit",
                        "edit the file"
                    ],
                    "/files/recover": [
                        "Pages",
                        "recover",
                        "recover the file"
                    ],
                    "/files": [
                        "Files",
                        "index",
                        "files"
                    ],
                    "/templates/add": [
                        "Templates",
                        "add",
                        "add a template"
                    ],
                    "/templates/delete": [
                        "Templates",
                        "delete",
                        "delete the template"
                    ],
                    "/templates/edit": [
                        "Templates",
                        "edit",
                        "edit the template"
                    ],
                    "/templates/recover": [
                        "Templates",
                        "recover",
                        "recover the template"
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
                    "/themes/delete": [
                        "Themes",
                        "delete",
                        "delete the theme"
                    ],
                    "/themes/edit": [
                        "Themes",
                        "edit",
                        "edit the theme"
                    ],
                    "/themes/recover": [
                        "Themes",
                        "recover",
                        "recover the theme"
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
                    "/users/delete": [
                        "Users",
                        "delete",
                        "delete the user"
                    ],
                    "/users/edit": [
                        "Users",
                        "edit",
                        "edit the user"
                    ],
                    "/users/recover": [
                        "Users",
                        "recover",
                        "recover the user"
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

                this->ddHead(code, location);
                echo output;
                this->ddFooter(isset(_SESSION["dd"]) ? true : false);
            } elseif(path == "/robots.txt") {
                var database, settings;
                let database = new Database(this->cfg);

                let settings = database->get("
                        SELECT
                            settings.robots_txt
                        FROM 
                            settings
                        LIMIT 1");
                if (settings) {
                    header("Content-Type: text/plain");
                    echo settings->robots_txt;
                }
            } elseif(path == "/sitemap.xml") {
                var database, pages, iLoop, url;
                let database = new Database(this->cfg);

                let pages = database->all("
                        SELECT
                            pages.*
                        FROM 
                            pages
                        WHERE pages.status='live' AND pages.deleted_at IS NULL");
                if (pages) {
                    let iLoop = 0;
                    let url = (_SERVER["HTTPS"] ? "https://" : "http://") . _SERVER["SERVER_NAME"];
                    header("Content-Type: text/xml");
                    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
                    echo "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">";
                    while (iLoop < count(pages)) {
                        echo "<url>";
                        echo "<loc>" .  url . pages[iLoop]->url . "</loc>";
                        echo "<lastmod>" . (new \DateTime(pages[iLoop]->updated_at))->format(\DateTime::ATOM) . "</lastmod>";
                        echo "</url>";                        
                        let iLoop = iLoop + 1;
                    }
                    echo "</urlset>";
                }
            } else {
                var database, data = [], page, settings, menu;
                
                let database = new Database(this->cfg);
                
                let settings = database->get("
                    SELECT
                        settings.name,
                        settings.meta_keywords,
                        settings.meta_description,
                        settings.meta_author,
                        settings.status,
                        themes.folder AS theme
                    FROM 
                        settings
                    JOIN themes ON themes.id=settings.theme_id LIMIT 1");
                if (empty(settings)) {
                    throw new \Exception("show stopper...no settings in the database");
                }

                if (settings->status == "offline") {
                    this->offline();
                } else {
                    let data["url"] = path;
                    let page = database->get("
                        SELECT
                            pages.id,
                            pages.name,
                            pages.url,
                            pages.content,
                            pages.meta_keywords,
                            pages.meta_description,
                            pages.meta_author,
                            templates.file AS template
                        FROM pages 
                        JOIN templates ON templates.id=pages.template_id 
                        WHERE pages.url=:url AND pages.status='live' AND pages.deleted_at IS NULL", data);
                    if (page) {
                        var file;
                        let file = page->template;
                        if (!empty(this->template_engine)) {
                            let file = page->template . this->template_engine->extension;
                        }

                        if (file_exists("./website/" . file)) {
                            var obj;
                            let obj = new \stdClass();
                            let settings->theme = "/website/themes/" . settings->theme . "/theme.css";
                            eval("$DUMBDOG = new \\stdClass();$DUMBDOG->menu = new \\stdClass();");
                            eval("$DUMBDOG->pages = new DumbDog\\Controllers\\Pages(json_decode('" . json_encode(this->cfg) . "', false, 512, JSON_THROW_ON_ERROR));");
                            eval("$DUMBDOG->site=json_decode('" . json_encode(settings) . "', false, 512, JSON_THROW_ON_ERROR);");
                            eval("$DUMBDOG->page=json_decode('" . json_encode(page, JSON_HEX_APOS | JSON_INVALID_UTF8_SUBSTITUTE) . "', false, 512, JSON_THROW_ON_ERROR);");
                            let menu = database->all("SELECT name, url FROM pages WHERE menu_item='header' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
                            if (menu) {
                                let obj->header = menu;
                                eval("$DUMBDOG->menu->header=json_decode('" . json_encode(menu) . "', false, 512, JSON_THROW_ON_ERROR);");
                            }
                            let menu = database->all("SELECT name, url FROM pages WHERE menu_item='footer' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
                            if (menu) {
                                let obj->footer = menu;
                                eval("$DUMBDOG->menu->footer=json_decode('" . json_encode(menu) . "', false, 512, JSON_THROW_ON_ERROR);");
                            }
                            let menu = database->all("SELECT name, url FROM pages WHERE menu_item='both' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
                            if (menu) {
                                let obj->both = menu;
                                eval("$DUMBDOG->menu->both=json_decode('" . json_encode(menu) . "', false, 512, JSON_THROW_ON_ERROR);");
                            }
                            
                            if (!empty(this->template_engine)) {
                                this->template_engine->render(
                                    page->template,
                                    [
                                        page,
                                        settings,
                                        new Pages(this->cfg),
                                        obj
                                    ]
                                );
                            } else {
                                require_once("./website/" . page->template);
                            }

                            let data = [];
                            let data["page_id"] = page->id;
                            let data["visitor"] = hash("sha256", _SERVER["REMOTE_ADDR"]);
                            let data["referer"] = null;
                            let data["agent"] = null;
                            let data["bot"] = null;

                            if (isset(_SERVER["HTTP_REFERER"])) {
                                let menu = parse_url(_SERVER["HTTP_REFERER"]);
                                let settings = (_SERVER["HTTPS"] ? "https://" : "http://") . _SERVER["SERVER_NAME"];
                                if (!empty(menu["host"])) {
                                    if (menu["host"] != settings) {
                                        let data["referer"] = trim(str_replace(["www."], "", menu["host"]));
                                    }
                                }
                            }

                            if (isset(_SERVER["HTTP_USER_AGENT"])) {
                                let data["agent"] = _SERVER["HTTP_USER_AGENT"];

                                let settings = this->setBot(strtolower(data["agent"]));
                                if (is_bool(settings) && settings === true) {
                                    let data["bot"] = data["agent"];
                                } elseif (is_string(settings)) {
                                    let data["bot"] = settings;
                                }
                            }

                            // Save the stats.
                            database->execute(
                                "INSERT INTO stats 
                                    (id,
                                    page_id,
                                    visitor,
                                    referer,
                                    agent,
                                    bot,
                                    created_at) 
                                VALUES 
                                    (UUID(),
                                    :page_id,
                                    :visitor,
                                    :referer,
                                    :agent,
                                    :bot,
                                    NOW())",
                                data,
                                true
                            );
                        } else {
                            throw new Exception("template not found");
                        }
                    } else {
                        this->notFound(false);
                    }
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

        var head, javascript, id;
        let head = new Head(this->cfg);
        let javascript = new Javascript();

        let id = "bk";
        
        if (strpos(location, "page not") !== false || strpos(location, "offline") !== false) {
            let id = "error";
        } elseif (strpos(location, "page") !== false) {
            let id = "page-bk";
        } elseif (strpos(location, "dashboard") !== false) {
            let id = "dashboard-bk";
        } elseif (strpos(location, "settings") !== false) {
            let id = "settings-bk";
        } elseif (strpos(location, "theme") !== false) {
            let id = "themes-bk";
        } elseif (strpos(location, "template") !== false) {
            let id = "templates-bk";
        } elseif (strpos(location, "user") !== false) {
            let id = "users-bk";
        }

        echo "<!DOCTYPE html><html lang='en'>" . head->build(location) . "<body id='" . id . "'><main>";
        if (this->cfg->save_mode == false) {
            echo "<div class='warning alert'><span>saving is currently disabled</span></div>";
        }
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
            echo titles->page("page not found", "/assets/dumbdog.png");
            this->ddFooter(false);
        }
    }

    private function offline()
    {
        var titles;
        let titles = new Titles();

        this->ddHead(404, "offline");
        echo titles->page("offline", "/assets/dumbdog.png");
        echo "<div class='box'><div class='box-body'><h3>*yawn* Let me sleep a little longer will you...</h3></div></div>";
        this->ddFooter(false);        
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

    private function secure(string path)
    {
        if (!isset(_SESSION["dd"])) {
            if (path != "/the-pound") {
                header("Location: /dumb-dog/the-pound");
                die();
            }
        }
    }

    private function setBot(string agent)
    {
        if (
            strpos("crawl", agent) !== false ||
            strpos("bot", agent) !== false ||
            strpos("spider", agent) !== false
        ) {
            return true;
        }

        var bots = [
            "Mail.RU_Bot": "https://help.mail.ru/webmaster/indexing/robots",
            "Xenu Link Sleuth": "Xenu Link Sleuth",
            "W3C Validator": "W3C_Validator",
            "TLS tester": "TLS tester",
            "Screaming Frog": "Screaming Frog SEO",
            "panscient.com": "panscient.com",
            "pantest": "pantest",
            "Pandalytics": "Pandalytics",
            "P3P Validator": "P3P Validator",
            "okhttp": "okhttp",
            "Netwalk research scanner": "Netwalk research scanner",
            "NetSystemsResearch": "NetSystemsResearch",
            "netEstate": "netEstate",
            "pdrlabs cloud mapping": "Cloud mapping experiment",
            "CheckMarkNetwork": "CheckMarkNetwork",
            "colly": "colly",
            "expanseinc.com": "expanseinc.com",
            "facebookexternalhit": "facebookexternalhit",
            "FeedFetcher-Google": "FeedFetcher-Google",
            "Fuzz Faster U Fool": "Fuzz Faster U Fool",
            "got": "got (https://github.com/sindresorhus/got)",
            "HTTP Banner Detection": "HTTP Banner Detection",
            "Gather Analyze Provide": "https://gdnplus.com",
            "httpx": "github.com/projectdiscovery/httpx",
            "IDG/IT": "IDG/IT (http://spaziodati.eu/)",
            "Kryptos Logic Telltale": "Kryptos Logic Telltale - telltale.kryptoslogic.com",
            "l9tcpid": "l9tcpid",
            "LinkWalker": "LinkWalker/3.0 (http://www.brandprotect.com)",
            "masscan-ng": "masscan-ng",
            "APIs-Ayeh": "APIs-Ayeh",
            "Google Site Verification": "Google-Site-Verification",
            "Bloglovin": "Bloglovin"
        ],
        type, check;

        for type, check in bots {
            if (strpos(agent, strtolower(check)) !== false) {
                return type;
            }
        }

        return false;
    }

    private function setTemplateEngine(template_engine)
    {
        var engine;
        let engine = get_class(template_engine);
                
        switch(engine) {
            case "eftec\\bladeone\\BladeOne":
                let this->template_engine = new Blade(template_engine);
                break;
            case "League\\Plates\\Engine":
                let this->template_engine = new Plates(template_engine);
                break;
            case "Mustache_Engine":
                let this->template_engine = new Mustache(template_engine);
                break;
            case "Phalcon\\Mvc\\View\\Engine\\Volt\\Compiler":
                let this->template_engine = new Volt(template_engine);
                break;
            case "Smarty":
                let this->template_engine = new Smarty(template_engine);
                break;
            case "Twig\\Environment":
                let this->template_engine = new Twig(template_engine);
                break;
            default:
                throw new Exception("Template engine not supported");
        }
    }
}