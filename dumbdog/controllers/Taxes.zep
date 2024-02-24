/**
 * DumbDog taxes builder
 *
 * @package     DumbDog\Controllers\Taxes
 * @author 		Mike Welsh
 * @copyright   2024 Digital Dunes
 * @version     0.0.1
 *
 * Copyright 2024 Digital Dunes
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;

class Taxes extends Content
{
    public global_url = "/taxes";
    public type = "tax";
    public required = ["name"];

    public function add(string path)
    {
        var html, data;
        
        let html = this->titles->page("Create the tax");

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
                        "INSERT INTO taxes 
                            (id,
                            name,
                            title,
                            tax_rate,
                            is_default,
                            status,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :title,
                            :tax_rate,                            
                            :is_default,
                            :status,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the tax");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Tax has been saved");
        }

        var model;
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->tax_rate = 1;
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
                taxes.* 
            FROM taxes 
            WHERE taxes.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Tax not found");
        }

        let html = this->titles->page("Edit the tax");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Tax has been updated");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = this->global_url . "/edit/" . model->id;

                if (isset(_POST["delete"])) {
                    if (!empty(_POST["delete"])) {
                        this->triggerDelete("taxes", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("taxes", path);
                    }
                }

                let path = path . "?saved=true";

                let data = this->setData(data);

                let status = this->database->execute(
                    "UPDATE taxes SET 
                        name=:name,
                        title=:title,
                        tax_rate=:tax_rate,
                        is_default=:is_default,
                        status=:status,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the tax");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        this->redirect(path);
                    } catch ValidationException, err {
                        this->missingRequired(err->getMessage());
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
        
        let html = this->titles->page("Taxes");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the tax");
        }

        if (this->back_url) {
            let html .= this->renderBack();
        } else {
            let html .= this->renderToolbar();
        }

        let html .= 
            this->inputs->searchBox(this->global_url, "Search the taxes") .
            this->renderList(path);
        return html;
    }

    public function render(model, mode = "add")
    {
        var html;

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='tabs'>
                <div class='tabs-content col'>
                    <div id='content-tab' class='row'>
                        <div class='col-12'>
                            <article class='card'>
                                <div class='card-body'>" .
                                    this->inputs->toggle("Active", "status", false, (model->status == "active" ? 1 : 0)) . 
                                    this->inputs->toggle("Default", "is_default", false, model->is_default) . 
                                    this->inputs->text("Name", "name", "Name the tax", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title for the tax", true, model->title) .
                                    this->inputs->text("Tax rate", "tax_rate", "The tax rate as percentage", true, model->tax_rate) .
                                "</div>
                            </article>
                        </div>
                    </div>
                </div>
                <ul class='col nav nav-tabs' role='tablist'>
                    <li class='nav-item' role='presentation'>
                        <button
                            class='nav-link'
                            type='button'
                            role='tab'
                            data-tab='#content-tab'
                            aria-controls='content-tab' 
                            aria-selected='true'>Tax</button>
                    </li>
                    <li class='nav-item' role='presentation'><hr/></li>
                    <li class='nav-item' role='presentation'>" . 
                        this->buttons->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {    
            if (model->deleted_at) {
                let html .= "<li class='nav-item' role='presentation'>" .
                    this->buttons->recover(this->global_url ."/recover/" . model->id) . 
                "</li>";
            } else {
                let html .= "<li class='nav-item' role='presentation'>" .
                    this->buttons->delete(this->global_url ."/delete/" . model->id) . 
                "</li>";
            }
        }

        let html .= "<li class='nav-item' role='presentation'>". 
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
            SELECT taxes.* FROM taxes";
        if (isset(_POST["q"])) {
            let query .= " AND taxes.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        let query .= " ORDER BY taxes.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "active" : "inactive";
        let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["tax_rate"] = floatval(_POST["tax_rate"]);
        let data["updated_by"] = this->database->getUserId();

        return data;
    }
}