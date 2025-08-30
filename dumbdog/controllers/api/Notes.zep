/**
 * DumbDog API for Notes controller
 *
 * @package     DumbDog\Controllers\Api\Notes
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Notes as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Notes extends Controller
{
    public api_routes = [
        "/api/notes/add": [
            "Notes",
            "add"
        ],
        "/api/notes/delete": [
            "Notes",
            "delete"
        ],
        "/api/notes/view": [
            "Notes",
            "view"
        ],
        "/api/notes": [
            "Notes",
            "list"
        ]
    ];

    public valid_sorts = ["content", "created_at"];
    
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
            let data["resource_id"] = null;

            let data = controller->setData(data, this->api_app->created_by);     

            let status = this->database->execute(
                controller->query_insert,
                this->database->encrypt(controller->encrypt, data)
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the note entry",
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
                    "Note entry successfully created",
                    this->database->decrypt(controller->encrypt, model)
                );
            }
        }

        throw new SaveException(
            "Failed to save the note entry, no post data",
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
            throw new NotFoundException("Note entry not found");
        }

        controller->triggerDelete("notes", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            controller->query,
            data
        );

        return this->createReturn(
            "Note entry successfully marked as deleted",
            this->database->decrypt(controller->encrypt, model)
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "DESC", controller;

        this->secure();

        let controller = new Main();

        let query = controller->query_list;

        if (isset(_GET["query"])) {
            let query .= " AND content LIKE :query";
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
            let query .= " ORDER BY created_at " . sort_dir;
        }        

        let results = this->database->all(query, data);

        return this->createReturn(
            "Notes",
            this->database->decrypt(controller->encrypt, results),
            isset(_GET["query"]) ? _GET["query"] : null
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
            throw new NotFoundException("Note entry not found");
        }

        return this->createReturn(
            "Note entry",
            this->database->decrypt(controller->encrypt, model)
        );
    }
}