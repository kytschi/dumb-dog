/**
 * Dumb Dog - A different type of CMS
 *
 * @package     DumbDog\DumbDog
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.9 alpha
 *
 */
namespace DumbDog;

use DumbDog\Controllers\Appointments;
use DumbDog\Controllers\Blog;
use DumbDog\Controllers\BlogCategories;
use DumbDog\Controllers\Comments;
use DumbDog\Controllers\Content;
use DumbDog\Controllers\ContentCategories;
use DumbDog\Controllers\ContentStacks;
use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Countries;
use DumbDog\Controllers\Currencies;
use DumbDog\Controllers\Dashboard;
use DumbDog\Controllers\Database;
use DumbDog\Controllers\Events;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\Groups;
use DumbDog\Controllers\Leads;
use DumbDog\Controllers\Menus;
use DumbDog\Controllers\Messages;
use DumbDog\Controllers\PaymentGateways;
use DumbDog\Controllers\Products;
use DumbDog\Controllers\ProductCategories;
use DumbDog\Controllers\Reviews;
use DumbDog\Controllers\Settings;
use DumbDog\Controllers\Socials;
use DumbDog\Controllers\Taxes;
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
use DumbDog\Helper\DumbDog as Helper;
use DumbDog\Ui\Feeds;
use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Titles;
use DumbDog\Ui\Menu;

class DumbDog
{
    private cfg;
    private template_engine = null;
    private version = "0.0.9 alpha";

    public function __construct(
        string cfg_file,
        libs = null,
        template_engine = null,
        bool commandline = false
    ) {
        var cfg, err;
        let cfg = new \stdClass();

        define("LIBS", libs);
        define("VERSION", this->version);

        if (!file_exists(cfg_file)) {
            throw new Exception(
                "Failed to load the config file",
                500,
                commandline
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
                500,
                commandline
            );
        }

        if (!isset(cfg->dumb_dog_url)) {
            let cfg->dumb_dog_url = "/dumb-dog";
        } elseif (!empty(cfg->dumb_dog_url)) {
            let cfg->dumb_dog_url = "/dumb-dog";
        }

        let cfg->dumb_dog_url = rtrim(cfg->dumb_dog_url, "/");
        let this->cfg = cfg;
        
        if (commandline) {
            define("CFG", this->cfg);
            return;
        }

        var database;
        let database = new Database(cfg);
        let cfg->settings = database->get("
            SELECT
                settings.*,
                themes.folder AS theme
            FROM 
                settings
            JOIN themes ON themes.id=settings.theme_id LIMIT 1");
        if (empty(cfg->settings)) {
            throw new \Exception("show stopper...no settings in the database");
        }

        let this->cfg = cfg;
        define("CFG", this->cfg);
        
        let this->template_engine = template_engine;

        var parsed, path, backend = false;
        let parsed = parse_url(_SERVER["REQUEST_URI"]);
        let path = "/" . trim(parsed["path"], "/");

        if (template_engine) {
            this->setTemplateEngine(template_engine);
        }
        
        try {
            if (strpos(path . "/", this->cfg->dumb_dog_url . "/") !== false) {
                let backend = true;
                this->backend(parsed["path"]);
            }

            //Look for the sitemap, rss, robots, atom request and so on.
            (new Feeds())->process(path);

            this->frontend(path);
        } catch NotFoundException, err {
            this->ddHead(strtolower(err->getMessage()), 404);
            echo this->notFound(backend, err->getMessage());
            this->ddFooter();
        } catch \Exception, err {
            throw err;
        }
    }
    
    private function backend(string path)
    {
        var location = "", url = "", route, output, code = 200, controller;

        let path = "/" . trim(str_replace(this->cfg->dumb_dog_url, "", path), "/");
        if (path == "/") {
            let path = "/dashboard";
        }

        // Payment gateway handling.        
        let controller = new PaymentGateways();
        controller->process(path);

        this->startSession();
        this->secure(path);

        var controllers = [
            "Appointments": new Appointments(),
            "Blog": new Blog(),
            "BlogCategories": new BlogCategories(),
            "Comments": new Comments(),
            "ContentStacks": new ContentStacks(),
            "Countries": new Countries(),
            "Currencies": new Currencies(),
            "Dashboard": new Dashboard(),
            "Events": new Events(),
            "Files": new Files(),
            "Groups": new Groups(),
            "Leads": new Leads(),
            "Menus": new Menus(),
            "Messages": new Messages(),
            "Pages": new Content(),
            "PageCategories": new ContentCategories(),
            "PaymentGateways": new PaymentGateways(),
            "Products": new Products(),
            "ProductCategories": new ProductCategories(),
            "Reviews": new Reviews(),
            "Settings": new Settings(),
            "Socials": new Socials(),
            "Taxes": new Taxes(),
            "Templates": new Templates(),
            "Themes": new Themes(),
            "Users": new Users()
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
            ]
        ];

        for url, route in controllers {
            let routes = array_merge(routes, route->routes);
        }
        
        for url, route in routes {
            if (strpos(path, url) === false) {
                continue;
            }

            if (!isset(route[0]) && !isset(route[1]) && !isset(route[2])) {
                continue;
            }

            if (!isset(controllers[route[0]])) {
                continue;
            }

            let controller = controllers[route[0]];
            let location = route[1];

            if (!method_exists(controller, location)) {
                continue;
            }
            
            let output = controller->{location}(path);
            let location = route[2];
            break;
        }

        if (empty(location)) {
            let code = 404;
            let output = this->notFound();
            let location = "page not found";
        }

        this->ddHead(location, code);
        if (this->runMigrations(true)) {
            echo "<div class='dd-warning dd-alert'><span>migrations available</span></div>";
        }
        echo output;
        this->ddFooter(isset(_SESSION["dd"]) ? true : false);
        exit();
    }

    private function ddFooter(bool menu = true)
    {
        var javascript;
        let javascript = new Javascript();

        echo "</main>";
        if (menu) {
            echo javascript->trumbowygIcons();
            (new Menu())->quickmenu();
        }
        echo "</body>" . javascript->common() . "</html>";
    }

    private function ddHead(string location, int code = 200)
    {
        if (code == 404) {
            header("HTTP/1.1 404 Not Found");
        }

        var head, javascript, id;
        let head = new Head();
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
        var database, data = [], page, settings, menu, files;         
        let database = new Database();
        let files = new Files();
        
        if (this->cfg->settings->status == "offline") {
            this->offline();
        } else {
            this->startSession();

            let data["url"] = path;
            let page = database->get("
                SELECT
                    content.*,
                    templates.file AS template 
                FROM content 
                JOIN templates ON templates.id=content.template_id 
                WHERE 
                    content.url=:url AND 
                    content.status='live' AND 
                    content.public_facing=1 AND 
                    content.deleted_at IS NULL",
                data
            );
            if (page) {
                var file;
                let file = page->template;
                if (!empty(this->template_engine)) {
                    let file = page->template . this->template_engine->extension;
                }

                if (file_exists("./website/" . file)) {
                    let page = this->pageExtra(database, page, files);

                    var obj;
                    let obj = new \stdClass();
                    let obj->header = [];
                    let obj->footer = [];
                    let obj->both = [];

                    define("DUMBDOG", new Helper(page));
                    eval("$DUMBDOG = constant('DUMBDOG');");
                                                                    
                    if (!empty(this->template_engine)) {
                        this->template_engine->render(
                            page->template,
                            [
                                page,
                                settings,
                                new Content(),
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
            var icons;
            let icons = new Icons();

            return "
            <div class='dd-box'>
                <div class='dd-box-title'>".
                    icons->dumbdog() .
                    "<span class='dd-pt-2'>dang it!</span>
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
            echo titles->page("page not found", "dumbdog");
            this->ddFooter(false);
        }
    }

    private function pageExtra(database, page, files)
    {
        var item, controller;
        let controller = new Controller();

        let page->images = database->all(
            "SELECT 
                IF(filename IS NOT NULL, CONCAT('" . files->folder . "', filename), '') AS image,
                IF(filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', filename), '') AS thumbnail 
            FROM files 
            WHERE resource_id=:resource_id AND resource='content-image' AND deleted_at IS NULL AND visible=1
            ORDER BY sort ASC",
            [
                "resource_id": page->id
            ]
        );

        // Get the parent
        let item = database->get("
            SELECT
                content.*,
                templates.file AS template 
            FROM content 
            JOIN templates ON templates.id=content.template_id 
            WHERE 
                content.id=:id AND 
                content.status='live' AND 
                content.public_facing=1 AND 
                content.deleted_at IS NULL",
            [
                "id": page->parent_id
            ]
        );

        if (item) {
            let item->images = database->all(
                "SELECT 
                    IF(filename IS NOT NULL, CONCAT('" . files->folder . "', filename), '') AS image,
                    IF(filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', filename), '') AS thumbnail 
                FROM files 
                WHERE resource_id=:resource_id AND resource='content-image' AND deleted_at IS NULL AND visible=1
                ORDER BY sort ASC",
                [
                    "resource_id": page->parent_id
                ]
            );
        }

        let page->parent = item;

        let item = "content.created_at DESC, content.sort ASC";
        if (in_array(page->type, ["blog-category", "blog"])) {
            let item = "content.created_at DESC";
        }

        let page->children = database->all("
            SELECT
                content.*,
                templates.file AS template 
            FROM content 
            JOIN templates ON templates.id=content.template_id 
            WHERE content.parent_id=:parent_id AND content.status='live' AND content.deleted_at IS NULL
            ORDER BY content.created_at DESC, content.name", 
            [
                "parent_id": page->id
            ]
        );
        
        let page->tags = controller->toTags(page->tags);

        if (page->children) {
            for item in page->children {
                let item = this->pageExtra(database, item, files);
            }
        }

        let page->stacks = database->all("
            SELECT
                content_stacks.*,
                templates.file AS template,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
            FROM content_stacks 
            LEFT JOIN templates ON templates.id = content_stacks.template_id AND templates.deleted_at IS NULL 
            LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
            WHERE 
                content_id=:id AND 
                content_stacks.deleted_at IS NULL AND 
                content_stack_id IS NULL
            ORDER BY sort ASC",
            [
                "id": page->id
            ]
        );

        for item in page->stacks {
            let item->stacks = database->all("
                SELECT
                    content_stacks.*,
                    IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
                    IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
                FROM content_stacks 
                LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
                WHERE content_stack_id=:id AND content_stacks.deleted_at IS NULL 
                ORDER BY sort ASC",
                [
                    "id": item->id
                ]
            );
        }

        switch (page->type) {
            case "product":
                let item = isset(_SESSION["currency"]) ? _SESSION["currency"] : "";
                if (empty(item)) {
                    let item = database->get("SELECT currencies.id FROM currencies WHERE is_default=1");
                    if (!empty(item)) {
                        let _SESSION["currency"] = item->id;
                        let item = _SESSION["currency"];
                    }
                }
                
                let item = database->get("
                    SELECT
                        products.code,
                        products.stock,
                        products.on_offer,
                        product_prices.price,
                        product_prices.offer_price,
                        currencies.symbol,
                        currencies.locale_code
                    FROM products
                    LEFT JOIN product_prices ON 
                        product_prices.id = 
                        (
                            SELECT id
                            FROM product_prices AS pp
                            WHERE
                                pp.product_id = products.id AND
                                pp.deleted_at IS NULL AND
                                pp.currency_id=:currency_id 
                            LIMIT 1
                        )
                    LEFT JOIN currencies ON currencies.id = product_prices.currency_id AND currencies.deleted_at IS NULL 
                    WHERE products.content_id=:page_id",
                    [
                        "currency_id": item,
                        "page_id": page->id
                    ]
                );
                
                if (item) {
                    let page->code = item->code;
                    let page->stock = item->stock;
                    let page->on_offer = item->on_offer;
                    let page->price = item->price;
                    let page->offer_price = item->offer_price;
                    let page->symbol = item->symbol;
                    let page->locale_code = item->locale_code;
                }
                break;
        }

        return page;
    }

    private function offline()
    {
        if (file_exists("./website/offline.php")) {
            var page;
            let page = new \stdClass();
            let page->name = "Offline";
            let page->content = "*yawn* Let me sleep a little longer will you...";
            let page->meta_description = "";
            let page->meta_keywords = "";
            let page->meta_author = "";

            define("DUMBDOG", new Helper(page));
            eval("$DUMBDOG = constant('DUMBDOG');");

            require_once("./website/offline.php");
        } else {
            var titles;
            let titles = new Titles();

            this->ddHead("offline", 404);
            echo titles->page("offline", "/assets/dumbdog.png");
            echo "<div class='dd-box'><div class='dd-box-body'><h3 class='dd-h3'>*yawn* Let me sleep a little longer will you...</h3></div></div>";
            this->ddFooter(false);
        }
    }

    public function runMigrations(bool check = false)
    {
        var migration, migrations, err, found, database;
        let database = new Database(this->cfg);

        if (!check) {
            echo "Running Dumb Dog migrations\n";
        }
        let migration = shell_exec("ls *.sql");
        if (empty(migration)) {
            return;
        }
        
        let migrations = explode("\n", migration);
        if (!count(migrations)) {
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
            } elseif(check) {
                return true;
            }

            try {
                if (!check) {
                    echo "Excuting migration " . migration . "...";
                }
                let found = database->execute(
                    file_get_contents(migration),
                    [],
                    true
                );
                if (!is_bool(found) && !check) {
                    echo "Failed to run the migration " . basename(migration) .
                        "\n Error: ". found . "\n";
                    die();
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
                    die();
                }
                if (!check) {
                    echo "complete\n";
                }
            } catch \Exception, err {
                if (!check) {
                    echo "Failed to run the migration " . basename(migration) .
                        "\n Error: " . err->getMessage() . "\n";
                    die();
                }
            }
        }
        if (!check) {
            echo "Migrations finished\n";
        }
    }

    private function secure(string path)
    {
        if (!isset(_SESSION["dd"])) {
            if (path != "/the-pound") {
                header("Location: " . this->cfg->dumb_dog_url . "/the-pound");
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

    private function startSession()
    {
        /**
         * I'm needed for the session handling for logins etc.
         */
         if (session_status() === 1) {
            session_set_cookie_params([
                "secure": true,
                "samesite": "none"
            ]);

            // Valid for four hours
            ini_set("session.gc_maxlifetime", 14400);
            ini_set("session.cookie_lifetime", 14400);

            session_name("dd");
            session_start();
        }
    }
}