/**
 * Dumb Dog templates builder
 *
 * @package     DumbDog\Controllers\Templates
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;

class Templates extends Content
{
    public global_url = "/templates";
    public back_url = "/pages";
    public required = ["name", "file", "type"];

    public routes = [
        "/templates/add": [
            "Templates",
            "add",
            "add a template"
        ],
        "/templates/edit": [
            "Templates",
            "edit",
            "edit the template"
        ],
        "/templates": [
            "Templates",
            "index",
            "templates"
        ]
    ];

    public function add(path)
    {
        var html, data, model;
        
        let html = this->titles->page(
            "Add a template",
            "add"
        );

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let path = this->global_url;

                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->getUserId();
                                        
                    let data = this->setData(data);

                    let status = this->database->execute(
                        "INSERT INTO templates  
                            (id,
                            type,
                            name,
                            file,
                            is_default,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (
                            :id,
                            :type,
                            :name,
                            :file,
                            :is_default,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the template");
                        let html .= this->consoleLogError(status);
                    } else {
                        let path = path . "?saved=true";
                        let model = this->database->get(
                            "SELECT * FROM templates WHERE id=:id",
                            [
                                "id": data["id"]
                            ]);
                        
                        this->redirect(this->global_url . "/edit/" . data["id"]);
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Entry has been saved");
        }

        let model = new \stdClass();
        let model->deleted_at = null;
        let model->type = "page";
        let model->name = "";
        let model->file = "";
        let model->is_default = 0;
        let model->id = "";
        
        let html .= this->render(model);

        return html;
    }

    public function edit(path)
    {
        var html, model, data = [], status = false;
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Template not found");
        }

        let html = this->titles->page("Edit the template", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            let path = this->global_url . "/edit/" . model->id;
            
            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("templates", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("templates", path);
                }
            }

            if (isset(_POST["save"])) {
                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
                    let data["updated_by"] = this->database->getUserId();

                    if (data["is_default"]) {
                        this->clearDefault(
                            "templates",
                            data["updated_by"]
                        );
                    }

                    let status = this->database->execute(
                        "UPDATE templates SET 
                            name=:name,
                            file=:file,
                            type=:type,
                            `is_default`=:is_default,
                            updated_at=NOW(),
                            updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the template");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the template");
        }

        let html .= this->render(model, "edit");

        return html;
    }

    public function index(path)
    {
        var html;
                
        let html = this->titles->page("Templates", "templates");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the template");
        }

        let html .= 
            this->renderToolbar() .
            this->inputs->searchBox(this->global_url, "Search the " . strtolower(this->title)) . 
            this->renderList(path);

        return html;
    }

    public function render(model, mode = "add")
    {
        var html;

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='content-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Default", "is_default", false, model->is_default) . 
                                    this->inputs->text("Name", "name", "Name the page", true, model->name) .
                                    this->inputs->text("File", "file", "The template's file", true, model->file) .
                                    this->inputs->select(
                                        "type",
                                        "type",
                                        "The template's type",
                                        [
                                            "page": "Page",
                                            "content-stack": "Content stack"
                                        ],
                                        true,
                                        model->type
                                    ) .
                                "
                                </div>
                            </div>
                        </div>
                    </div>
                </div>" .
                this->renderSidebar(model, mode) .
            "</div>
        </form>";

        return html;
    }

    public function renderList(path)
    {
        var data = [], query;

        let query = "
            SELECT * 
            FROM templates 
            WHERE id IS NOT NULL";
        if (isset(_POST["q"])) {
            let query .= " AND name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        let query .= " ORDER BY `is_default` DESC, name ASC";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderSidebar(model, mode = "add")
    {
        var html = "";
        let html = "
        <ul class='dd-col dd-nav-tabs' role='tablist'>
            <li class='dd-nav-item' role='presentation'>
                <div id='dd-tabs-toolbar'>
                    <div id='dd-tabs-toolbar-buttons' class='dd-flex'>". 
                        this->buttons->generic(
                            this->global_url,
                            "",
                            "back",
                            "Go back to the list"
                        ) .
                        this->buttons->save() . 
                        this->buttons->generic(
                            this->global_url . "/add",
                            "",
                            "add",
                            "Add a new template"
                        );
        if (mode == "edit") {
            if (model->deleted_at) {
                let html .= this->buttons->recover(model->id);
            } else {
                let html .= this->buttons->delete(model->id);
            }
        }
        let html .= "</div>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#content-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='content-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("content-tab") .
                        "Content
                    </span>
                </div>
            </li>
        </ul>";
        return html;
    }

    public function renderToolbar()
    {
        var html;
        
        let html = "<div class='dd-page-toolbar'>";

        if (this->back_url) {
            let html .= this->buttons->round(
                this->cfg->dumb_dog_url . this->back_url,
                "Back",
                "back",
                "Go back to the pages"
            );
        }

        let html .= 
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new template"
            ) .
        "</div>";

        return html;
    }

    public function setData(array data, user_id = null, model = null)
    {   
        let data["name"] = _POST["name"];
        let data["file"] = _POST["file"];
        let data["type"] = isset(_POST["type"]) ? _POST["type"] : (!empty(model) ? model->type : "page");
        let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
        let data["updated_by"] = user_id ? user_id : this->getUserId();

        return data;
    }
}