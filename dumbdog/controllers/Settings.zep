/**
 * Dumb Dog settings builder
 *
 * @package     DumbDog\Controllers\Settings
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
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
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Input;
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Settings extends Controller
{
    public function index(string path)
    {
        var titles, html, model, data = [], input, button, status = false;
        let input = new Input(this->cfg);
        let button = new Button();
        let titles = new Titles();

        let model = this->database->get("SELECT * FROM settings LIMIT 1");

        if (empty(model)) {
            throw new NotFoundException("Settings not found");
        }

        let html = titles->page("Site settings");
        
        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                if (!this->validate(_POST, ["name", "theme_id"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["domain"] = trim(_POST["domain"], "/");
                    let data["contact_email"] = _POST["contact_email"];
                    let data["phone"] = _POST["phone"];
                    let data["theme_id"] = _POST["theme_id"];
                    let data["status"] = _POST["status"] ? "online" : "offline";
                    let data["meta_description"] = _POST["meta_description"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                    let data["robots_txt"] = _POST["robots_txt"];

                    let status = this->database->execute(
                        "UPDATE settings
                        SET 
                            name=:name,
                            domain=:domain,
                            contact_email=:contact_email,
                            phone=:phone,
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
                        this->redirect("/fremen/settings?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Settings have been updated");
        }

        let html .= "
        <form method='post' enctype='multipart/form-data'>
            <div class='tabs'>
                <div class='tabs-content dd-col'>
                    <div id='settings-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <article class='dd-card'>
                                <div class='dd-card-body'>" .
                                input->toggle("Online", "status", false, (model->status=="online" ? 1 : 0)) . 
                                input->text("name", "name", "make sure to set a name", true, model->name) .
                                input->text("Domain", "domain", "Your domain, i.e. https://example.com", true, model->domain) .
                                input->text("Contact email", "contact_email", "hello@example.com", false, model->contact_email) .
                                input->text("Phone", "phone", "0123456789", false, model->phone) .
                            "   </div>
                            </article>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='col-12'>
                            <article class='dd-card'>
                                <div class='dd-card-body'>".
                                input->selectDB(
                                    "Theme",
                                    "theme_id",
                                    "Your current theme",
                                    "SELECT * FROM themes WHERE deleted_at IS NULL ORDER BY `default` DESC",
                                    true,
                                    model->theme_id
                                ) .
                            "   </div>
                            </article>
                        </div>
                    </div>
                    <div id='seo-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <article class='dd-card'>
                                <div class='dd-card-body'>".
                                input->text("Meta author", "meta_author", "Author of your site", false, model->meta_author) .
                                input->text("Meta keywords", "meta_keywords", "Keywords to describe your site", false, model->meta_keywords) .
                                input->textarea("Meta description", "meta_description", "A short description of your site", false, model->meta_description) .
                                input->textarea("Robots txt", "robots_txt", "robots.txt configuration", false, model->robots_txt) .
                                "</div>
                            </article>
                        </div>
                    </div>
                </div>
                <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
                    <li class='dd-dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#settings-tab'
                            aria-controls='settings-tab' 
                            aria-selected='true'>Settings</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#look-tab'
                            aria-controls='look-tab' 
                            aria-selected='true'>Look &amp; feel</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#seo-tab'
                            aria-controls='seo-tab' 
                            aria-selected='true'>SEO</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>". 
                        button->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }
}