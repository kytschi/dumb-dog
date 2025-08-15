/**
 * DumbDog API for content stacks controller
 *
 * @package     DumbDog\Controllers\Api\ContentStacks
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\ContentStacks as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class ContentStacks extends Controller
{
    public api_routes = [
        "/api/content-stacks/add": [
            "ContentStacks",
            "add"
        ],
        "/api/content-stacks/delete": [
            "ContentStacks",
            "delete"
        ],
        "/api/content-stacks/edit": [
            "ContentStacks",
            "edit"
        ],
        "/api/content-stacks/recover": [
            "ContentStacks",
            "recover"
        ],
        "/api/content-stacks": [
            "ContentStacks",
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

            let data = controller->setData(data, this->api_app->created_by);

            let status = this->database->execute(
                "INSERT INTO content_stacks 
                    (id,
                    content_id,
                    content_stack_id,
                    template_id,
                    sort,
                    name,
                    title,
                    sub_title,
                    content,
                    tags,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by) 
                VALUES 
                    (:id,
                    :content_id,
                    :content_stack_id,
                    :template_id,
                    :sort,
                    :name,
                    :title,
                    :sub_title,                            
                    :content,
                    :tags,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by)",
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the content stack",
                    400
                );
            } else {
                let model = this->database->get(
                    "SELECT * FROM content_stacks WHERE id=:id",
                    [
                        "id": data["id"]
                    ]
                );

                return this->createReturn(
                    "Content stack successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the content stack, no post data",
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
            "SELECT * FROM content_stacks WHERE id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Content stack not found");
        }

        controller->triggerDelete("content_stacks", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            "SELECT * FROM content_stacks WHERE id=:id",
            data
        );

        return this->createReturn(
            "Content stack successfully marked as deleted",
            model
        );
    }

    public function edit(path)
    {
        var model, data = [], controller, status = false;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        let model = this->database->get(
            "SELECT * FROM content_stacks WHERE id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Content stack not found");
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
                    "UPDATE content_stacks SET 
                        content_id=:content_id,
                        content_stack_id=:content_stack_id,
                        template_id=:template_id,
                        sort=:sort,
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        content=:content,
                        tags=:tags,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    throw new SaveException(
                        "Failed to update the content stack",
                        400
                    );
                } else {
                    let model = this->database->get(
                        "SELECT * FROM content_stacks WHERE id=:id",
                        [
                            "id": data["id"]
                        ]
                    );
    
                    return this->createReturn(
                        "Content stack successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the content stack, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC";

        this->secure();

        let query = "
            SELECT * FROM content_stacks";

        if (isset(_GET["query"])) {
            let query .= " AND name LIKE :query";
            let data["query"] = "%" . _GET["query"] . "%";
        }

        if (isset(_GET["tag"])) {
            let query .= " AND tags LIKE :tag";
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

            let query .= " ORDER BY " . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY name " . sort_dir;
        }        

        let results = this->database->all(query, data);

        return this->createReturn(
            "Content stacks",
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
            "SELECT * FROM content_stacks WHERE id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Content stack not found");
        }

        controller->triggerRecover("content_stacks", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            "SELECT * FROM content_stacks WHERE id=:id",
            data
        );

        return this->createReturn(
            "Content stack successfully recovered from the deleted state",
            model
        );
    }
}