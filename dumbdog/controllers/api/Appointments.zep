/**
 * DumbDog API for appointments controller
 *
 * @package     DumbDog\Controllers\Api\Appointments
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Appointments as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Appointments extends Controller
{
    public api_routes = [
        "/api/appointments/add": [
            "Appointments",
            "add"
        ],
        "/api/appointments/delete": [
            "Appointments",
            "delete"
        ],
        "/api/appointments/edit": [
            "Appointments",
            "edit"
        ],
        "/api/appointments/recover": [
            "Appointments",
            "recover"
        ],
        "/api/appointments/view": [
            "Appointments",
            "view"
        ],
        "/api/appointments": [
            "Appointments",
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
            let data["created_by"] = this->api_app->created_by;
            let data["type"] = controller->type;

            let data = controller->setData(data, this->api_app->created_by);

            let status = this->database->execute(
                controller->query_insert,
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the appointment",
                    400
                );
            } else {
                let model = this->database->get(
                    "SELECT content.* FROM content WHERE id=:id",
                    [
                        "id": data["id"]
                    ]
                );

                if (this->cfg->save_mode == true) {
                    controller->updateExtra(model, path);
                }

                let model = this->database->get(
                    controller->query_appointment,
                    [
                        "id": data["id"],
                        "type": data["type"]
                    ]
                );

                return this->createReturn(
                    "Appointment successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the appointment, no post data",
            400
        );
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type;

        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        if (this->cfg->save_mode == true) {
            controller->triggerDelete("content", path, data["id"], this->api_app->created_by, false);
        }

        let model = this->database->get(
            controller->query_appointment,
            data
        );

        return this->createReturn(
            "Appointment successfully marked as deleted",
            model
        );
    }

    public function edit(path)
    {
        var model, data = [], controller, status = false;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type;
        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
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
                
                let status = this->database->execute(
                    controller->query_update,
                    data
                );
                
                if (!is_bool(status)) {
                    throw new SaveException(
                        "Failed to update the appointment",
                        400
                    );
                } else {
                    let model = this->database->get(
                        "SELECT content.* FROM content WHERE id=:id",
                        [
                            "id": data["id"]
                        ]
                    );
    
                    if (this->cfg->save_mode == true) {
                        controller->updateExtra(model, path);
                    }

                    let model = this->database->get(
                        controller->query_appointment,
                        [
                            "id": data["id"],
                            "type": data["type"]
                        ]
                    );
    
                    return this->createReturn(
                        "Appointment successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the appointment, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC", controller;

        this->secure();

        let controller = new Main();

        let query = controller->query_appointment;

        if (isset(_GET["query"])) {
            let query .= " AND main_page.name LIKE :query";
            let data["query"] = "%" . _GET["query"] . "%";
        }

        if (isset(_GET["tag"])) {
            let query .= " AND main_page.tags LIKE :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
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

            let query .= " ORDER BY main_page." . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY main_page.name " . sort_dir;
        }        

        let results = this->database->all(query, data);

        return this->createReturn(
            "Appointments",
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
        let data["type"] = controller->type;

        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        if (this->cfg->save_mode == true) {
            controller->triggerRecover("content", path, data["id"], this->api_app->created_by, false);
        }

        let model = this->database->get(
            controller->query_appointment,
            data
        );

        return this->createReturn(
            "Appointment successfully recovered from the deleted state",
            model
        );
    }

    public function view(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type;

        let model = this->database->get(
            controller->query_appointment,
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        return this->createReturn(
            "Appointment",
            model
        );
    }
}