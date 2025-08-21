/**
 * DumbDog API for pages controller
 *
 * @package     DumbDog\Controllers\Api\Pages
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Content;
use DumbDog\Controllers\Files;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Pages extends Controller
{
    public api_routes = [
        "/api/pages/add": [
            "Pages",
            "add"
        ],
        "/api/pages/delete": [
            "Pages",
            "delete"
        ],
        "/api/pages/edit": [
            "Pages",
            "edit"
        ],
        "/api/pages/recover": [
            "Pages",
            "recover"
        ],
        "/api/pages/view": [
            "Pages",
            "view"
        ],
        "/api/pages": [
            "Pages",
            "list"
        ]
    ];

    public valid_sorts = ["name", "created_at"];

    public function add(path)
    {
        var data = [], model = null, status = false, controller;

        this->secure();

        if (!empty(_POST)) {
            let controller = new Content();

            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            }

            let data["id"] = this->database->uuid();
            let data["created_by"] = this->api_app->created_by;
            let data["type"] = "page";

            let data = controller->setData(data, this->api_app->created_by);

            let status = this->database->execute(
                controller->query_insert,
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the page",
                    400
                );
            } else {
                let model = this->database->get(
                    controller->query . " WHERE main_page.id=:id",
                    [
                        "id": data["id"]
                    ]
                );

                return this->createReturn(
                    "Page successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the page, no post data",
            400
        );
    }

    public function createReturn(message, data = null, query = null, code = 200)
    {
        var parent_page = null, controller;

        let controller = new Content();

        if (!is_array(data)) {
            let data->tags = controller->toTags(data->tags);

            let data->images = this->database->all(
                controller->query_images,
                [
                    "resource_id": data->id
                ]
            );
            let data->stacks = this->database->all(
                controller->query_stacks,
                [
                    "id": data->id
                ]
            );

            if (data->parent_id) {
                let parent_page = this->database->get(
                    controller->query_parent,
                    [
                        "id": data->parent_id
                    ]
                );

                let parent_page->images = this->database->all(
                    controller->query_images,
                    [
                        "resource_id": parent_page->id
                    ]
                );
                let parent_page->stacks = this->database->all(
                    controller->query_stacks,
                    [
                        "id": parent_page->id
                    ]
                );
            }

            let data->parent = parent_page;

            let data->children = this->database->all(
                controller->query_children, 
                [
                    "parent_id": data->id
                ]
            );

            let data->old_urls = this->database->all(
                controller->query_old_urls,
                [
                    "id": data->id
                ]
            );
        }

        return parent::createReturn(message, data, query, code);
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Content();

        let data["id"] = controller->getPageId(path);
        let data["type"] = "page";

        let model = this->database->get(
            "SELECT * FROM content WHERE type=:type AND id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Page not found");
        }

        controller->triggerDelete("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query . " WHERE main_page.id=:id",
            [
                "id": data["id"]
            ]
        );

        return this->createReturn(
            "Page successfully marked as deleted",
            model
        );
    }

    public function edit(path)
    {
        var model, data = [], controller, status = false;

        this->secure();

        let controller = new Content();
                
        let data["id"] = controller->getPageId(path);
        let data["type"] = "page";
        let model = this->database->get(
            "SELECT * FROM content WHERE type=:type AND id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Page not found");
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
                        "Failed to update the page",
                        400
                    );
                } else {
                    let model = this->database->get(
                        controller->query . " WHERE main_page.id=:id",
                        [
                            "id": data["id"]
                        ]
                    );
    
                    return this->createReturn(
                        "Page successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the page, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC", controller;

        this->secure();

        let controller = new Content();

        let query = controller->query . " WHERE main_page.type='page'";

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
            "Pages",
            results,
            isset(_GET["query"]) ? _GET["query"] : null
        );
    }

    public function recover(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Content();

        let data["id"] = controller->getPageId(path);
        let data["type"] = "page";

        let model = this->database->get(
            "SELECT * FROM content WHERE type=:type AND id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Page not found");
        }

        controller->triggerRecover("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query . " WHERE main_page.type=:type AND main_page.id=:id",
            data
        );

        return this->createReturn(
            "Page successfully recovered from the deleted state",
            model
        );
    }

    public function view(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Content();
                
        let data["id"] = controller->getPageId(path);
        let data["type"] = "page";

        let model = this->database->get(
            controller->query . " WHERE main_page.type=:type AND main_page.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Page not found");
        }

        return this->createReturn(
            "Page",
            model
        );
    }
}