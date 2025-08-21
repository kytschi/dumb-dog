/**
 * DumbDog API for Menus controller
 *
 * @package     DumbDog\Controllers\Api\Menus
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Menus as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Menus extends Controller
{
    public api_routes = [
        "/api/menus/items/add": [
            "Menus",
            "addItem"
        ],
        "/api/menus/items/delete": [
            "Menus",
            "deleteItem"
        ],
        "/api/menus/items/edit": [
            "Menus",
            "editItem"
        ],
        "/api/menus/items/recover": [
            "Menus",
            "recoverItem"
        ],
        "/api/menus/add": [
            "Menus",
            "add"
        ],
        "/api/menus/delete": [
            "Menus",
            "delete"
        ],
        "/api/menus/edit": [
            "Menus",
            "edit"
        ],
        "/api/menus/recover": [
            "Menus",
            "recover"
        ],
        "/api/menus/view": [
            "Menus",
            "view"
        ],
        "/api/menus": [
            "Menus",
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
            
            let status = this->database->execute(
                controller->query_insert,
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the menu",
                    400
                );
            } else {
                let model = new \stdClass();
                let model->id = data["id"];

                controller->updateExtra(model, path);

                let model = this->database->get(
                    controller->query . " AND content.id=:id",
                    [
                        "id": data["id"],
                        "type": data["type"]
                    ]
                );

                return this->createReturn(
                    "Menu successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the menu, no post data",
            400
        );
    }

    public function addItem(path)
    {
        var controller;

        this->secure();

        let controller = new Main();
        controller->addItem(
            controller->getPageId(path),
            this->api_app->created_by
        );

        return this->view(path);
    }

    public function createReturn(message, data = null, query = null, code = 200)
    {
        var parent_page = null, controller;

        let controller = new Main();

        if (!is_array(data)) {
            let data->tags = controller->toTags(data->tags);

            let data->items = this->database->all(
                controller->query . " AND content.parent_id=:id",
                [
                    "id": data->id,
                    "type": controller->type . "-item"
                ]
            );
                       
            if (data->parent_id) {
                let parent_page = this->database->get(
                    controller->query_parent,
                    [
                        "id": data->parent_id
                    ]
                );

                if (parent_page) {
                    let parent_page->items = this->database->all(
                        controller->query . " AND content.parent_id=:id",
                        [
                            "id": data->parent_id,
                            "type": controller->type . "-item"
                        ]
                    );
                }
            }

            let data->parent = parent_page;
        }

        return parent::createReturn(message, data, query, code);
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type;

        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu not found");
        }

        controller->triggerDelete("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        return this->createReturn(
            "Menu successfully marked as deleted",
            model
        );
    }

    public function deleteItem(path)
    {
        var controller, model, data = [];

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type . "-item";
        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu item not found");
        }

        controller->deleteItem(
            model->parent_id,
            model->id,
            this->api_app->created_by,
            false
        );

        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        return this->createReturn(
            "Menu item successfully marked as deleted",
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
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu not found");
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
                        "Failed to update the menu",
                        400
                    );
                } else {
                    controller->updateExtra(model, path);

                    let model = this->database->get(
                        controller->query . " AND content.id=:id",
                        [
                            "id": data["id"],
                            "type": data["type"]
                        ]
                    );

                    return this->createReturn(
                        "Menu successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the menu, no post data",
            400
        );
    }

    public function editItem(path)
    {
        var controller, model, data = [];

        this->secure();

        let controller = new Main();

        if (!controller->validate(_POST, controller->required)) {
            throw new ValidationException(
                "Missing required fields",
                400,
                controller->required
            );
        }

        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type . "-item";
        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu item not found");
        }

        controller->updateStacks(
            model,
            this->api_app->created_by
        );

        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        return this->createReturn(
            "Menu item",
            model
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC", controller;

        this->secure();

        let controller = new Main();

        let data["type"] = controller->type;
        let query = controller->query;

        if (isset(_GET["query"])) {
            let query .= " AND content.name LIKE :query";
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

            let query .= " ORDER BY content." . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY content.name " . sort_dir;
        }        

        let results = this->database->all(query, data);

        return this->createReturn(
            "Menu items",
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
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu not found");
        }

        controller->triggerRecover("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        return this->createReturn(
            "Menu successfully recovered from the deleted state",
            model
        );
    }

    public function recoverItem(path)
    {
        var controller, model, data = [];

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        let data["type"] = controller->type . "-item";
        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu item not found");
        }

        controller->recoverItem(
            model->parent_id,
            model->id,
            this->api_app->created_by,
            false
        );

        let model = this->database->get(
            controller->query . " AND content.id=:id",
            data
        );

        return this->createReturn(
            "Menu item successfully recovered from deleted state",
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
            controller->query . " AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Menu not found");
        }

        return this->createReturn(
            "Menu entry",
            model
        );
    }
}