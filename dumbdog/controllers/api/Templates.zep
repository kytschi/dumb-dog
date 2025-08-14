/**
 * DumbDog API for templates controller
 *
 * @package     DumbDog\Controllers\Api\Templates
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Templates as MainTemplates;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Templates extends Controller
{
    public api_routes = [
        "/api/templates/add": [
            "Templates",
            "add"
        ],
        "/api/templates/delete": [
            "Templates",
            "delete"
        ],
        "/api/templates/edit": [
            "Templates",
            "edit"
        ],
        "/api/templates/recover": [
            "Templates",
            "recover"
        ],
        "/api/templates": [
            "Templates",
            "list"
        ]
    ];

    public valid_sorts = ["name", "created_at"];
    
    public function add(path)
    {
        var data = [], model = null, status = false, controller;

        this->secure();

        if (!empty(_POST)) {
            let controller = new MainTemplates();

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
                "INSERT INTO templates  
                    (id,
                    type,
                    name,
                    file,
                    is_default,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by) 
                VALUES 
                    (
                    :id,
                    :type,
                    :name,
                    :file,
                    :is_default,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by)",
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the template",
                    400
                );
            } else {
                let model = this->database->get(
                    "SELECT * 
                    FROM templates 
                    WHERE id=:id",
                    [
                        "id": data["id"]
                    ]
                );

                return this->createReturn(
                    "Template successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the template, no post data",
            400
        );
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new MainTemplates();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Template not found");
        }

        controller->triggerDelete("templates", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        return this->createReturn(
            "Template successfully marked as deleted",
            model
        );
    }

    public function edit(path)
    {
        var model, data = [], status = false, controller;

        this->secure();

        let controller = new MainTemplates();
        
        let data["id"] = controller->getPageId(path);
        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Template not found");
        }

        if (!empty(_POST)) {
            if (!controller->validate(_POST, ["name", "file"])) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    ["name", "file"]
                );
            } else {
                let data = controller->setData(data, this->api_app->created_by, model);

                if (this->cfg->save_mode == true) {
                    if (data["is_default"]) {
                        let status = this->database->execute(
                            "UPDATE templates SET `is_default`=0, updated_at=NOW(), updated_by=:updated_by",
                            data
                        );
                    }
                    let status = this->database->execute(
                        "UPDATE templates SET 
                            name=:name,
                            file=:file,
                            type=:type,
                            `is_default`=:is_default,
                            updated_at=NOW(),
                            updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );
                } else {
                    let status = true;
                }

                if (!is_bool(status)) {
                    throw new SaveException(
                        "Failed to update the template",
                        400
                    );
                } else {
                    let model = this->database->get(
                        "SELECT * 
                        FROM templates 
                        WHERE id=:id",
                        [
                            "id": data["id"]
                        ]
                    );

                    return this->createReturn(
                        "Template successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the template, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC";

        this->secure();

        let query = "
            SELECT * 
            FROM templates 
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
            "Templates",
            results,
            isset(_GET["query"]) ? _GET["query"] : null
        );
    }

    public function recover(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new MainTemplates();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Template not found");
        }

        controller->triggerRecover("templates", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        return this->createReturn(
            "Template successfully recovered from the deleted state",
            model
        );
    }
}