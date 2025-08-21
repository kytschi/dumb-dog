/**
 * DumbDog API for messages controller
 *
 * @package     DumbDog\Controllers\Api\Messages
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Messages as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Messages extends Controller
{
    public api_routes = [
        "/api/messages/add": [
            "Messages",
            "add"
        ],
        "/api/messages/delete": [
            "Messages",
            "delete"
        ],
        "/api/messages/read": [
            "Messages",
            "read"
        ],
        "/api/messages/recover": [
            "Messages",
            "recover"
        ],
        "/api/messages/unread": [
            "Messages",
            "unread"
        ],
        "/api/messages/view": [
            "Messages",
            "view"
        ],
        "/api/messages": [
            "Messages",
            "list"
        ]
    ];

    public valid_sorts = ["message", "created_at"];
    
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

            let status = controller->save(data);
            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the message",
                    400
                );
            } else {
                let model = this->database->decrypt(
                    controller->decrypt,
                    this->database->get(
                        controller->query,
                        [
                            "id": data["id"]
                        ]
                    )
                );
                
                return this->createReturn(
                    "Message successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the message, no post data",
            400
        );
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get(controller->query, data);

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        controller->triggerDelete("messages", path, data["id"], this->api_app->created_by, false);

        let model = this->database->decrypt(
            controller->decrypt,
            this->database->get(controller->query, data)
        );

        return this->createReturn(
            "Message successfully marked as deleted",
            model
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "DESC", controller;

        this->secure();

        let controller = new Main();

        let query = controller->query_list;

        if (isset(_GET["query"])) {
            let query .= " AND message LIKE :query";
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
            let query .= " ORDER BY messages.created_at " . sort_dir;
        }        

        let results = this->database->decrypt(
            controller->decrypt,
            this->database->all(query, data)
        );

        return this->createReturn(
            "Messages",
            results,
            isset(_GET["query"]) ? _GET["query"] : null
        );
    }

    public function read(path)
    {
        var model, data = [], controller, status;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get(controller->query, data);

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let status = this->database->execute(
            controller->query_read,
            [
                "id": data["id"],
                "updated_by": this->api_app->created_by
            ]
        );

        if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to mark the message as read",
                    400
                );
        } else {
            let model = this->database->decrypt(
                controller->decrypt,
                this->database->get(controller->query, data)
            );

            return this->createReturn(
                "Message successfully marked as read",
                model
            );
        }
    }

    public function recover(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get(controller->query, data);

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        controller->triggerRecover("messages", path, data["id"], this->api_app->created_by, false);

        let model = this->database->decrypt(
            controller->decrypt,
            this->database->get(controller->query, data)
        );

        return this->createReturn(
            "Message successfully recovered from the deleted state",
            model
        );
    }

    public function unread(path)
    {
        var model, data = [], controller, status;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get(controller->query, data);

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let status = this->database->execute(
            controller->query_unread,
            [
                "id": data["id"],
                "updated_by": this->api_app->created_by
            ]
        );

        if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to mark the message as unread",
                    400
                );
        } else {
            let model = this->database->decrypt(
                controller->decrypt,
                this->database->get(controller->query, data)
            );

            return this->createReturn(
                "Message successfully marked as unread",
                model
            );
        }
    }

    public function view(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        
        let model = this->database->decrypt(
            controller->decrypt,
            this->database->get(controller->query, data)
        );

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        return this->createReturn(
            "Message",
            model
        );
    }
}