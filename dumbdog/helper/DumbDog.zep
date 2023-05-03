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
use DumbDog\Ui\Captcha;

class DumbDog
{
    public captcha;
    public cfg;
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
        var database, query, where;
        let database = new Database(this->cfg);

        let query = "
        SELECT
            pages.name,
            pages.url,
            pages.content,
            pages.meta_keywords,
            pages.meta_description,
            pages.meta_author,
            pages.event_on,
            pages.event_length,
            pages.type,
            templates.file AS template
        FROM pages 
        JOIN templates ON templates.id=pages.template_id";
        let where = " WHERE pages.status='live' AND pages.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "where":
                        let where .= " AND " . value;
                        break;
                    default:
                        continue;
                }
            }
        }

        return database->all(query . where);
    }
}