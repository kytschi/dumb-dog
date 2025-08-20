/**
 * DumbDog API for Settings controller
 *
 * @package     DumbDog\Controllers\Api\Settings
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Settings as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Settings extends Controller
{
    public api_routes = [
        "/api/settings/edit": [
            "Settings",
            "edit"
        ],
        "/api/settings/view": [
            "Settings",
            "view"
        ]
    ];

    public valid_sorts = ["name", "created_at"];
    
    public function edit(path)
    {
        var model, data = [], status = false, controller;

        this->secure();

        let controller = new Main();

        let model = this->database->get(
            controller->query
        );

        if (empty(model)) {
            throw new NotFoundException("Settings not found");
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
                        "Failed to update the settings",
                        400
                    );
                } else {
                    let model = this->database->get(
                        controller->query
                    );

                    return this->createReturn(
                        "Settings successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the settings, no post data",
            400
        );
    }

    public function view(path)
    {
        var model, controller;

        this->secure();

        let controller = new Main();
        
        let model = this->database->get(
            controller->query
        );

        if (empty(model)) {
            throw new NotFoundException("Settings not found");
        }

        return this->createReturn(
            "Settings",
            model
        );
    }
}