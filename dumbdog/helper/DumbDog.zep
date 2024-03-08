/**
 * Dumb Dog helper
 *
 * @package     DumbDog\Helper\DumbDog
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Helper;

use DumbDog\Controllers\Basket;
use DumbDog\Controllers\Content;
use DumbDog\Controllers\Database;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\Messages;
use DumbDog\Controllers\PaymentGateways;
use DumbDog\Controllers\Products;
use DumbDog\Controllers\ProductCategories;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Dates;
use DumbDog\Helper\Security;
use DumbDog\Ui\Captcha;

class DumbDog
{
    private cfg;
    private libs;
    public captcha;
    private database;
    public basket;
    public page;
    public payment_gateways;
    public menu;
    public site;

    private valid_columns = [
        "url",
        "name",
        "status",
        "meta_keywords",
        "meta_author",
        "meta_description",
        "type",
        "event_on",
        "event_length",
        "created_at",
        "updated_at"
    ];

    private valid_dir = [
        "ASC",
        "DESC"
    ];

    public function __construct(object page)
    {
        var site, cfg, libs;
        let cfg = constant("CFG");
        let libs = constant("LIBS");

        let this->cfg = cfg;
        let this->libs = libs;
        let this->page = page;
        let this->database = new Database();

        let site = this->database->get("
        SELECT
            settings.*,
            themes.folder AS theme
        FROM 
            settings
        JOIN themes ON themes.id=settings.theme_id LIMIT 1");

        let site->theme_folder = "/website/themes/" . trim(site->theme, "/") . "/";
        let site->theme = site->theme_folder . "theme.css";
        let site->mode = this->cfg->mode;
        let site->dumb_dog_url = this->cfg->dumb_dog_url;
        
        let this->site = site;

        let this->payment_gateways = new PaymentGateways();
        let this->captcha = new Captcha();
        let this->basket = new Basket();
    }

    public function addComment(array data)
    {
        var security, status;
        let security = new Security();

        let data["content"] = security->clean(data["content"]);
        let data["created_by"] = this->database->system_uuid;
        let data["updated_by"] = this->database->system_uuid;

        let status = this->database->execute(
            "INSERT INTO comments 
                (id,
                content,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :content,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            return false;
        }

        return true;
    }

    public function addMessage(array data)
    {
        let data["type"] = "inbox";
        return (new Messages())->save(data);
    }

    private function addStacks(data)
    {
        var item, item_sub;

        for item in data {
            let item->stacks = this->database->all("
            SELECT *
            FROM content_stacks
            WHERE content_id='" . item->id . "' AND deleted_at IS NULL AND content_stack_id IS NULL");
            for item_sub in item->stacks {
                let item_sub->stacks = this->database->all("
                SELECT *
                FROM content_stacks
                WHERE content_stack_id='" . item_sub->id . "' AND deleted_at IS NULL");                
            }
        }

        return data;
    }

    public function appointments(array filters = [])
    {
        var query, data = [];        

        let query = "SELECT
            appointments.*,
            users.nickname AS user, 
            IFNULL(CONCAT('/website/files/', users.file), '') AS filename,
            IFNULL(CONCAT('/website/files/thumb-', users.file), '') AS thumbnail  
        FROM appointments 
        LEFT JOIN users ON users.id=appointments.user_id 
        WHERE appointments.free_slot=1 AND appointments.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "order":
                        let query .= " " . value;
                        break;
                    case "where":
                        if (isset(value["query"])) {
                            let query .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        let query .= "";
                        continue;
                }
            }
        }

        return this->database->all(query, data);
    }

    public function bookAppointment(array data)
    {
        var model, security;
        let security = new Security();

        let model = this->database->get(
            "SELECT * FROM appointments WHERE free_slot=1 AND id=:id",
            ["id": data["id"]]
        );
        if (empty(model)) {
            throw new Exception("Failed to find the appointment");
        }

        let data["updated_by"] = this->database->system_uuid;
        let data["content"] = security->clean(data["content"]);
        
        return this->database->execute(
            "UPDATE appointments SET 
                name=:name,
                content=:content, 
                free_slot=0,
                updated_at=NOW(), 
                updated_by=:updated_by
            WHERE id=:id",
            data
        );
    }

    public function canonical(string url)
    {
        return this->site->domain . "/" . trim(url, "/");
    }

    public function comments(array filters = [])
    {
        var query, where, data = [];

        let query = "
        SELECT
            comments.id,
            comments.name,
            comments.content
        FROM comments";
        let where = " WHERE comments.reviewed = 1 AND comments.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "random":
                        let where .= " ORDER BY RAND() LIMIT " . intval(value);
                        break;
                    case "order":
                        let where .= " " . value;
                        break;
                    case "where":
                        if (isset(value["query"])) {
                            let where .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        continue;
                }
            }
        }

        return this->database->all(query . where, data);
    }

    public function countries(array filters = [])
    {
        var query, where, data = [];

        let query = "
        SELECT
            countries.id,
            countries.name,
            countries.is_default 
        FROM countries";
        let where = " WHERE countries.deleted_at IS NULL AND countries.status = 'active'";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "where":
                        if (isset(value["query"])) {
                            let where .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        continue;
                }
            }
        }

        let where .= " ORDER BY is_default DESC, name";

        return this->database->all(query . where, data);
    }

    public function currencies(array filters = [])
    {
        var query, where, data = [];

        let query = "
        SELECT
            currencies.id,
            currencies.title,
            currencies.is_default,
            currencies.symbol
        FROM currencies";
        let where = " WHERE currencies.deleted_at IS NULL AND currencies.status = 'active'";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "where":
                        if (isset(value["query"])) {
                            let where .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        continue;
                }
            }
        }

        let where .= " ORDER BY is_default DESC, name";

        return this->database->all(query . where, data);
    }

    public function events(array filters = [])
    {
        return this->pageQuery(filters, "event");
    }

    public function filesByTag(string tag)
    {
        var query;

        let query = "
        SELECT
            name,
            mime_type,
            CONCAT('/website/files/', filename) AS filename,
            CONCAT('/website/files/thumb-', filename) AS thumbnail  
        FROM files 
        WHERE tags like :tag AND deleted_at IS NULL";

        return this->database->all(query, ["tag": "%{\"value\":\"" . tag . "\"}%"]);
    }

    public function imageHeight(string image)
    {
        var sizes;
        let sizes = getimagesize(getcwd() . image);

        return isset(sizes[1]) ? sizes[1] : "100%";
    }

    public function imageWidth(string image)
    {
        var sizes;
        let sizes = getimagesize(getcwd() . image);

        return isset(sizes[0]) ? sizes[0] : "100%";
    }

    public function menusByTag(string tag)
    {
        var query, results, item;

        let query = "
        SELECT
            menus.*,
            content.*,
            content.sub_title AS alt,
            IF(link.url IS NOT NULL, link.url, content.url) AS url
        FROM content 
        JOIN menus ON menus.content_id = content.id 
        LEFT JOIN content AS link ON link.id = menus.link_to AND link.deleted_at IS NULL 
        WHERE content.tags LIKE :tag AND content.deleted_at IS NULL AND content.type='menu' 
        ORDER BY content.sort ASC";

        let results = this->database->all(query, ["tag": "%{\"value\":\"" . tag . "\"}%"]);

        for item in results {
            let item = this->menuItems(item);
        }

        return results;
    }

    private function menuItems(item)
    {
        //var child;

        let item->items = this->database->all("
            SELECT
                menus.*,
                content.*,
                content.sub_title AS alt,
                IF(link.url IS NOT NULL, link.url, content.url) AS url
            FROM content 
            JOIN menus ON menus.content_id = content.id 
            LEFT JOIN content AS link ON link.id = menus.link_to AND link.deleted_at IS NULL 
            WHERE content.parent_id=:parent_id AND content.deleted_at IS NULL AND content.type='menu-item' 
            ORDER BY content.sort ASC",
            [
                "parent_id": item->id
            ]
        );

        /*let item->children = this->database->all("
        SELECT
            menus.*,
            IF(content.url IS NOT NULL, content.url, menus.url) AS url
        FROM menus 
        LEFT JOIN content ON content.id = menus.content_id AND content.deleted_at IS NULL 
        WHERE menus.parent_id='" . item->id . "' AND menus.deleted_at IS NULL
        ORDER BY sort ASC");

        for child in item->children {
            let child = this->menuItems(child);
        }*/

        return item;
    }

    public function metaDate(string datetime)
    {
        var err;

        try {
            return date("l, F d, H:i a", strtotime(datetime));
        } catch \Exception, err {
            if (err) {
                //stopping compile warning
            }
            echo "Failed to render date";
        }
    }

    public function pages(array filters = [])
    {
        return this->pageQuery(filters);
    }

    private function pageQuery(array filters, string type = "page")
    {
        var query, where, join = "", data = [], order = "", item, key, files;
        let files = new Files();
        
        let query = "
        SELECT
            content.*,
            IF(banner.filename IS NOT NULL, CONCAT('" . files->folder . "', banner.filename), '') AS banner_image,
            IF(banner.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', banner.filename), '') AS banner_thumbnail,
            templates.file AS template";

        let join = " FROM content 
        LEFT JOIN files AS banner ON banner.resource_id = content.id AND resource='banner-image'
        JOIN templates ON templates.id=content.template_id";

        let where = " WHERE content.status='live' AND content.deleted_at IS NULL AND content.type = '" . type . "'";

        if (count(filters)) {
            for key, item in filters {
                switch (key) {
                    case "children":
                        let where .= " AND parent_id=:parent_id";
                        let data["parent_id"] = item;
                        break;
                    case "random":
                        let order .= " ORDER BY RAND() LIMIT " . intval(item);
                        break;
                    case "order":
                        var splits, check, id = 0;
                        let splits = explode(" ", item);
                        let check = reset(splits);
                        if (in_array(check, this->valid_columns)) {
                            let order = " ORDER BY ". check;
                            let id = count(splits);
                            let id -= 1;
                            let check = splits[id];
                            if (in_array(strtoupper(check), this->valid_dir)) {
                                let order .= " ". check;
                            }
                        }
                        break;
                    case "tag":
                        let where .= " AND tags like :tag";
                        let data["tag"] = "%{\"value\":\"" . item . "\"}%";
                        break;
                    case "where":
                        if (isset(item["query"])) {
                            let where .= " AND " . item["query"];
                        }
                        if (isset(item["data"])) {
                            let data = array_merge(data, item["data"]);
                        }
                        break;
                    default:
                        continue;
                }
            }
        }
        
        let data = this->database->all(query . join . where . order, data);

        let data = this->addStacks(data);

        return data;
    }

    public function prettyDate(
        string datetime,
        bool time = true,
        bool seconds = true,
        bool today = false,
        string unknown = "Unknown"
    ) {
        return (new Dates())->prettyDate(datetime, time, seconds, today, unknown);
    }

    public function prettyDateFull(
        string datetime,
        bool time = true,
        bool seconds = true,
        bool today = false,
        string unknown = "Unknown"
    ) {
        return (new Dates())->prettyDateFull(datetime, time, seconds, today, unknown);
    }

    public function products(array filters = [])
    {
        return (new Products())->get(filters);
    }

    public function productCategories(array filters = [])
    {
        return (new ProductCategories())->get(filters);
    }

    public function randomString(int length = 64)
    {
        var security;
        let security = new Security();
        return security->randomString(length);
    }

    public function reviews(array filters = [])
    {
        return this->pageQuery(filters, "review");
    }

    public function session(string name, value = null)
    {
        return this->basket->session(name, value);
    }

    public function socials()
    {
        var files;
        let files = new Files();

        return this->database->all("
        SELECT
            content.*,
            IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
            IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
        FROM content 
        LEFT JOIN files ON files.resource_id = content.id AND files.deleted_at IS NULL 
        WHERE content.deleted_at IS NULL AND content.type='social' 
        ORDER BY content.sort ASC");
    }

    public function stacksByTag(string tag, string id = "")
    {
        var query, results, item, files, data = [];

        let data["tag"] = "%{\"value\":\"" . tag . "\"}%";

        let files = new Files();

        let query = "
        SELECT
            content_stacks.*,
            IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
            IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
        FROM content_stacks 
        LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
        WHERE content_stacks.tags like :tag AND content_stacks.deleted_at IS NULL";
        if (id) {
            let query .= " AND content_id=:content_id";
            let data["content_id"] = id;
        }
        let query .= " ORDER BY sort ASC";

        let results = this->database->all(query, data);

        for item in results {
            let item->stacks = this->database->all("
            SELECT
                content_stacks.*,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail  
            FROM content_stacks
            LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
            WHERE content_stack_id='" . item->id . "' AND content_stacks.deleted_at IS NULL
            ORDER BY sort ASC");
        }

        return results;
    }

    public function toCurrency(number)
    {
        return number_format(floatval(number), 2);
    }
}