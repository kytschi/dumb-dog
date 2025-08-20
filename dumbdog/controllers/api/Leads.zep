/**
 * DumbDog API for Leads controller
 *
 * @package     DumbDog\Controllers\Api\Leads
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Leads as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Leads extends Controller
{
    public api_routes = [
        "/api/leads/add": [
            "Leads",
            "add"
        ],
        "/api/leads/delete": [
            "Leads",
            "delete"
        ],
        "/api/leads/edit": [
            "Leads",
            "edit"
        ],
        "/api/leads/recover": [
            "Leads",
            "recover"
        ],
        "/api/leads/view": [
            "Leads",
            "view"
        ],
        "/api/leads": [
            "Leads",
            "list"
        ]
    ];

    public valid_sorts = ["first_name", "created_at"];
    
    public function add(path)
    {
        var data = [], model = null, status = false, controller, err;

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
            let data["created_by"] = this->api_app->created_by;
            let data["contact_id"] = controller->saveContact(
                controller->setData(data, this->api_app->created_by),
                this->api_app->created_by
            );

            try {
                let data = controller->setLeadData(data, this->api_app->created_by);

                let status = this->database->execute(
                    controller->query_insert,
                    data
                );
            } catch \Exception, err {
                throw new SaveException(
                    "Failed to save the lead entry",
                    err->getCode(),
                    err->getMessage()
                );
            }

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the lead entry",
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
                    "Lead entry successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the lead entry, no post data",
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
            controller->query . " WHERE leads.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Lead entry not found");
        }

        controller->triggerDelete("leads", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query . " WHERE leads.id=:id",
            data
        );

        return this->createReturn(
            "Lead entry successfully marked as deleted",
            controller->decryptData(model)
        );
    }

    public function edit(path)
    {
        var model, data = [], status = false, controller;

        this->secure();

        let controller = new Main();
        
        let data["id"] = controller->getPageId(path);
        let model = this->database->get(
            controller->query . " WHERE leads.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Lead entry not found");
        }

        if (!empty(_POST)) {
            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            } else {
                let model = controller->decryptData(model);

                controller->updateContact(
                    controller->setData(data, this->api_app->created_by, model),
                    this->api_app->created_by,
                    model
                );
                let data = controller->setLeadData(data, this->api_app->created_by, model);
                  
                let status = this->database->execute(
                    controller->query_update,
                    data
                );

                if (!is_bool(status)) {
                    throw new SaveException(
                        "Failed to update the lead entry",
                        400
                    );
                } else {
                    let model = this->database->get(
                        controller->query . " WHERE leads.id=:id",
                        [
                            "id": data["id"]
                        ]
                    );

                    return this->createReturn(
                        "Lead entry successfully updated",
                        controller->decryptData(model)
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the lead entry, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, sort_dir = "ASC", controller;

        this->secure();

        let controller = new Main();
        
        let query = controller->query_list;

        if (isset(_GET["query"])) {
            let query .= " AND contacts.first_name=:query";
            let data["query"] = this->database->encrypt(_GET["query"]);
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

            let query .= " ORDER BY contacts." . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY contacts.first_name " . sort_dir;
        }
        
        return this->createReturn(
            "Leads",
            controller->decryptData(this->database->all(query, data)),
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
            controller->query . " WHERE leads.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Lead entry not found");
        }

        controller->triggerRecover("leads", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query . " WHERE leads.id=:id",
            data
        );

        return this->createReturn(
            "Lead entry successfully recovered from the deleted state",
            controller->decryptData(model)
        );
    }

    public function view(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        
        let model = this->database->get(
            controller->query . " WHERE leads.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Lead entry not found");
        }

        return this->createReturn(
            "Lead entry",
            controller->decryptData(model)
        );
    }
}