/**
 * Dumb Dog leads
 *
 * @package     DumbDog\Controllers\Leads
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Contacts;
use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Ui\Gfx\Table;

class Leads extends Content
{
    public global_url = "/leads";
    public list = [
        "full_name|with_tags",
        "email|decrypt",
        "phone|decrypt",
        "owner"
    ];
    public required = ["first_name"];
    public title = "Leads";
    public type = "lead";

    public function add(string path)
    {
        var html, data;
                
        let html = this->titles->page("Create a menu", "menus");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["name"] = _POST["name"];
                    let data["title"] = _POST["title"];
                    let data["alt"] = _POST["alt"];
                    let data["url"] = _POST["url"];
                    let data["content_id"] = _POST["content_id"];
                    let data["parent_id"] = _POST["parent_id"];
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();
                    let data["tags"] = this->inputs->isTagify(_POST["tags"]);
                    
                    let status = this->database->execute(
                        "INSERT INTO menus 
                            (id,
                            name,
                            title,
                            alt,
                            url,
                            tags,
                            parent_id,
                            content_id,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :title,
                            :alt,
                            :url,
                            :tags,
                            :parent_id,
                            :content_id,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the menu");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Menu has been saved");
        }

        var model;
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->alt = "";
        let model->url = "";
        let model->sort = "";
        let model->content_id = "";

        let html .= this->render(model);

        return html;
    }

    public function edit(string path)
    {
        var html, model, data = [], contacts, err;

        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                users.nickname AS owner,
                contacts.*,
                leads.id,
                leads.contact_id,
                leads.ranking 
            FROM leads
            JOIN contacts ON contacts.id = leads.contact_id 
            LEFT JOIN users ON users.id = leads.user_id 
            WHERE leads.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Lead not found");
        }

        let html = this->titles->page("Manage the lead", "edit");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("Lead item has been deleted");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let contacts = new Contacts(this->cfg, this->libs);

        let model = this->database->decrypt(
            contacts->encrypt,
            model
        );

        if (!empty(_POST)) {
            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("leads", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("leads", path);
                }
            }

            if (!this->validate(_POST, contacts->required)) {
                let html .= this->missingRequired();
            } else {
                
                this->notes->actions(model->id);
                let data = this->setData(data);
                try {
                    contacts->update(model->contact_id);
                    this->redirect(path . "?saved=true");
                } catch ValidationException, err {
                    this->missingRequired(err->getMessage());
                }
            }
        }
        
        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the lead");
        }

        let html .= this->render(model, "edit");
        return html;
    }

    private function render(model, mode = "add")
    {
        var html;

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-row'>
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title'>
                            <span>Ranking</span>
                        </div>
                        <div class='dd-box-body dd-flex'>
                            <div class='dd-switcher'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='poor' " . 
                                        (model->ranking == "poor" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingPoor() .
                                    "   Good
                                    </span>
                                </label>
                            </div>
                            <div class='dd-switcher'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='good' " . 
                                        (model->ranking == "good" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingGood() .
                                    "   Good
                                    </span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='lead-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>
                                    <div class='dd-row'>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("First name", "first_name", "Set their first name", true, model->first_name) .
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Last name", "last_name", "Set their last name", false, model->last_name) .
                                        "</div>
                                    </div> 
                                    <div class='dd-row'>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Email", "email", "Set their email", false, model->email) .
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Phone", "phone", "Set their phone", false, model->phone) .
                                        "</div>
                                    </div> 
                                    <div class='dd-row'>
                                        <div class='dd-col-6'>" .
                                            
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Position", "position", "What is their position?", false, model->position) .
                                        "</div>
                                    </div>" . 
                                    this->inputs->text("Website", "website", "Do they have a website?", false, model->website) .
                                    this->inputs->tags("Tags", "tags", "Tag the menu", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>";

        if (mode == "edit") {
            let html .= this->notes->render(model->id);
        }

        let html .= "</div>
                <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#lead-tab'
                            aria-controls='lead-tab' 
                            aria-selected='true'>Lead</button>
                    </li>";

        if (mode == "edit") {
            let html .= "
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#messages-tab'
                            aria-controls='messages-tab' 
                            aria-selected='true'>Messages</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#notes-tab'
                            aria-controls='notes-tab' 
                            aria-selected='true'>Notes</button>
                    </li>";
        }

        let html .= "<li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>" . 
                        this->buttons->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {
            if (model->website) {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->view(model->website) .
                "</li>";
            }
            if (model->deleted_at) {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->recover(model->id) . 
                "</li>";
            } else {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->delete(model->id) . 
                "</li>";
            }
        }

        let html .= "<li class='dd-nav-item' role='presentation'>". 
                        this->buttons->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }

    public function renderList(string path)
    {
        var data = [], query, table;

        let table = new Table(this->cfg);

        let query = "
            SELECT 
                users.nickname AS owner,
                contacts.*,
                leads.id 
            FROM leads
            JOIN contacts ON contacts.id = leads.contact_id 
            LEFT JOIN users ON users.id = leads.user_id 
            WHERE leads.id IS NOT NULL ";

        if (isset(_POST["q"])) {
            let query .= " AND contacts.first_name=:first_name";
            let data["first_name"] = this->database->encrypt(_POST["q"]);
        }
        if (isset(_GET["tag"])) {
            let query .= " AND leads.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }

        if (!this->database->isManager()) {
            let data["user_id"] = this->getUserId();
        }

        let data = this->database->all(query, data);
        for query in data {
            if (isset(query->first_name) && isset(query->last_name)) {
                let query->full_name = this->database->decrypt(query->first_name) . " " . this->database->decrypt(query->last_name);
            } elseif (isset(query["first_name"])) {
                let query->full_name = this->database->decrypt(query->first_name);
            }
        }

        return table->build(
            this->list,
            data,
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->add(this->global_url . "/add") .
        "</div>";
    }

    private function setData(data)
    {
        return data;
    }
}