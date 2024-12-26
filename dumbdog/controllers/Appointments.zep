/**
 * Dumb Dog appointments
 *
 * @package     DumbDog\Controllers\Appointments
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Dates;

class Appointments extends Content
{
    public global_url = "/appointments";
    public type = "appointment";
    public title = "Appointments";
    public required = ["name", "on_date", "on_time", "appointment_length"];
    public list = [
        "name|with_tags",
        "title"        
    ];

    public function add(string path)
    {
        var html, data = [], model;

        let html = this->titles->page("Create an appointment", "appointments");
        let model = new \stdClass();

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                
                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->database->getUserId();
                    let data["type"] = this->type;

                    let data = this->setData(data);
                    
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
                            sitemap_include,
                            public_facing,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (
                            :id,
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
                            :sitemap_include,
                            :public_facing,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the appointments");
                        let html .= this->consoleLogError(status);
                    } else {
                        if (isset(_FILES["banner_image"]["name"])) {
                            if (!empty(_FILES["banner_image"]["name"])) {
                                this->files->addResource("banner_image", data["id"], "image");
                            }
                        }
                        let model->id = data["id"];
                        let path = this->updateExtra(model, path);
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Appointments has been saved");
        }

        let model->deleted_at = null;
        let model->status = "live";
        let model->name = "";
        let model->title = "";
        let model->sub_title = "";
        let model->feature = false;
        let model->content = "";
        let model->sitemap_include = false;
        let model->public_facing = false;
        let model->tags = "";
        let model->url = "";

        if (isset(_GET["lead_id"])) {
            let data = this->database->get("
                SELECT contacts.*
                FROM leads
                JOIN contacts ON contacts.id = leads.contact_id 
                WHERE leads.id=:id",
                [
                    "id": _GET["lead_id"]
                ]
            );

            if (!empty(data)) {
                let model->name = "Appointment with " .
                    this->database->decrypt(data->first_name) .
                    (!empty(data->last_name) ? " " . this->database->decrypt(data->last_name) : "");
            }
        }
        
        let html .= this->render(model);

        return html;
    }
    
    public function edit(string path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                appointments.*,
                content.*,
                IF(banner.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-',  banner.filename), '') AS banner_image
            FROM content 
            LEFT JOIN files AS banner ON 
                banner.resource_id = content.id AND
                resource='banner-image' AND
                banner.deleted_at IS NULL
            JOIN appointments ON appointments.content_id = content.id 
            WHERE content.type='" . this->type . "' AND content.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        let html = this->titles->page("Edit the appointment", "appointments");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = this->global_url . "/edit/" . model->id;

                if (isset(_POST["delete"])) {
                    if (!empty(_POST["delete"])) {
                        this->triggerDelete("content", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("content", path);
                    }
                }

                let path = path . "?saved=true";

                let data = this->setData(data);
                
                if (isset(_FILES["banner_image"]["name"])) {
                    if (!empty(_FILES["banner_image"]["name"])) {
                        this->files->addResource("banner_image", data["id"], "banner-image");
                    }
                }

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
                        sitemap_include=:sitemap_include 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the review");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        let path = this->updateExtra(model, path);
                        this->redirect(path);
                    } catch ValidationException, err {
                        let html .= this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the appointment");
        }

        let html .= this->render(model, "edit");
        return html;
    }

    public function index(string path)
    {
        var html;
        
        let html = this->titles->page("Appointments", "appointments");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the appointment");
        }
        
        let html .= this->renderToolbar();
        
        var days, iLoop = 0, start, blanks = 0, data, entry, today = 0, date;
        
        if (isset(_GET["date"])) {
            let date = _GET["date"];
        } else {
            let date = date("Y-m");
        }

        let start = date("l", strtotime(date(date . "-01")));
        if (date("Y-m") == date) {
            let today = intval(date("d"));
        }
        
        let html .= "
        <div id='dd-calendar-month' class='dd-flex'>" .
            this->buttons->previous(this->global_url . "?date=" . date("Y-m", strtotime("-1 months", strtotime(date . "-01"))), "Previous month") .
            "<span>" . date("F Y", strtotime(date . "-01")) . "</span>" . 
            this->buttons->next(this->global_url . "?date=" . date("Y-m", strtotime("+1 months", strtotime(date . "-01"))), "Next month") .
        "</div>
        <div id='dd-calendar'>";
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        while(iLoop < count(days)) {
            let html .= "<div class='dd-calendar-day'>" . days[iLoop] . "</div>";
            if (days[iLoop] == start) {
                let blanks = iLoop;
            }
            let iLoop = iLoop + 1;
        }

        if (blanks) {
            let iLoop = 0;
            while(iLoop < blanks) {
                let html .= "<div class='dd-calendar-blank'></div>";
                let iLoop = iLoop + 1;
            }
        }

        let days = cal_days_in_month(CAL_GREGORIAN, date("m"), date("Y"));
        let iLoop = 1;
        while(iLoop <= days) {
            let html .= "<div class='dd-calendar-entry";
            if (iLoop == today) {
                let html .= " dd-calendar-today";
            } elseif (iLoop < today) {
                let html .= " dd-calendar-blank";
            }
            let html .= "'><div class='dd-calendar-date'>" . iLoop ."</div>";
            let data = this->database->all(
                "SELECT
                    appointments.*,
                    content.*  
                FROM content 
                JOIN appointments ON appointments.content_id = content.id  
                WHERE 
                    on_date BETWEEN CONCAT(:on_date, ' 00:00') AND
                    CONCAT(:on_date, ' 23:59')
                ORDER BY on_date",
                [
                    "on_date": date(date . "-" . iLoop)
                ]
            );
            if (data) {
                for entry in data {
                    let html .= "<div class='dd-calendar-event";
                    if (entry->free_slot) {
                        let html .= " dd-calendar-free-slot";
                    }
                    let html .= "'><a href='" .this->global_url . "/edit/" . entry->id . "' class='dd-link'>
                        <small>" .date("H:i", strtotime(entry->on_date));
                    if (entry->free_slot) {
                        let html .= "&nbsp;<span>free slot</span>";
                    }
                    let html .= "</small><br/>" . 
                        entry->name . 
                    "</a></div>";
                }
            }
            let html .= "</div>";
            let iLoop = iLoop + 1;
        }
        let html .= "</div>";
        
        return html;
    }

    public function render(model, mode = "add")
    {
        var html = "";

        if (!empty(model->on_date)) {
            let model->on_time = (new Dates())->getTime(model->on_date, false);
        }

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='content-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Set live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                    this->inputs->text("Name", "name", "Name the appointment", true, model->name) .
                                    this->inputs->date("On date", "on_date", "When the appointment is", true, model->on_date) .
                                    this->inputs->text("On time", "on_time", "What time is the appointment", true, model->on_time) .
                                    this->inputs->select(
                                        "Length",
                                        "appointment_length",
                                        "Appointment length",
                                        [
                                            "1": "1 hour",
                                            "2": "2 hours",
                                            "4": "4 hours",
                                            "all_day": "all day",
                                            "daily": "daily",
                                            "weekly": "weekly",
                                            "monthly": "monthly",
                                            "annually": "annually"
                                        ],
                                        true,
                                        model->appointment_length
                                    ) . 
                                    this->inputs->toggle("Free slot", "free_slot", false, model->free_slot) . 
                                    this->userSelect(model->user_id) . 
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='public-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>Public</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Public", "public_facing", false, model->public_facing) . 
                                    this->inputs->text("Title", "title", "The appointment title", false, model->title) .
                                    this->inputs->text("Sub title", "sub_title", "The appointment sub title", false, model->sub_title) .
                                    this->inputs->textarea("Slogan", "slogan", "The appointment slogan", false, model->slogan, 500) .
                                    this->inputs->wysiwyg("Content", "content", "The appointment content", false, model->content) . 
                                    this->inputs->toggle("Feature", "featured", false, model->featured) . 
                                    this->inputs->tags("Tags", "tags", "Tag the appointment", false, model->tags) .
                                    this->inputs->text("Path", "url", "The path for the page", false, model->url) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='seo-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>SEO</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Sitemap include", "sitemap_include", false, model->sitemap_include) . 
                                    this->inputs->text("Meta keywords", "meta_keywords", "Help search engines find the page", false, model->meta_keywords) .
                                    this->inputs->text("Meta author", "meta_author", "The author of the page", false, model->meta_author) .
                                    this->inputs->textarea("Meta description", "meta_description", "A short description of the page", false, model->meta_description) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>Look and Feel</div>
                                <div class='dd-box-body'>" .
                                    this->templatesSelect(model->template_id) . 
                                    this->inputs->image("Banner image", "banner_image", "Upload your banner image here", false, model->banner_image) . 
                                "</div>
                            </div>
                        </div>
                    </div>";

        if (mode == "edit") {
            let html .= this->renderStacks(model);
            let html .= this->renderOldUrls(model);
        }

        let html .= "
                </div>
                <ul class='dd-col dd-nav-tabs' role='tablist'>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#content-tab'
                            aria-controls='content-tab' 
                            aria-selected='true'>Appointment</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#public-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='public-tab' 
                            aria-selected='true'>Public</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#seo-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='seo-tab' 
                            aria-selected='true'>SEO</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#look-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='look-tab' 
                            aria-selected='true'>Look and Feel</button>
                    </li>";
        if (mode == "edit") {
            let html .= "
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#stack-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='stack-tab' 
                            aria-selected='true'>Stacks</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#old-urls-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='old-urls-tab' 
                            aria-selected='true'>Old URLs</button>
                    </li>";
        }

        let html .= "<li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>" . 
                        this->buttons->generic(
                            isset(_GET["lead_id"]) ?
                                this->cfg->dumb_dog_url . "/leads/edit/" . _GET["lead_id"] :
                                this->global_url,
                            "back",
                            "back",
                            isset(_GET["lead_id"]) ?
                                "Back to the lead" :
                                "Go back to the list"
                        ) .
                    "</li>";
        if (mode == "edit") {
            let html .= "
                <li class='dd-nav-item' role='presentation'>" . 
                    this->buttons->generic(
                        this->global_url . "/add",
                        "add",
                        "add",
                        "Create a new " . str_replace("-", " ", this->type)
                    ) .
                "</li>
                <li class='dd-nav-item' role='presentation'>" .
                    this->buttons->view(model->url) .
                "</li>";
            if (!empty(model->lead_id)) {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->generic(
                        this->cfg->dumb_dog_url . "/leads/edit/" . model->lead_id,
                        "lead",
                        "leads",
                        "View the lead"
                    ) .
                "</li>";
            }
            if (model->deleted_at) {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->recover(model->id) . 
                "</li>";
            } else {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->delete(model->id) . 
                "</li>";
            }
        }

        let html .= "<li class='dd-nav-item' role='presentation'>". 
                        this->buttons->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }

    public function renderToolbar()
    {
        var html;
        
        let html = "<div class='dd-page-toolbar'>";

        if (this->back_url) {
            let html .= this->buttons->round(
                this->cfg->dumb_dog_url . this->back_url,
                "Back",
                "back",
                "Go back to the appointments"
            );
        }

        let html .= 
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new appointment"
            ) .
        "</div>";

        return html;
    }

    private function setData(array data)
    {
        if (empty(_POST["url"])) {
            let data["url"] = "/appointments/" . this->createSlug(!empty(_POST["title"]) ? _POST["title"] : _POST["name"]);
        }
        let data = this->setContentData(data);

        let data["public_facing"] = isset(_POST["public_facing"]) ? 1 : 0;

        return data;
    }

    private function setAppointmentData(array data)
    {
        let data["user_id"] = isset(_POST["user_id"]) ? _POST["user_id"] : null;
        let data["with_email"] = isset(_POST["with_email"]) ? _POST["with_email"] : null;
        let data["with_number"] = isset(_POST["with_number"]) ? _POST["with_number"] : null;
        let data["free_slot"] = isset(_POST["free_slot"]) ? 1 : 0;
        let data["appointment_length"] = isset(_POST["appointment_length"]) ? _POST["appointment_length"] : null;
        let data["on_date"] = this->database->toDate(_POST["on_date"] . " " . _POST["on_time"] . ":00");
        let data["lead_id"] = isset(_GET["lead_id"]) ? _GET["lead_id"] : null;
        
        return data;
    }

    public function updateExtra(model, path)
    {
        var data, status = false, required = ["appointment_length", "on_date"];

        let data = this->database->get("
            SELECT *
            FROM appointments 
            WHERE content_id='" . model->id . "'");

        if (!empty(data)) {
            if (!this->validate(_POST, required)) {
                throw new ValidationException("Missing required data");
            }

            let data = this->setAppointmentData(["id": data->id]);
                        
            let status = this->database->get("
                UPDATE appointments SET
                    user_id=:user_id,
                    with_email=:with_email,
                    with_number=:with_number,
                    free_slot=:free_slot,
                    appointment_length=:appointment_length,
                    on_date=:on_date,
                    lead_id=:lead_id 
                WHERE id=:id",
                data
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to update the appointment");
            }
        } else {
            let data = this->setAppointmentData(["content_id": model->id]);

            let status = this->database->get("
                INSERT INTO appointments 
                (
                    id,
                    content_id,
                    user_id,
                    with_email,
                    with_number,
                    free_slot,
                    appointment_length,
                    on_date,
                    lead_id
                ) VALUES
                (
                    UUID(),
                    :content_id,
                    :user_id,
                    :with_email,
                    :with_number,
                    :free_slot,
                    :appointment_length,
                    :on_date,
                    :lead_id
                )",
                data
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to create the appointment");
            }
        }

        return path;
    }

    private function userSelect(selected = null)
    {
        var select = ["": "available to all"], data;
        let data = this->database->all(
            "SELECT *
            FROM users  
            ORDER BY nickname"
        );
        var iLoop = 0;

        if (isset(_POST["user_id"])) {
            let selected = _POST["user_id"];
        } elseif (isset(_GET["lead_id"])) {
            let selected = this->database->getUserId();
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->nickname;
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Owner",
            "user_id",
            "Who owns this appointment?",
            select,
            false,
            selected
        );
    }
}