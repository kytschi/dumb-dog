/**
 * DumbDog payment gateways builder
 *
 * @package     DumbDog\Controllers\PaymentGateways
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Files;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Input;
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class PaymentGateways extends Controller
{
    public global_url = "/DumbDog/payment-gateways";
    public type = "payment-gateway";
    public required = ["name", "title"];

    public function add(string path)
    {
        var titles, html, data, files, input;
        let files = new Files();
        let titles = new Titles();
        let input = new Input();

        let html = titles->page("Create the payment gateway");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->getUserId();

                    let data = this->setData(data);

                    let status = this->database->execute(
                        "INSERT INTO payment_gateways 
                            (id,
                            name,
                            title,
                            slug,
                            description,
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
                            :slug,
                            :description,
                            :is_default,
                            :status,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the payment gateway");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Payment gateway has been saved");
        }

        var model;
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->slug = "";
        let model->description = "";
        let model->is_default = 0;

        let html .= this->render(model);

        return html;
    }

    public function edit(string path)
    {
        var titles, html, model, data = [], input, files;
        let titles = new Titles();
        let input = new Input();
        let files = new Files();

        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                payment_gateways.* 
            FROM payment_gateways 
            WHERE payment_gateways.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Payment gateway not found");
        }

        let html = titles->page("Edit the payment gateway");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Payment gateway has been updated");
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
                        this->triggerDelete("payment_gateways", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("payment_gateways", path);
                    }
                }

                let path = path . "?saved=true";

                let data = this->setData(data);

                let status = this->database->execute(
                    "UPDATE payment_gateways SET 
                        name=:name,
                        title=:title,
                        slug=:slug,
                        description=:description,
                        is_default=:is_default,
                        status=:status,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the payment gateway");
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

    /**
     * For the frontend.
     */
    public function get()
    {
        return this->database->all("
        SELECT
            payment_gateways.id,
            payment_gateways.title,
            payment_gateways.description,
            payment_gateways.is_default 
        FROM
            payment_gateways
        WHERE
            deleted_at IS NULL AND status='active' 
        ORDER BY is_default DESC, title");
    }

    public function index(string path)
    {
        var titles, table, html, query, data, button;
        let titles = new Titles();
        let button = new Button();
        let table = new Table();
        
        let html = titles->page("Payment gateways");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the payment gateway");
        }

        let html .= "
            <form class='card' action='" . this->global_url . "' method='post'>
                <div class='card-body'>
                    <div class='flex two'>
                        <div class='full half-1000'>
                            <input 
                                class='w-100'
                                name='q'
                                type='text' 
                                placeholder='Search the " . (ucwords(this->type). "s") . "'
                                value='" . (isset(_POST["q"]) ? _POST["q"]  : ""). "'>
                        </div>
                        <div>";
                        if (isset(_POST["q"])) {
                            let html .= "<a href='" . this->global_url . "' class='button-blank float-start'>clear</a>";
                        }
            
            let html .= "   <button 
                                type='submit'
                                name='search' 
                                class='float-start' 
                                value='search'>search</button>
                            <div class='float-end'>" . 
                                button->add(this->global_url . "/add") .
                            "</div>
                        </div>
                    </div>
                    
                </div>
            </form>";

        let html .= this->tags(path, "content");

        let html .= "<article class='card'><div class='card-body'>";

        let data = [];
        let query = "
            SELECT payment_gateways.* FROM payment_gateways";
        if (isset(_POST["q"])) {
            let query .= " AND payment_gateways.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        let query .= " ORDER BY payment_gateways.name";

        let html .= table->build(
            [
                "name",
                "title",
                "description"
            ],
            this->database->all(query, data),
            "/DumbDog/" . ltrim(path, "/")
        );

        return html . "</div></article>";
    }

    private function render(model, mode = "add")
    {
        var html, button, input;

        let input = new Input();
        let button = new Button();

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='tabs'>
                <div class='tabs-content col'>
                    <div id='content-tab' class='row'>
                        <div class='col-12'>
                            <article class='card'>
                                <div class='card-body'>" .
                                    input->toggle("Active", "status", false, (model->status == "active" ? 1 : 0)) . 
                                    input->toggle("Default", "is_default", false, model->is_default) . 
                                    input->text("Name", "name", "Name the payment gateway", true, model->name) .
                                    input->text("Title", "title", "The display title for the payment gateway", true, model->title) .
                                    input->textarea("Description", "description", "The display description", false, model->description) .
                                    input->text("Slug", "slug", "Slug to help internally identify", false, model->slug) .
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
                            aria-selected='true'>Payment gateway</button>
                    </li>
                    <li class='nav-item' role='presentation'><hr/></li>
                    <li class='nav-item' role='presentation'>" . 
                        button->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {    
            if (model->deleted_at) {
                let html .= "<li class='nav-item' role='presentation'>" .
                    button->recover(this->global_url ."/recover/" . model->id) . 
                "</li>";
            } else {
                let html .= "<li class='nav-item' role='presentation'>" .
                    button->delete(this->global_url ."/delete/" . model->id) . 
                "</li>";
            }
        }

        let html .= "<li class='nav-item' role='presentation'>". 
                        button->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "active" : "inactive";
        let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["slug"] = isset(_POST["slug"]) ? _POST["slug"] : this->createSlug(data["name"]);
        let data["description"] = isset(_POST["description"]) ? _POST["description"] : "";
        let data["updated_by"] = this->getUserId();

        return data;
    }
}