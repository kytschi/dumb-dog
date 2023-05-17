/**
 * Dumb Dog helper
 *
 * @package     DumbDog\Helper\DumbDog
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
namespace DumbDog\Helper;

use DumbDog\Controllers\Database;
use DumbDog\Controllers\Pages;
use DumbDog\Exceptions\Exception;
use DumbDog\Helper\Security;
use DumbDog\Ui\Captcha;

class DumbDog
{
    private cfg;
    protected system_uuid = "00000000-0000-0000-0000-000000000000";

    public captcha;
    public page;
    public menu;
    public site;

    public function __construct(object cfg, object page)
    {
        var database, data, site, menu;

        let this->cfg = cfg;
        let this->page = page;

        let database = new Database(cfg);

        let site = database->get("
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

        let site->theme_folder = "/website/themes/" . site->theme;
        let site->theme = site->theme_folder . "/theme.css";

        let this->site = site;

        let this->captcha = new Captcha();

        let menu = new \stdClass();
        let menu->header = [];
        let menu->footer = [];
        let menu->both = [];

        let data = database->all("SELECT name, url FROM pages WHERE menu_item='header' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
        if (data) {
            let menu->header = data;
        }

        let data = database->all("SELECT name, url FROM pages WHERE menu_item='footer' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
        if (data) {
            let menu->footer = data;
        }

        let data = database->all("SELECT name, url FROM pages WHERE menu_item='both' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
        if (data) {
            let menu->both = data;
        }
        let this->menu = menu;
    }

    public function addComment(array data)
    {
        var database, security, status;
        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let data["content"] = security->clean(data["content"]);
        let data["created_by"] = this->system_uuid;
        let data["updated_by"] = this->system_uuid;

        let status = database->execute(
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
        var database, security, status;
        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let data["from_email"] = security->encrypt(data["from_email"]);
        let data["from_name"] = security->encrypt(data["from_name"]);
        let data["from_number"] = security->encrypt(data["from_number"]);
        let data["message"] = security->encrypt(security->clean(data["message"]));
        let data["to_name"] = "dumb dog";
        let data["created_by"] = this->system_uuid;
        let data["updated_by"] = this->system_uuid;

        let status = database->execute(
            "INSERT INTO messages 
                (id,
                subject,
                from_email,
                from_name,
                from_number,
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
    }

    public function appointments(array filters = [])
    {
        var database, query, where, data = [];
        let database = new Database(this->cfg);

        let query = "
        SELECT * FROM appointments";
        let where = " WHERE free_slot=1 AND appointments.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
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

        return database->all(query . where, data);
    }

    public function bookAppointment(array data)
    {
        var database, model, security;
        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let model = database->get(
            "SELECT * FROM appointments WHERE free_slot=1 AND id=:id",
            ["id": data["id"]]
        );
        if (empty(model)) {
            throw new Exception("Failed to find the appointment");
        }

        let data["updated_by"] = this->system_uuid;
        let data["content"] = security->clean(data["content"]);
        
        return database->execute(
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

    public function comments(array filters = [])
    {
        var database, query, where, data = [];
        let database = new Database(this->cfg);

        let query = "
        SELECT
            comments.name,
            comments.content
        FROM comments";
        let where = " WHERE comments.reviewed = 1 AND comments.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
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

        return database->all(query . where, data);
    }

    public function events(array filters = [])
    {
        return this->pageQuery(filters, "event");
    }

    public function filesByTag(string tag)
    {
        var database, query;
        let database = new Database(this->cfg);

        let query = "
        SELECT
            name,
            mime_type,
            CONCAT('/website/files/', filename) AS filename 
        FROM files 
        WHERE tags like :tag AND deleted_at IS NULL";

        return database->all(query, ["tag": "%{\"value\":\"" . tag . "\"}%"]);
    }

    public function pages(array filters = [])
    {
        return this->pageQuery(filters);
    }

    private function pageQuery(array filters, string type = "page")
    {
        var database, query, where, data = [];
        let database = new Database(this->cfg);

        let query = "
        SELECT
            pages.*,
            templates.file AS template
        FROM pages 
        JOIN templates ON templates.id=pages.template_id";

        let where = " WHERE pages.status='live' AND pages.deleted_at IS NULL";
        if (type == "event") {
            let where .= " AND pages.type = 'event'";
        } else {
            let where .= " AND pages.type != 'event'";
        }

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "children":
                        let where .= " AND parent_id=:parent_id";
                        let data["parent_id"] = value;
                        break;
                    case "order":
                        let where .= " " . value;
                        break;
                    case "tag":
                        let where .= " AND tags like :tag";
                        let data["tag"] = "%{\"value\":\"" . value . "\"}%";
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

        return database->all(query . where, data);
    }
}