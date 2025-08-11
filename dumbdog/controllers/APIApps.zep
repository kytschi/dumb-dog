/**
 * DumbDog APIApps controller
 *
 * @package     DumbDog\Controllers\APIApps
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Helper\Security;
use DumbDog\Helper\Dates;
use DumbDog\Ui\Gfx\Buttons;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Inputs;
use DumbDog\Ui\Gfx\Tables;
use DumbDog\Ui\Gfx\Titles;

class APIApps extends Controller
{
    protected tables;
    protected titles;
    protected buttons;
    protected inputs;
    protected icons;

    public global_url = "/api-apps";
    public type = "api-app";
    public title = "API apps";
    public back_url = "";
    
    public list = [
        "name|with_tags",
        "description",
        "status"
    ];

    public required = ["name", "description"];

    public routes = [
        "/api-apps/add": [
            "APIApps",
            "add",
            "create an API app"
        ],
        "/api-apps/edit": [
            "APIApps",
            "edit",
            "edit the API app"
        ],
        "/api-apps": [
            "APIApps",
            "index",
            "API apps"
        ]
    ];

    public function __globals()
    {
        let this->tables = new Tables();
        let this->titles = new Titles();
        let this->inputs = new Inputs();
        let this->buttons = new Buttons();
        let this->icons = new Icons();
    }

    public function add(path)
    {
        var html, data, model;
        
        let html = this->titles->page(
            "Create an API app",
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

                    let data["api_key"] = (new Security())->randomString(128);

                    let status = this->database->execute(
                        "INSERT INTO api_apps 
                            (id,
                            status,
                            name,
                            description,
                            tags,
                            api_key,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (
                            :id,
                            :status,
                            :name,
                            :description,
                            :tags,
                            :api_key,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the API app");
                        let html .= this->consoleLogError(status);
                    } else {
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
        let model->status = "active";
        let model->name = "";
        let model->description = "";
        let model->api_key = "";
        let model->tags = "";
        
        let html .= this->render(model);

        return html;
    }

    public function edit(path)
    {
        var html = "", model, data = [];

        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM api_apps WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("API app not found");
        }

        let html = this->titles->page("Edit the API app", "edit");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the API app");
        }

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;
            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("content", path);
                }
            } elseif (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("content", path);
                }
            }

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = path . "?saved=true";
                let data = this->setData(data);

                if (_POST["regenerate"]) {
                    let data["api_key"] = (new Security())->randomString(128);
                } else {
                    let data["api_key"] = model->api_key;
                }
 
                let status = this->database->execute(
                    "UPDATE api_apps SET 
                        status=:status,
                        name=:name,
                        description=:description,
                        api_key=:api_key,
                        updated_at=NOW(),
                        updated_by=:updated_by,
                        tags=:tags 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the API app");
                    let html .= this->consoleLogError(status);
                } else {
                    this->redirect(path);
                }
            }
        }

        let html .= this->render(model, "edit");
        return html;
    }

    public function index(path)
    {
        var html;       
        
        let html = this->titles->page(this->title, strtolower(str_replace(" ", "", this->title)));

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        let html .= 
            this->renderToolbar() .
            this->inputs->searchBox(this->global_url, "Search the " . strtolower(this->title)) . 
            this->tags(path, "content", this->type) .
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
                                    this->inputs->toggle("Set active", "status", false, (model->status=="active" ? 1 : 0)) . 
                                    this->inputs->text("Name", "name", "Name the API app", true, model->name) .
                                    this->inputs->text("Description", "description", "Describe the API app", true, model->description) .
                                "
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id='key-tab' class='dd-row'>
                        <div class='dd-col-lg-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>API key</div>
                                <div class='dd-box-body'>
                                    <div class='dd-row'>
                                        <div class='dd-col-12 dd-flex'>
                                            <div class='dd-col'>" .
                                                this->inputs->text("API key", "api_key", "API key", false, model->api_key, true, "The system will auto-generate the key") .
                                            "</div>
                                            <div class='dd-col-auto dd-mt-4'>" .
                                                this->buttons->copy(model->api_key) .
                                            "</div>
                                        </div>
                                    </div>
                                    <div class='dd-row'>
                                        <div class='dd-col-12'>" .
                                            this->inputs->toggle("Re-generate the key", "regenerate", false, 0) . 
                                        "</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id='nav-tab' class='dd-row'>
                        <div class='dd-col-lg-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>Tags</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->tags("Tags", "tags", "Tag the API app", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>
                </div> " .
                this->renderSidebar(model, mode) .
            "</div>
        </form>";

        return html;
    }

    public function renderList(path)
    {
        var data = [], query;

        let query = "
            SELECT * FROM api_apps 
            WHERE id IS NOT NULL";
        if (isset(_POST["q"])) {
            let query .= " AND (name LIKE :query OR description LIKE :query)";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND tags LIKE :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY name";

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
                            "Create a new API app"
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
                        data-tab='#key-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='key-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("key-tab") .
                        "API key
                    </span>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#nav-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='nav-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("nav-tab") .
                        "Tags
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
                "Go back to the API apps"
            );
        }

        let html .= this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new API app"
            ) .
        "</div>";

        return html;
    }

    private function setData(array data)
    {   
        let data["status"] = isset(_POST["status"]) ? "active" : "inactive";
        let data["name"] = _POST["name"];
        let data["description"] = _POST["description"];
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);
        let data["updated_by"] = this->getUserId();

        return data;
    }
}