/**
 * DumbDog payment gateways builder
 *
 * @package     DumbDog\Controllers\PaymentGateways
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
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

    public types = [
        "stripe": "Stripe"
    ];

    public routes = [
        "/payment-gateways/add": [
            "PaymentGateways",
            "add",
            "add a payment gateway"
        ],
        "/payment-gateways/edit": [
            "PaymentGateways",
            "edit",
            "edit the payment gateway"
        ],
        "/payment-gateways": [
            "PaymentGateways",
            "index",
            "payment gateways"
        ]
    ];

    public function __globals()
    {
        parent::__globals();

        let this->query = "
            SELECT payment_gateways.* 
            FROM payment_gateways 
            WHERE payment_gateways.id=:id";

        let this->query_insert = "
            INSERT INTO payment_gateways 
                (
                    id,
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
                    updated_by
                ) 
            VALUES 
                (
                    :id,
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
                    :updated_by
                )";
        
        let this->query_update = "
            UPDATE payment_gateways 
            SET 
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
            WHERE id=:id";
    }

    public function add(path)
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

                    if (data["is_default"]) {
                        this->clearDefault(
                            "payment_gateways",
                            data["updated_by"]
                        );
                    }

                    let status = this->database->execute(
                        this->query_insert,
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

    public function edit(path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get(
            this->query,
            data
        );

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

                if (data["is_default"]) {
                    this->clearDefault(
                        "payment_gateways",
                        data["updated_by"]
                    );
                }

                let status = this->database->execute(
                    this->query_update,
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
            WHERE deleted_at IS NULL AND status='live' 
            ORDER BY is_default DESC, title");
        
        for item in data {
            let item = this->database->decrypt(this->decrypt, item);
        }

        return data;
    }

    public function index(path)
    {
        var html;       
        
        let html = this->titles->page("Payment gateways", "paymentGateways");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the payment gateway");
        }

        let html .= 
            this->renderToolbar() .
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
                                    this->inputs->toggle("Live", "status", false, (model->status == "live" ? 1 : 0)) . 
                                    this->inputs->toggle("Default", "is_default", false, model->is_default) . 
                                    this->inputs->select(
                                        "Type",
                                        "type",
                                        "The type of payment gateway",
                                        this->types,
                                        true,
                                        model->type
                                    ) . 
                                    this->inputs->text("Name", "name", "Name the payment gateway", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title for the payment gateway", true, model->title) .
                                    this->inputs->tags("Tags", "tags", "Tag the gateway", false, model->tags) . 
                                    this->inputs->textarea("Description", "description", "The display description", false, model->description) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='api-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>API access</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->text("Public key", "public_api_key", "The public key for API access", false, model->public_api_key) .
                                    this->inputs->text("Private key", "private_api_key", "The private key for API access", false, model->private_api_key) .
                                "</div>
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
                        this->buttons->generic(
                            this->global_url . "/add",
                            "",
                            "add",
                            "Add a new payment gateway"
                        );
        if (mode == "edit") {
            if (model->deleted_at) {
                let html .= this->buttons->recover(model->id);
            } else {
                let html .= this->buttons->delete(model->id);
            }
        }
        let html .= this->buttons->save() . "</div>
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
                        "Payment gateway
                    </span>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#api-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='api-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("api-tab") .
                        "API access
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
                "Go back to the payment gateways"
            );
        }

        let html .= 
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new payment gateway"
            ) .
        "</div>";

        return html;
    }

    public function process(path)
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

    public function setData(array data, user_id = null, model = null)
    {
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["type"] = _POST["type"];

        if (!in_array(data["type"], array_keys(this->types))) {
            throw new ValidationException(
                "Invalid payment type",
                this->types
            );
        }

        let data["status"] = isset(_POST["status"]) ?
            "live" :
            (model ? model->status : "offline");

        let data["is_default"] = isset(_POST["is_default"]) ? 1 : (model ? model->is_default : 0);
        
        let data["description"] = isset(_POST["description"]) ?
            _POST["description"] :
            (model ? model->description : null);

        let data["updated_by"] = user_id ? user_id : this->getUserId();

        let data["public_api_key"] = 
            isset(_POST["public_api_key"]) ?
                this->database->encrypt(_POST["public_api_key"]) :
                (model ? model->public_api_key : null);

        let data["private_api_key"] = 
            isset(_POST["private_api_key"]) ?
                this->database->encrypt(_POST["private_api_key"]) :
                (model ? model->private_api_key : null);

        return data;
    }
}