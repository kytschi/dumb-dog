/**
 * DumbDog payment gateways builder
 *
 * @package     DumbDog\Controllers\PaymentGateways
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Controllers\Gateways\Stripe;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;

class PaymentGateways extends Content
{
    public decrypt = ["public_api_key", "private_api_key"];
    public global_url = "/payment-gateways";
    public type = "payment-gateway";
    public required = ["name", "title", "type"];
    public list = [
        "name",
        "type",
        "is_default|bool",
        "status"
    ];

    public function add(string path)
    {
        var html, data;

        let html = this->titles->page("Create the payment gateway", "add");

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
                            type,
                            description,
                            is_default,
                            status,
                            public_api_key,
                            private_api_key,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :title,
                            :type,
                            :description,
                            :is_default,
                            :status,
                            :public_api_key,
                            :private_api_key,
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
        let model->type = "";
        let model->description = "";
        let model->is_default = 0;
        let model->public_api_key = "";

        let html .= this->render(model);

        return html;
    }

    public function edit(string path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                payment_gateways.* 
            FROM payment_gateways 
            WHERE payment_gateways.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Payment gateway not found");
        }

        let model = this->database->decrypt(this->decrypt, model);

        let html = this->titles->page("Edit the payment gateway", "edit");

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
                        type=:type,
                        description=:description,
                        is_default=:is_default,
                        status=:status,
                        public_api_key=:public_api_key,
                        private_api_key=:private_api_key,
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
                        let html .= this->missingRequired(err->getMessage());
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
        var data = [], item;
        let data = this->database->all("
            SELECT payment_gateways.*
            FROM payment_gateways
            WHERE deleted_at IS NULL AND status='active' 
            ORDER BY is_default DESC, title");
        
        for item in data {
            let item = this->database->decrypt(this->decrypt, item);
        }

        return data;
    }

    public function index(string path)
    {
        var html;       
        
        let html = this->titles->page("Payment gateways", "paymentGateways");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the payment gateway");
        }

        if (this->back_url) {
            let html .= this->renderBack();
        } else {
            let html .= this->renderToolbar();
        }

        let html .= 
            this->inputs->searchBox(this->global_url, "Search the payment gateways") .
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
                                    this->inputs->select(
                                        "Type",
                                        "type",
                                        "The type of payment gateway",
                                        [
                                            "stripe": "stripe"
                                        ],
                                        true,
                                        model->type
                                    ) . 
                                    this->inputs->text("Name", "name", "Name the payment gateway", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title for the payment gateway", true, model->title) .                                    
                                    this->inputs->textarea("Description", "description", "The display description", false, model->description) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='api-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->text("Public key", "public_api_key", "The public key for API access", false, model->public_api_key) .
                                    this->inputs->text("Private key", "private_api_key", "The private key for API access", false, model->private_api_key) .
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
                            aria-selected='true'>Payment gateway</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#api-tab'
                            aria-controls='api-tab' 
                            aria-selected='true'>API access</button>
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
            SELECT payment_gateways.* FROM payment_gateways";
        if (isset(_POST["q"])) {
            let query .= " AND payment_gateways.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        let query .= " ORDER BY payment_gateways.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
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

    public function process(string path)
    {
        if (strpos(path, "/payment-gateway/") !== false) {
            if (strpos(path, "/payment-gateway/create/") !== false) {
                let path = str_replace("/payment-gateway/create/", "", path);
                switch (path) {
                    case "stripe":
                        (new Stripe())->create();
                        break;
                }
            } elseif (strpos(path, "/payment-gateway/status/") !== false) {
                let path = str_replace("/payment-gateway/status/", "", path);
                switch (path) {
                    case "stripe":
                        (new Stripe())->status();
                        break;
                }
            } else {
                header("Content-Type: application/json");
                http_response_code(404);
                echo json_encode(["error": "invalid path"]);
                die();
            }
        }
    }

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "active" : "inactive";
        let data["is_default"] = isset(_POST["is_default"]) ? 1 : 0;
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["type"] = _POST["type"];
        let data["description"] = isset(_POST["description"]) ? _POST["description"] : "";
        let data["updated_by"] = this->getUserId();

        let data["public_api_key"] = this->database->encrypt(_POST["public_api_key"]);
        let data["private_api_key"] = this->database->encrypt(_POST["private_api_key"]);

        return data;
    }
}