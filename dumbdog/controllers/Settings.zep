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
    public function index(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let model = database->get("SELECT * FROM settings LIMIT 1");

        if (empty(model)) {
            throw new NotFoundException("Settings not found");
        }

        let html = titles->page("Site settings", "settings");
        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/themes' class='dd-link round icon icon-themes' title='Managing the themes'>&nbsp;</a>
            <a href='/dumb-dog/users' class='dd-link round icon icon-users' title='Manage the users'>&nbsp;</a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "theme_id"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["theme_id"] = _POST["theme_id"];
                    let data["status"] = _POST["status"] ? "online" : "offline";
                    let data["meta_description"] = _POST["meta_description"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                    let data["robots_txt"] = _POST["robots_txt"];

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE settings
                        SET 
                            name=:name,
                            theme_id=:theme_id,
                            `status`=:status,
                            meta_description=:meta_description,
                            meta_author=:meta_author,
                            meta_keywords=:meta_keywords,
                            robots_txt=:robots_txt
                        WHERE name IS NOT NULL",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the settings");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/settings?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the settings");
        }

        let html .= "<form method='post'><div class='box dd-wfull'>
            <div class='box-title'>
                <span>the settings</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>online</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='status' value='1'";
                if (model->{"status"} == "online") {
                    let html .= " checked='checked'";
                }
                
                let html .= ">
                            <span>
                                <small class='switcher-on'></small>
                                <small class='switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>";
            let html .= this->createInputText("name", "name", "make sure to set a name", true, model->name);
            let html .= "
                <div class='input-group'>
                    <span>theme<span class='required'>*</span></span>
                    <select name='theme_id'>";
        let data = database->all("SELECT * FROM themes WHERE deleted_at IS NULL ORDER BY `default` DESC");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == model->theme_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>meta author</span>
                    <input type='text' name='meta_author' placeholder='who made this?' value='" . model->meta_author . "'>
                </div>
                <div class='input-group'>
                    <span>meta keywords</span>
                    <input type='text' name='meta_keywords' placeholder='list some keywords for the site' value='" . model->meta_keywords . "'>
                </div>
                <div class='input-group'>
                    <span>meta description</span>
                    <textarea name='meta_description' placeholder='describe the site a bit'>" . model->meta_description . "</textarea>
                </div>
                <div class='input-group'>
                    <span>robots.txt</span>
                    <textarea name='robots_txt' placeholder='some text for robots'>" . model->robots_txt . "</textarea>
                </div>
            </div>
            <div class='box-footer'>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div>
        </div></form>";

        return html;
    }
}