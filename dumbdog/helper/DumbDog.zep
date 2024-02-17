/**
 * Dumb Dog helper
 *
 * @package     DumbDog\Helper\DumbDog
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Helper;

use DumbDog\Controllers\Basket;
use DumbDog\Controllers\Content;
use DumbDog\Controllers\Database;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\PaymentGateways;
use DumbDog\Controllers\Products;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Security;
use DumbDog\Ui\Captcha;

class DumbDog
{
    private cfg;
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

    public function __construct(object cfg, object page)
    {
        var site;

        let this->cfg = cfg;
        let this->page = page;
        let this->database = new Database(cfg);

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
        if (isset(this->cfg->gateway)) {
            if (isset(this->cfg->gateway->stripe)) {
                let site->stripe_api_key = this->cfg->gateway->stripe->public_api_key;
                let this->payment_gateways = new PaymentGateways(this->cfg);
            }
        }

        let this->site = site;

        let this->captcha = new Captcha();
        let this->basket = new Basket(this->cfg);
    }

    public function addComment(array data)
    {
        var security, status;
        let security = new Security(this->cfg);

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
        var security, status, err;
        let security = new Security(this->cfg);        

        if (!isset(data["subject"])) {
            let data["subject"] = "Web form contact";
        } elseif (empty(data["subject"])) {
            let data["subject"] = "Web form contact";
        }

        if (!isset(data["from_email"]) || !isset(data["from_number"]) || !isset(data["message"])) {
            throw new ValidationException("Missing required");
        }

        let data["subject"] = security->encrypt(security->clean(data["subject"]));
        let data["from_email"] = security->encrypt(security->clean(data["from_email"]));
        let data["from_name"] = security->encrypt(security->clean(data["from_name"]));
        let data["message"] = security->encrypt(security->clean(data["message"]));

        if (isset(data["from_number"])) {
            let data["from_number"] = security->encrypt(security->clean(data["from_number"]));
        } else {
            let data["from_number"] = null;
        }
        if (isset(data["from_company"])) {
            let data["from_company"] = security->encrypt(security->clean(data["from_company"]));
        } else {
            let data["from_company"] = null;
        }
        
        let data["to_name"] = this->site->name;
        let data["created_by"] = this->database->getUserId();
        let data["updated_by"] = this->database->getUserId();

        try {
            let status = this->database->execute(
                "INSERT INTO messages 
                    (id,
                    subject,
                    from_email,
                    from_name,
                    from_number,
                    from_company,
                    message,
                    to_name,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by) 
                VALUES 
                    (UUID(),
                    :subject,
                    :from_email,
                    :from_name,
                    :from_number,
                    :from_company,
                    :message,
                    :to_name,
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
        } catch Exception, err {
            throw new Exception("Failed to save the message", err);
        }
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
        let security = new Security(this->cfg);

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
        var query, results, item, files;

        let files = new Files(this->cfg);

        let query = "
        SELECT
            menus.*,
            IF(content.url IS NOT NULL, content.url, menus.url) AS url
        FROM menus 
        LEFT JOIN content ON content.id = menus.content_id AND content.deleted_at IS NULL 
        WHERE menus.tags like :tag AND menus.deleted_at IS NULL
        ORDER BY sort ASC";

        let results = this->database->all(query, ["tag": "%{\"value\":\"" . tag . "\"}%"]);

        for item in results {
            let item = this->menuItems(item);
        }

        return results;
    }

    private function menuItems(item)
    {
        var child;

        let item->items = this->database->all("
        SELECT
            menus.*,
            IF(content.url IS NOT NULL, content.url, menus.url) AS url
        FROM menus 
        LEFT JOIN content ON content.id = menus.content_id AND content.deleted_at IS NULL 
        WHERE menu_id='" . item->id . "' AND menus.deleted_at IS NULL
        ORDER BY sort ASC");

        let item->children = this->database->all("
        SELECT
            menus.*,
            IF(content.url IS NOT NULL, content.url, menus.url) AS url
        FROM menus 
        LEFT JOIN content ON content.id = menus.content_id AND content.deleted_at IS NULL 
        WHERE menus.parent_id='" . item->id . "' AND menus.deleted_at IS NULL
        ORDER BY sort ASC");

        for child in item->children {
            let child = this->menuItems(child);
        }

        return item;
    }

    public function pages(array filters = [])
    {
        return this->pageQuery(filters);
    }

    private function pageQuery(array filters, string type = "page")
    {
        var query, where, join = "", data = [], order = "", item, key, files;
        let files = new Files(this->cfg);
        
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
        bool today = false,
        string unknown = "Unknown",
        bool seconds = true
    ) {
        var timestamp, err;

        try {
            if (empty(datetime)) {
                if (today) {
                    return today ? date(time ? (seconds ? "d/m/Y H:i:s" : "d/m/Y H:i") : "d/m/Y") : unknown;
                }
                return unknown;
            }

            if (strtolower(datetime) == "unknown") {
                return unknown;
            }
            let timestamp = strtotime(datetime);
            if (empty(timestamp)) {
                let timestamp = strtotime("NOW");
            }
            return date(
                time ? (seconds ? "d/m/Y H:i:s" : "d/m/Y H:i") : "d/m/Y",
                timestamp
            );
        } catch Exception, err {
            return err ? "Failed to render the date" : "Failed to render the date";
        }
    }

    public function prettyDateFull(
        string datetime,
        bool time = true,
        bool today = false,
        string unknown = "Unknown",
        bool seconds = true
    ) {
        var timestamp, err;

        try {
            if (empty(datetime)) {
                if (today) {
                    return today ? date(time ? (seconds ? "M dS, Y H:i:s" : "M dS, Y H:i") : "M dS, Y") : unknown;
                }
                return unknown;
            }
            if (strtolower(datetime) == "unknown") {
                return unknown;
            }

            let timestamp = strtotime(datetime);
            if (empty(timestamp)) {
                let timestamp = strtotime("NOW");
            }
            return date(time ? "M jS, Y H:i" : "M jS, Y", timestamp);
        } catch Exception, err {
            return err ? "Failed to render the date" : "Failed to render the date";
        }
    }

    public function products(array filters = [])
    {
        return (new Products(this->cfg))->get(filters);
    }

    public function randomString(int length = 64)
    {
        var security;
        let security = new Security(this->cfg);
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
        let files = new Files(this->cfg);

        return this->database->all("
        SELECT
            socials.*,
            IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
            IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
        FROM socials 
        LEFT JOIN files ON files.resource_id = socials.id AND files.deleted_at IS NULL 
        WHERE socials.deleted_at IS NULL
        ORDER BY sort ASC");
    }

    public function stacksByTag(string tag, string id = "")
    {
        var query, results, item, files, data = [];

        let data["tag"] = "%{\"value\":\"" . tag . "\"}%";

        let files = new Files(this->cfg);

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