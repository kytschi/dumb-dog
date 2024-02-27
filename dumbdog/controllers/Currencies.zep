/**
 * DumbDog currencies
 *
 * @package     DumbDog\Controllers\Currencies
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;

class Currencies extends Content
{
    public global_url = "/currencies";
    public type = "currency";
    public title = "Currencies";
    public required = ["name"];

    public function add(string path)
    {
        var html, data, model;

        let model = new \stdClass();
        let html = this->titles->page("Create the currency", "add");

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
                        "INSERT INTO currencies 
                            (id,
                            name,
                            title,
                            symbol,
                            exchange_rate,
                            exchange_rate_safety_buffer,
                            locale_code,
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
                            :symbol,
                            :exchange_rate,
                            :exchange_rate_safety_buffer,
                            :locale_code,
                            :is_default,
                            :status,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the currency");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Currency has been saved");
        }

        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->symbol = "";
        let model->exchange_rate = 1;
        let model->exchange_rate_safety_buffer = 0;
        let model->locale_code = "";
        let model->is_default = 0;
        let model->status = "active";

        let html .= this->render(model);

        return html;
    }

    public function edit(string path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT currencies.* 
            FROM currencies 
            WHERE currencies.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Currency not found");
        }

        let html = this->titles->page("Edit the currency", "edit");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Currency has been updated");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;

            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("currencies", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("currencies", path);
                }
            }

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = path . "?saved=true";

                let data = this->setData(data);

                let status = this->database->execute(
                    "UPDATE currencies SET 
                        name=:name,
                        title=:title,
                        symbol=:symbol,
                        exchange_rate=:exchange_rate,
                        exchange_rate_safety_buffer=:exchange_rate_safety_buffer,
                        locale_code=:locale_code,
                        is_default=:is_default,
                        status=:status,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the currency");
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
        
        let html = this->titles->page("Currencies", "currencies");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        if (this->back_url) {
            let html .= this->renderBack();
        } else {
            let html .= this->renderToolbar();
        }

        let html .= 
            this->inputs->searchBox(this->global_url, "Search the currencies") . 
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
                                    this->inputs->text("Name", "name", "Name the currency", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title for the currency", true, model->title) .
                                    this->inputs->text("Symbol", "symbol", "The display symbol for the currency", true, model->symbol) .
                                    this->inputs->text("Locale", "locale_code", "i.e. en_GB", false, model->locale_code) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='exchange-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->text("Exchange rate", "exchange_rate", "The currency exchange rate", false, model->exchange_rate) .
                                    this->inputs->text("Safety buffer", "exchange_rate_safety_buffer", "The exchange safety buffer", false, model->exchange_rate_safety_buffer) .
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
                            aria-selected='true'>Currency</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#exchange-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='exchange-tab' 
                            aria-selected='true'>Exchange rate</button>
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
            SELECT currencies.* FROM currencies";
        if (isset(_POST["q"])) {
            let query .= " AND currencies.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        let query .= " ORDER BY currencies.name";

        return this->tables->build(
            [
                "name",
                "title",
                "symbol",
                "exchange_rate"
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
        let data["title"] = _POST["title"];
        let data["symbol"] = _POST["symbol"];
        let data["locale_code"] = _POST["locale_code"];
        let data["exchange_rate"] = floatval(_POST["exchange_rate"]);
        let data["exchange_rate_safety_buffer"] = floatval(_POST["exchange_rate_safety_buffer"]);
        let data["updated_by"] = this->database->getUserId();

        return data;
    }
}