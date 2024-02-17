/**
 * Dumb Dog settings builder
 *
 * @package     DumbDog\Controllers\Settings
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
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

class Settings extends Content
{
    public function index(string path)
    {
        var html, model, data = [], status = false;

        let model = this->database->get("SELECT * FROM settings LIMIT 1");

        if (empty(model)) {
            throw new NotFoundException("Settings not found");
        }

        let html = this->titles->page("Site settings", "settings");
        
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
                        this->redirect("/dumbdog/settings?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Settings have been updated");
        }

        let html .= this->renderToolbar();

        let html .= "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs dd-mt-4'>
                <div class='dd-tabs-content dd-col'>
                    <div id='settings-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                this->inputs->toggle("Online", "status", false, (model->status=="online" ? 1 : 0)) . 
                                this->inputs->text("name", "name", "make sure to set a name", true, model->name) .
                                this->inputs->text("Domain", "domain", "Your domain, i.e. https://example.com", true, model->domain) .
                                this->inputs->text("Contact email", "contact_email", "hello@example.com", false, model->contact_email) .
                                this->inputs->text("Phone", "phone", "0123456789", false, model->phone) .
                            "   </div>
                            </div>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>".
                                this->inputs->selectDB(
                                    "Theme",
                                    "theme_id",
                                    "Your current theme",
                                    "SELECT * FROM themes WHERE deleted_at IS NULL ORDER BY `default` DESC",
                                    true,
                                    model->theme_id
                                ) .
                            "   </div>
                            </div>
                        </div>
                    </div>
                    <div id='seo-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>".
                                this->inputs->text("Meta author", "meta_author", "Author of your site", false, model->meta_author) .
                                this->inputs->text("Meta keywords", "meta_keywords", "Keywords to describe your site", false, model->meta_keywords) .
                                this->inputs->textarea("Meta description", "meta_description", "A short description of your site", false, model->meta_description) .
                                this->inputs->textarea("Robots txt", "robots_txt", "robots.txt configuration", false, model->robots_txt) .
                                "</div>
                            </div>
                        </div>
                    </div>
                </div>
                <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
                    <li class='dd-nav-item' role='presentation'>
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
                            aria-selected='true'>Look and feel</button>
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
                        this->buttons->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->round(
                this->cfg->dumb_dog_url . "/countries",
                "countries",
                "countries",
                "Manage the countries"
            ) .
        "</div>";
    }
}