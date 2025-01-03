/**
 * Dumb dog countries
 *
 * @package     DumbDog\Controllers\Countries
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Controllers\Files;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;

class Countries extends Content
{
    public global_url = "/countries";
    public titles = "Countries";
    public type = "country";
    public required = ["name"];

    public routes = [
        "/countries/add": [
            "Countries",
            "add",
            "create a country"
        ],
        "/countries/edit": [
            "Countries",
            "edit",
            "edit the country"
        ],
        "/countries": [
            "Countries",
            "index",
            "countries"
        ]
    ];
    
    public function add(string path)
    {
        var html, data, model;

        let model = new \stdClass();

        let html = this->titles->page("Create the country", "add");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->database->getUserId();

                    let data = this->setData(data);

                    let status = this->database->execute(
                        "INSERT INTO countries 
                            (id,
                            name,
                            code,
                            is_default,
                            status,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :code,
                            :is_default,
                            :status,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the country");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Country has been saved");
        }

        let model->deleted_at = null;
        let model->name = "";
        let model->code = "";
        let model->status = "active";
        let model->is_default = 0;

        let html .= this->render(model);

        return html;
    }

    public function edit(string path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                countries.* 
            FROM countries 
            WHERE countries.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Country not found");
        }

        let html = this->titles->page("Edit the country", "edit");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Country has been updated");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;

            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("countries", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("countries", path);
                }
            }

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = path . "?saved=true";

                let data = this->setData(data);

                let status = this->database->execute(
                    "UPDATE countries SET 
                        name=:name,
                        code=:code,
                        is_default=:is_default,
                        status=:status,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the country");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        let status = this->database->execute(
                            "UPDATE product_shipping 
                            SET country_code=:country_code
                            WHERE country_id=:country_id",
                            [
                                "country_code": data["code"],
                                "country_id": data["id"]
                            ]
                        );
                        if (!is_bool(status)) {
                            let html .= this->saveFailed("Failed to update the shipping country codes");
                            let html .= this->consoleLogError(status);
                        } else {
                            this->redirect(path);
                        }
                    } catch ValidationException, err {
                        let html .= this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        let html .= this->render(model, "edit");
        return html;
    }

    public function index(string path)
    {
        var html;
        
        let html = this->titles->page("Countries", "countries");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        let html .= this->renderToolbar();

        let html .= 
            this->inputs->searchBox(this->global_url, "Search the countries") . 
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
                                    this->inputs->toggle("Active", "status", false, (model->status == "active" ? 1 : 0)) . 
                                    this->inputs->toggle("Default", "is_default", false, model->is_default) . 
                                    this->inputs->text("Name", "name", "The country name", true, model->name) .
                                    this->inputs->text("Code", "code", "The country code", true, model->code) .
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
                            data-tab='#content-tab'
                            aria-controls='content-tab' 
                            aria-selected='true'>Country</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>" . 
                        this->buttons->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {    
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
        var data = [], query;

        let query = "
            SELECT countries.* FROM countries";
        if (isset(_POST["q"])) {
            let query .= " AND countries.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        let query .= " ORDER BY countries.name";

        return this->tables->build(
            [
                "name",
                "status"
            ],
            this->database->all(query, data),
            this->cfg->dumb_dog_url . ltrim(path, "/")
        );
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new " . str_replace("-", " ", this->type)
            ) .
        "</div>";
    }

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "active" : "inactive";
        let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
        let data["name"] = _POST["name"];
        let data["code"] = _POST["code"];
        let data["updated_by"] = this->database->getUserId();

        return data;
    }
}