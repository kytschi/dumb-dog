/**
 * Dumb Dog settings builder
 *
 * @package     DumbDog\Controllers\Settings
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
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Settings extends Controller
{
    private cfg;

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function index(string path)
    {
        var titles, html, database, page, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let page = database->get("SELECT * FROM settings LIMIT 1");

        if (empty(page)) {
            throw new NotFoundException("Settings not found");
        }

        let html = titles->page("Site settings", "/assets/settings.png");
        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/themes' class='button' title='Managing the themes'>
                <img src='/assets/themes.png'>
            </a>
            <a href='/dumb-dog/users' class='button' title='Manage the users'>
                <img src='/assets/users.png'>
            </a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "theme_id", "status"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["theme_id"] = _POST["theme_id"];
                    let data["status"] = _POST["status"];
                    let data["meta_description"] = _POST["meta_description"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                                        
                    if (this->cfg["save_mode"] == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "UPDATE settings
                            SET 
                                name=:name,
                                theme_id=:theme_id,
                                `status`=:status,
                                meta_description=:meta_description,
                                meta_author=:meta_author,
                                meta_keywords=:meta_keywords
                            WHERE name IS NOT NULL",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the settings");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've updated the settings");
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the settings</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>status<span class='required'>*</span></span>
                    <select name='status'>
                        <option value='online'";
        if (page->status == "online") {
            let html .= " selected='selected'";
        }
        let html .= ">Online</option>
                        <option value='offline'";
        if (page->status == "offline") {
            let html .= " selected='selected'";
        }
        let html .= ">Offline</option>
                    </select>
                </div>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . page->name . "'>
                </div>
                <div class='input-group'>
                    <span>meta author</span>
                    <input type='text' name='meta_author' placeholder='who made this?' value='" . page->meta_author . "'>
                </div>
                <div class='input-group'>
                    <span>meta keywords</span>
                    <input type='text' name='meta_keywords' placeholder='list some keywords for the site' value='" . page->meta_keywords . "'>
                </div>
                <div class='input-group'>
                    <span>meta description</span>
                    <textarea name='meta_description' placeholder='describe the site a bit'>" . page->meta_description . "</textarea>
                </div>
                <div class='input-group'>
                    <span>theme<span class='required'>*</span></span>
                    <select name='theme_id'>";
        let data = database->all("SELECT * FROM themes WHERE deleted_at IS NULL ORDER BY `default` DESC");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == page->theme_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
            </div>
            <div class='box-footer'>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }
}