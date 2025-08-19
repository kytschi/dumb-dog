/**
 * Dumb Dog themes
 *
 * @package     DumbDog\Controllers\Themes
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\Dates;

class Themes extends Content
{
    public global_url = "/themes";
    public back_url = "/pages";
    public required = ["name", "folder"];
    public list = [        
        "name|with_tags",
        "folder",
        "is_default|bool",
        "annual|bool",
        "active_from|date",
        "active_to|date",
        "status"
    ];

    public routes = [
        "/themes/add": [
            "Themes",
            "add",
            "add a theme"
        ],
        "/themes/edit": [
            "Themes",
            "edit",
            "edit the theme"
        ],
        "/themes": [
            "Themes",
            "index",
            "themes"
        ]
    ];

    public function add(path)
    {
        var html, data = [], status = false, model;
        let html = this->titles->page("Add a theme", "add");
        
        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data = this->setData(data);
                    let data["created_by"] = this->database->getUserId();

                    let status = this->database->execute(
                        "INSERT INTO themes 
                            (id, name, folder, `is_default`, created_at, created_by, updated_at, updated_by, status, annual, active_from, active_to) 
                        VALUES 
                            (UUID(), :name, :folder, :is_default, NOW(), :created_by, NOW(), :updated_by, :status, :annual, :active_from, :active_to)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the theme");
                    }
                }
            }
        }

        let model = new \stdClass();
        let model->deleted_at = null;
        let model->annual = 0;
        let model->active_from = null;
        let model->active_to = null;
        let model->folder = "";
        let model->name = "";
        let model->is_default = 0;
        let model->id = "";
        let model->status = "live";
        
        let html .= this->render(model);

        return html;
    }

    public function edit(path)
    {
        var html, model, data = [], status = false;
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM themes WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Theme not found");
        }

        let html = this->titles->page("Edit the theme", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("themes", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("themes", path);
                }
            }

            if (isset(_POST["save"])) {
                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data = this->setData(data);

                    let status = this->database->execute(
                        "UPDATE themes SET 
                            name=:name,
                            folder=:folder,
                            `is_default`=:is_default,
                            status=:status,
                            annual=:annual,
                            active_from=:active_from,
                            active_to=:active_to,
                            updated_at=NOW(),
                            updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("" . this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the theme");
        }

        let html .= this->render(model, "edit");

        return html;
    }

    public function index(path)
    {
        var html;
                
        let html = this->titles->page("Themes", "themes");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the theme");
        }

        let html .= 
            this->renderToolbar() .
            this->inputs->searchBox(this->global_url, "Search the themes") . 
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
                                    this->inputs->toggle("Live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                    this->inputs->text("Name", "name", "Name the theme", true, model->name) .
                                    this->inputs->text("Folder", "folder", "Where am I located?", true, model->folder) .
                                    this->inputs->toggle("Default", "is_default", false, model->is_default) . 
                                "
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id='time-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>Date schedule</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Annually recurring", "annual", false, model->annual) . 
                                    this->inputs->date("Active from", "active_from", "Date theme becomes active", false, model->active_from) .
                                    this->inputs->date("Active to", "active_to", "Date theme becomes inactive", false, model->active_to) .
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
            FROM themes 
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
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#time-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='time-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("time-tab") .
                        "Date schedule
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
                "Add a new theme"
            ) .
        "</div>";

        return html;
    }

    public function setData(array data, user_id = null, model = null)
    {
        let data["name"] = _POST["name"];
        let data["folder"] = _POST["folder"];
        let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
        let data["status"] = isset(_POST["status"]) ? "live" : "offline";
        let data["annual"] = isset(_POST["annual"]) ? 1 : 0;
        let data["active_from"] = isset(_POST["active_from"]) ? (new Dates())->toSQL(_POST["active_from"], false) : null;
        let data["active_to"] = isset(_POST["active_to"]) ? (new Dates())->toSQL(_POST["active_to"], false) : null;
        let data["updated_by"] = this->database->getUserId();

        return data;
    }
}