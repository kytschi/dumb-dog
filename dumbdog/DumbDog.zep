/**
 * Dumb Dog - A different type of CMS
 *
 * @package     DumbDog\DumbDog
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.4 alpha
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

use DumbDog\Controllers\Appointments;
use DumbDog\Controllers\Comments;
use DumbDog\Controllers\Dashboard;
use DumbDog\Controllers\Database;
use DumbDog\Controllers\Events;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\Messages;
use DumbDog\Controllers\Orders;
use DumbDog\Controllers\Pages;
use DumbDog\Controllers\Products;
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
    private version = "0.0.5 alpha";

    public function __construct(string cfg_file, template_engine = null, string migrations_folder = "")
    {
        var cfg, err;
        let cfg = new \stdClass();

        if (!file_exists(cfg_file)) {
            throw new Exception(
                "Failed to load the config file",
                (!empty(migrations_folder) ? true : false)
            );
        }
        try {
            let cfg = json_decode(file_get_contents(cfg_file), false, 512, JSON_THROW_ON_ERROR);
            if (!property_exists(cfg, "save_mode")) {
                let cfg->save_mode = true;
            }
        } catch \Exception, err {
            throw new Exception(
                "Failed to decode the JSON in config file",
                (!empty(migrations_folder) ? true : false)
            );
        }
        let this->cfg = cfg;
        define("VERSION", this->version);

        if (!empty(migrations_folder)) {
            this->runMigrations(migrations_folder);
            return;
        }

        let this->template_engine = template_engine;

        var parsed, path, backend = false;
        let parsed = parse_url(_SERVER["REQUEST_URI"]);
        let path = "/" . trim(parsed["path"], "/");

        if (template_engine) {
            this->setTemplateEngine(template_engine);
        }

        try {
            if (strpos(path, "/dumb-dog") !== false) {
                let backend = true;
                this->backend(parsed["path"]);
            } elseif(path == "/robots.txt") {
                this->robots();
            } elseif(path == "/sitemap.xml") {
                this->sitemap();
            } else {
                this->frontend(path);
            }
        } catch NotFoundException, err {
            this->ddHead("", 404);
            echo this->notFound(backend, err->getMessage());
            this->ddFooter();
        } catch \Exception, err {
            throw err;
        }
    }
    
    private function backend(string path)
    {
        var location = "", url = "", route, output, code = 200, controller;
        
        let path = "/" . trim(str_replace("/dumb-dog", "", path), "/");
        if (path == "/") {
            let path = "/dashboard";
        }

        /**
         * I'm needed for the session handling for logins etc.
         */
        if (session_status() === 1) {
            session_name("dd");
            session_start();
        }

        this->secure(path);

        var controllers = [
            "Appointments": new Appointments(this->cfg),
            "Comments": new Comments(this->cfg),
            "Dashboard": new Dashboard(this->cfg),
            "Events": new Events(this->cfg),
            "Files": new Files(this->cfg),
            "Messages": new Messages(this->cfg),
            "Orders": new Orders(this->cfg),
            "Pages": new Pages(this->cfg),
            "Products": new Products(this->cfg),
            "Settings": new Settings(this->cfg),
            "Templates": new Templates(this->cfg),
            "Themes": new Themes(this->cfg),
            "Users": new Users(this->cfg)
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
            "/appointments/add": [
                "Appointments",
                "add",
                "create an appointment"
            ],
            "/appointments/delete": [
                "Appointments",
                "delete",
                "delete the appointment"
            ],
            "/appointments/edit": [
                "Appointments",
                "edit",
                "edit the appointment"
            ],
            "/appointments/recover": [
                "Appointments",
                "recover",
                "recover the appointment"
            ],
            "/appointments": [
                "Appointments",
                "index",
                "appointments"
            ],
            "/comments/add": [
                "Comments",
                "add",
                "create a comment"
            ],
            "/comments/delete": [
                "Comments",
                "delete",
                "delete the comment"
            ],
            "/comments/edit": [
                "Comments",
                "edit",
                "edit the comment"
            ],
            "/comments/recover": [
                "Comments",
                "recover",
                "recover the comment"
            ],
            "/comments": [
                "Comments",
                "index",
                "comments"
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
            "/events/add": [
                "Events",
                "add",
                "create an event"
            ],
            "/events/delete": [
                "Events",
                "delete",
                "delete the event"
            ],
            "/events/edit": [
                "Events",
                "edit",
                "edit the event"
            ],
            "/events/recover": [
                "Events",
                "recover",
                "recover the event"
            ],
            "/events": [
                "Events",
                "index",
                "events"
            ],
            "/products/add": [
                "Products",
                "add",
                "create a product"
            ],
            "/products/delete": [
                "Products",
                "delete",
                "delete the product"
            ],
            "/products/edit": [
                "Products",
                "edit",
                "edit the product"
            ],
            "/products/recover": [
                "Products",
                "recover",
                "recover the product"
            ],
            "/products": [
                "Products",
                "index",
                "products"
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
            "/messages/delete": [
                "Messages",
                "delete",
                "delete the message"
            ],
            "/messages/view": [
                "Messages",
                "view",
                "view the message"
            ],
            "/messages/read": [
                "Messages",
                "read",
                "mark the message as read"
            ],
            "/messages/recover": [
                "Messages",
                "recover",
                "recover the message"
            ],
            "/messages": [
                "Messages",
                "index",
                "messages"
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
            ],
            "/orders/delete": [
                "Orders",
                "delete",
                "delete the order"
            ],
            "/orders/edit": [
                "Orders",
                "edit",
                "edit the order"
            ],
            "/orders/recover": [
                "Orders",
                "recover",
                "recover the order"
            ],
            "/orders": [
                "Orders",
                "index",
                "orders"
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

        this->ddHead(location, code);
        echo output;
        this->ddFooter(isset(_SESSION["dd"]) ? true : false);
    }

    private function ddFooter(bool menu = true)
    {
        var javascript;
        let javascript = new Javascript();

        echo "</main>";
        if (menu) {
            this->quickMenu();
            echo javascript->trumbowygIcons();
        }
        echo "</body>" . javascript->common() . "</html>";
    }

    private function ddHead(string location, int code = 200)
    {
        if (code == 404) {
            header("HTTP/1.1 404 Not Found");
        }

        var head, javascript, id;
        let head = new Head(this->cfg);
        let javascript = new Javascript();

        let id = "dd-bk";
        
        if (strpos(location, "page not") !== false) {
            let id = "dd-page-not-found";
        } elseif (strpos(location, "offline") !== false) {
            let id = "dd-error";
        } elseif (strpos(location, "page") !== false) {
            let id = "dd-page-bk";
        } elseif (strpos(location, "appointment") !== false) {
            let id = "dd-appointments-bk";
        } elseif (strpos(location, "product") !== false) {
            let id = "dd-products-bk";
        } elseif (strpos(location, "dashboard") !== false) {
            let id = "dd-dashboard-bk";
        } elseif (strpos(location, "event") !== false) {
            let id = "dd-events-bk";
        } elseif (strpos(location, "settings") !== false) {
            let id = "dd-settings-bk";
        } elseif (strpos(location, "theme") !== false) {
            let id = "dd-themes-bk";
        } elseif (strpos(location, "template") !== false) {
            let id = "dd-templates-bk";
        } elseif (strpos(location, "user") !== false) {
            let id = "dd-users-bk";
        } elseif (strpos(location, "order") !== false) {
            let id = "dd-orders-bk";
        }

        echo "<!DOCTYPE html>
            <html lang='en'>" . head->build(location) .
            "<body id='" . id . "'>
            <div class='dd-background-image'></div>
            <main class='dd-main'>";
        if (this->cfg->save_mode == false) {
            echo "<div class='dd-warning dd-alert'><span>saving is currently disabled</span></div>";
        }
        echo javascript->logo();
    }

    private function frontend(string path)
    {
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
                    pages.*,
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
                    let obj->header = [];
                    let obj->footer = [];
                    let obj->both = [];

                    eval("$DUMBDOG = new DumbDog\\Helper\\DumbDog(
                        json_decode('" . json_encode(this->cfg) . "', false, 512, JSON_THROW_ON_ERROR),
                        json_decode('" . json_encode(page, JSON_HEX_APOS | JSON_INVALID_UTF8_SUBSTITUTE) . "', false, 512, JSON_THROW_ON_ERROR)
                    );");
                                                
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

    private function notFound(bool backend = true, string message = "page is not found")
    {
        if (backend) {
            return "
            <div class='dd-box'>
                <div class='dd-box-title'>
                    <img src='/assets/dumbdog.png'>
                    <span>dang it!</span>
                </div>
                <div class='dd-box-body'>
                    <h1 class='dd-h1'>" . message . "</h1>
                </div>
                <div class='dd-box-footer'>
                    <button type='button' class='dd-button' onclick='window.history.back()'>back</button>
                </div>
            </div>
            ";
        } else {
            var titles;
            let titles = new Titles();

            this->ddHead("page not found", 404);
            echo titles->page("page not found", "/assets/dumbdog.png");
            this->ddFooter(false);
        }
    }

    private function offline()
    {
        var titles;
        let titles = new Titles();

        this->ddHead("offline", 404);
        echo titles->page("offline", "/assets/dumbdog.png");
        echo "<div class='dd-box'><div class='dd-box-body'><h3 class='dd-h3'>*yawn* Let me sleep a little longer will you...</h3></div></div>";
        this->ddFooter(false);        
    }

    private function quickMenu()
    {
        var database, messages, appointments, controller;

        let controller = new Appointments(this->cfg);
        let database = new Database(this->cfg);

        echo "<div id='dd-quick-menu' style='display: none'>
            <a href='/dumb-dog/pages/add' class='dd-round dd-icon' title='Add a page'>&nbsp;</a>
            <a href='/dumb-dog/pages' class='dd-round dd-icon dd-icon-pages' title='Managing the content'>&nbsp;</a>
            <a href='/dumb-dog/appointments' class='dd-round dd-icon dd-icon-appointments' title='Go to the appointments'>&nbsp;</a>
            <a href='/dumb-dog' class='dd-round dd-icon dd-icon-dashboard' title='Go to the dashboard'>&nbsp;</a>
            <a href='/dumb-dog/settings' class='dd-round dd-icon dd-icon-settings' title='Site wide settings'>&nbsp;</a>
            <a href='/dumb-dog/give-up' class='dd-round dd-icon dd-icon-logout' title='Log me out'>&nbsp;</a>
        </div>
        <div id='dd-quick-menu-button'>
            <div class='dd-round dd-icon dd-icon-dumbdog' onclick='showQuickMenu()'>&nbsp;</div>";
        
        let messages = database->get("SELECT count(id) AS total FROM messages WHERE status='unread'");
        if (messages->total) {
            echo "<div id='dd-message-count'><a href='/dumb-dog/messages'>new messages</a><span></span></div>";
        }

        let appointments = database->get(
            "SELECT count(id) AS total FROM appointments WHERE user_id=:user_id AND on_date >= NOW() AND free_slot = 0",
            [
                "user_id": controller->getUserId()
            ]
        );
        if (appointments->total) {
            echo "<div id='dd-appointments'><a href='/dumb-dog/appointments'>new appointments</a><span></span></div>";
        }

        echo "</div>";
    }

    private function robots()
    {
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
    }

    private function runMigrations(string migrations_folder)
    {
        var migration, migrations, err, found, database;
        let database = new Database(this->cfg);

        echo "Running migrations\n";
        let migration = shell_exec("ls " . rtrim(migrations_folder, "/") . "/*.sql");
        if (empty(migration)) {
            echo "Nothing to migrate!\n";
            return;
        }
        let migrations = explode("\n", migration);
        if (!count(migrations)) {
            echo "Nothing to migrate!\n";
            return;
        }

        for migration in migrations {
            if (empty(migration)) {
                continue;
            }

            try {
                let found = database->get(
                    "SELECT * FROM migrations WHERE migration=:migration",
                    [
                        "migration": basename(migration)
                    ]
                );
            } catch \Exception, err {
                let found = false;
            }

            if (found) {
                continue;
            }

            try {
                let found = database->execute(
                    file_get_contents(migration),
                    [],
                    true
                );
                if (!is_bool(found)) {
                    echo "Failed to run the migration " . basename(migration) .
                        "\n Error: ". found . "\n";
                } else {
                    echo basename(migration) . " successfully run\n";
                }
                let found = database->execute(
                    "INSERT INTO migrations (migration, created_at) VALUES (:migration, NOW())",
                    [
                        "migration": basename(migration)
                    ],
                    true
                );
                if (!is_bool(found)) {
                    echo "Failed to save the migration " . basename(migration) .
                        " in the migrations table\n Error: ". found . "\n";
                }
            } catch \Exception, err {
                echo "Failed to run the migration " . basename(migration) .
                    "\n Error: " . err->getMessage() . "\n";
            }
        }
        echo "Migrations complete\n";
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

    private function sitemap()
    {
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
    }
}