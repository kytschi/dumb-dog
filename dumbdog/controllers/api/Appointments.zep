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
use DumbDog\Controllers\Appointments as MainAppointments;
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
            let controller = new MainAppointments();

            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            }

            let data["id"] = this->database->uuid();
            let data["created_by"] = this->api_app->created_by;
            let data["type"] = "appointment";

            let data = controller->setData(data, this->api_app->created_by);

            let status = this->database->execute(
                "INSERT INTO content 
                    (id,
                    status,
                    name,
                    title,
                    sub_title,
                    slogan,
                    url,
                    content,
                    template_id,
                    meta_keywords,
                    meta_author,
                    meta_description,
                    type,
                    tags,
                    featured,
                    parent_id,
                    sort,
                    sitemap_include,
                    public_facing,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by) 
                VALUES 
                    (:id,
                    :status,
                    :name,
                    :title,
                    :sub_title,
                    :slogan,
                    :url,
                    :content,                            
                    :template_id,
                    :meta_keywords,
                    :meta_author,
                    :meta_description,
                    :type,
                    :tags,
                    :featured,
                    :parent_id,
                    :sort,
                    :sitemap_include,
                    :public_facing,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by)",
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

                controller->updateExtra(model, path);

                let model = this->database->get(
                    "SELECT main_page.*,
                    appointments.user_id,
                    appointments.lead_id,
                    appointments.with_email, 
                    appointments.with_number,
                    appointments.on_date,
                    appointments.appointment_length,
                    appointments.free_slot,
                    IFNULL(templates.name, 'No template') AS template, 
                    IFNULL(parent_page.name, 'No parent') AS parent 
                    FROM content AS main_page 
                    JOIN appointments ON appointments.content_id = main_page.id 
                    LEFT JOIN templates ON templates.id=main_page.template_id 
                    LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id 
                    WHERE main_page.id=:id",
                    [
                        "id": data["id"]
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

        let controller = new MainAppointments();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.id=:id",
            [
                "id": data["id"]
            ]
        );

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        controller->triggerDelete("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            "SELECT main_page.*,
            appointments.user_id,
            appointments.lead_id,
            appointments.with_email, 
            appointments.with_number,
            appointments.on_date,
            appointments.appointment_length,
            appointments.free_slot 
            IFNULL(templates.name, 'No template') AS template, 
            IFNULL(parent_page.name, 'No parent') AS parent 
            FROM content AS main_page 
            JOIN appointments ON appointments.content_id = content.id 
            LEFT JOIN templates ON templates.id=main_page.template_id 
            LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id 
            WHERE main_page.id=:id",
            [
                "id": data["id"]
            ]
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

        let controller = new MainAppointments();
                
        let data["id"] = controller->getPageId(path);
        let model = this->database->get(
            "SELECT content.* FROM content WHERE id=:id",
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
                    "UPDATE content SET 
                        status=:status,
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        slogan=:slogan,
                        url=:url,
                        template_id=:template_id,
                        content=:content,
                        meta_keywords=:meta_keywords,
                        meta_author=:meta_author,
                        meta_description=:meta_description,
                        updated_at=NOW(),
                        updated_by=:updated_by,
                        tags=:tags,
                        featured=:featured,
                        parent_id=:parent_id,
                        sort=:sort,
                        sitemap_include=:sitemap_include,
                        public_facing=:public_facing 
                    WHERE id=:id",
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
    
                    controller->updateExtra(model, path);

                    let model = this->database->get(
                        "SELECT main_page.*,
                        appointments.user_id,
                        appointments.lead_id,
                        appointments.with_email, 
                        appointments.with_number,
                        appointments.on_date,
                        appointments.appointment_length,
                        appointments.free_slot, 
                        IFNULL(templates.name, 'No template') AS template, 
                        IFNULL(parent_page.name, 'No parent') AS parent 
                        FROM content AS main_page 
                        JOIN appointments ON appointments.content_id = main_page.id 
                        LEFT JOIN templates ON templates.id=main_page.template_id 
                        LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id 
                        WHERE main_page.id=:id",
                        [
                            "id": data["id"]
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
        var data = [], query, results, sort_dir = "ASC";

        this->secure();

        let query = "
            SELECT
                content.*,
                appointments.user_id,
                appointments.lead_id,
                appointments.with_email, 
                appointments.with_number,
                appointments.on_date,
                appointments.appointment_length,
                appointments.free_slot 
            FROM content 
            JOIN appointments ON appointments.content_id = content.id ";

        if (isset(_GET["query"])) {
            let query .= " AND content.name LIKE :query";
            let data["query"] = "%" . _GET["query"] . "%";
        }

        if (isset(_GET["tag"])) {
            let query .= " AND content.tags LIKE :tag";
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

            let query .= " ORDER BY content." . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY content.name " . sort_dir;
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

        let controller = new MainAppointments();

        let data["id"] = controller->getPageId(path);

        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.id=:id",
            [
                "id": data["id"]
            ]
        );

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        controller->triggerRecover("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            "SELECT main_page.*,
            appointments.user_id,
            appointments.lead_id,
            appointments.with_email, 
            appointments.with_number,
            appointments.on_date,
            appointments.appointment_length,
            appointments.free_slot 
            IFNULL(templates.name, 'No template') AS template, 
            IFNULL(parent_page.name, 'No parent') AS parent 
            FROM content AS main_page 
            JOIN appointments ON appointments.content_id = content.id 
            LEFT JOIN templates ON templates.id=main_page.template_id 
            LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id 
            WHERE main_page.id=:id",
            [
                "id": data["id"]
            ]
        );

        return this->createReturn(
            "Appointment successfully recovered from the deleted state",
            model
        );
    }
}