/**
 * DumbDog API for Payment Gateways controller
 *
 * @package     DumbDog\Controllers\Api\PaymentGateways
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\PaymentGateways as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class PaymentGateways extends Controller
{
    public api_routes = [
        "/api/payment-gateways/add": [
            "PaymentGateways",
            "add"
        ],
        "/api/payment-gateways/delete": [
            "PaymentGateways",
            "delete"
        ],
        "/api/payment-gateways/edit": [
            "PaymentGateways",
            "edit"
        ],
        "/api/payment-gateways/recover": [
            "PaymentGateways",
            "recover"
        ],
        "/api/payment-gateways/types": [
            "PaymentGateways",
            "types"
        ],
        "/api/payment-gateways/view": [
            "PaymentGateways",
            "view"
        ],
        "/api/payment-gateways": [
            "PaymentGateways",
            "list"
        ]
    ];

    public valid_sorts = ["name", "created_at"];
    
    public function add(path)
    {
        var data = [], model = null, status = false, controller;

        this->secure();

        if (!empty(_POST)) {
            let controller = new Main();

            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            }

            let data["id"] = this->database->uuid();
            let data["type"] = controller->type;
            let data["created_by"] = this->api_app->created_by;

            let data = controller->setData(data, this->api_app->created_by);     

            if (data["is_default"]) {
                controller->clearDefault(
                    "payment_gateways",
                    data["updated_by"]
                );
            }

            let status = this->database->execute(
                controller->query_insert,
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the payment gateway entry",
                    400
                );
            } else {
                let model = this->database->get(
                    controller->query,
                    [
                        "id": data["id"]
                    ]
                );

                return this->createReturn(
                    "Payment gateway entry successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the payment gateway entry, no post data",
            400
        );
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        
        let model = this->database->get(
            controller->query,
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Payment gateway entry not found");
        }

        controller->triggerDelete("payment_gateways", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query,
            data
        );

        return this->createReturn(
            "Payment gateway entry successfully marked as deleted",
            model
        );
    }

    public function edit(path)
    {
        var model, data = [], status = false, controller;

        this->secure();

        let controller = new Main();
        
        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type;
        let model = this->database->get(
            controller->query,
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Payment gateway entry not found");
        }

        if (!empty(_POST)) {
            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            } else {
                let data = controller->setData(data, this->api_app->created_by, model);

                if (data["is_default"]) {
                    controller->clearDefault(
                        "payment_gateways",
                        data["updated_by"]
                    );
                }
                                
                let status = this->database->execute(
                    controller->query_update,
                    data
                );

                if (!is_bool(status)) {
                    throw new SaveException(
                        "Failed to update the payment gateway entry",
                        400
                    );
                } else {
                    let model = this->database->get(
                        controller->query,
                        [
                            "id": data["id"]
                        ]
                    );

                    return this->createReturn(
                        "Payment gateway entry successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the payment gateway entry, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC", controller;

        this->secure();

        let controller = new Main();
        
        let query = "
            SELECT * 
            FROM payment_gateways  
            WHERE id IS NOT NULL";

        if (isset(_GET["query"])) {
            let query .= " AND name LIKE :query";
            let data["query"] = "%" . _GET["query"] . "%";
        }

        if (isset(_GET["sort_dir"])) {
            if (!in_array(strtoupper(_GET["sort_dir"]), this->valid_sort_dir)) {
                throw new ValidationException(
                    "Invalid sort direction",
                    400,
                    this->valid_sort_dir
                );
            }

            let sort_dir = strtoupper(_GET["sort_dir"]);
        }

        if (isset(_GET["sort"])) {
            if (!in_array(strtolower(_GET["sort"]), this->valid_sorts)) {
                throw new ValidationException(
                    "Invalid sort",
                    400,
                    this->valid_sorts
                );
            }

            let query .= " ORDER BY " . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY name " . sort_dir;
        }        

        let results = this->database->all(query, data);

        return this->createReturn(
            "Payment gateways",
            results,
            isset(_GET["query"]) ? _GET["query"] : null
        );
    }

    public function recover(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        
        let model = this->database->get(
            controller->query,
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Payment gateway entry not found");
        }

        controller->triggerRecover("payment_gateways", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query,
            data
        );

        return this->createReturn(
            "Payment gateway entry successfully recovered from the deleted state",
            model
        );
    }

    public function types(path)
    {
        var controller;

        this->secure();

        let controller = new Main();

        return this->createReturn(
            "Payment gateway types",
            controller->types
        );
    }

    public function view(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        
        let model = this->database->get(
            controller->query,
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Payment gateway entry not found");
        }

        return this->createReturn(
            "Payment gateway entry",
            model
        );
    }
}