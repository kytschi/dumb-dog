/**
 * Dumb Dog leads
 *
 * @package     DumbDog\Controllers\Leads
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers;

use DumbDog\Controllers\Contacts;
use DumbDog\Controllers\Messages;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Dates;

class Leads extends Contacts
{
    public global_url = "/leads";
    public list = [
        "icon|ranking",
        "full_name|with_tags",
        "email|decrypt",
        "phone|decrypt",
        "owner"
    ];

    public title = "Leads";
    public type = "lead";

    public routes = [
        "/leads/add": [
            "Leads",
            "add",
            "create a lead"
        ],
        "/leads/edit": [
            "Leads",
            "edit",
            "manage the lead"
        ],
        "/leads": [
            "Leads",
            "index",
            "leads"
        ]
    ];

    public rankings = [
        "terrible",
        "poor",
        "ok",
        "good",
        "excellent"
    ];

    public person_titles = [
        "": "Unknown",
        "Mr": "Mr",
        "Ms": "Ms",
        "Mrs": "Mrs",
        "Dr": "Dr"
    ];

    public function __globals()
    {
        parent::__globals();

        let this->query = "
            SELECT 
                users.nickname AS owner,
                contacts.*,
                leads.id,
                leads.contact_id,
                leads.ranking,
                appointments.content_id AS appointment_id,
                appointments.on_date 
            FROM leads
            JOIN contacts ON contacts.id = leads.contact_id 
            LEFT JOIN appointments ON appointments.lead_id = leads.id  
            LEFT JOIN users ON users.id = leads.user_id";

        let this->query_insert = "
            INSERT INTO leads 
                (
                    id,
                    contact_id,
                    user_id,
                    ranking,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by
                ) 
            VALUES 
                (
                    :id,
                    :contact_id,
                    :user_id,
                    :ranking,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by
                )";

        let this->query_update = "
            UPDATE leads 
            SET 
                user_id=:user_id,
                ranking=:ranking,
                updated_by=:updated_by,
                updated_at=NOW()
            WHERE id=:id";

        let this->query_list = "
            SELECT 
                users.nickname AS owner,
                contacts.*,
                leads.id,
                leads.ranking  
            FROM leads
            JOIN contacts ON contacts.id = leads.contact_id 
            LEFT JOIN users ON users.id = leads.user_id 
            WHERE leads.id IS NOT NULL ";
    }

    public function add(path)
    {
        var html, data, status = false;
        
        let html = this->titles->page("Create a lead", "leads");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["user_id"] = this->database->getUserId();

                    let data["contact_id"] = this->saveContact(this->setData(data));

                    let data = this->setData(data);
                    
                    let status = this->database->execute(
                        this->query_insert,
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the menu");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Menu has been saved");
        }

        var model;
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->ranking = "ok";
        let model->user_id= "";

        let html .= this->render(model);

        return html;
    }

    private function setRankingIcon(item)
    {
        switch (item->ranking) {
            case "excellent":
                let item->icon = this->icons->rankingExcellent();
                break;
            case "good":
                let item->icon = this->icons->rankingGood();
                break;
            case "ok":
                let item->icon = this->icons->rankingOK();
                break;
            case "poor":
                let item->icon = this->icons->rankingPoor();
                break;
            case "terrible":
                let item->icon = this->icons->rankingTerrible();
                break;
            default:
                let item->icon = item->ranking;
                break;
        }

        return item;
    }

    public function decryptData(data)
    {
        var item, key;

        let data = this->database->decrypt(this->encrypt, data);

        if (is_array(data)) {
            for key, item in data {
                if (isset(item->first_name) && isset(item->last_name)) {
                    let item->full_name = 
                        item->first_name . 
                        " " . 
                        item->last_name;
                }

                let item = this->setRankingIcon(item);

                let data[key] = item;
            }
        } else {
            if (isset(data->first_name) && isset(data->last_name)) {
                let data->full_name = 
                    data->first_name . 
                    " " . 
                    data->last_name;
            }
            let data = this->setRankingIcon(data);
        }

        return data;
    }

    public function edit(path)
    {
        var html, model, data = [], err, status = false;

        let data["id"] = this->getPageId(path);
        let model = this->database->get(
            this->query . " WHERE leads.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Lead not found");
        }

        let html = this->titles->page("Manage the lead", "edit");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("Lead item has been deleted");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let model = this->database->decrypt(
            this->encrypt,
            model
        );

        if (!empty(_POST)) {
            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("leads", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("leads", path);
                }
            }

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                this->notes->actions(model->id);

                this->updateContact(
                    [
                        "id": model->contact_id
                    ],
                    null,
                    model
                );

                let data = this->setLeadData(
                    [
                        "id": model->id
                    ],
                    null,
                    model
                );

                try {
                    let status = this->database->execute(
                        this->query_update,
                        data
                    );
                } catch Exception, err {
                    throw new SaveException(
                        "Failed to update the lead entry",
                        err->getCode(),
                        err->getMessage()
                    );
                }

                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to save the menu");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        this->redirect(path . "?saved=true");
                    } catch ValidationException, err {
                        let html .= this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the lead");
        }

        let html .= this->render(model, "edit");
        return html;
    }

    public function render(model, mode = "add")
    {
        var html;

        let html = "
        <form method='post' enctype='multipart/form-data'>";

        if (!empty(model->on_date)) {
            let html .= "
            <div class='dd-row'>
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title dd-flex'>
                            <div class='dd-col'>Appointment booked</div>
                            <div class='dd-col-auto'>" . 
                                this->buttons->generic(
                                    this->cfg->dumb_dog_url . "/appointments/edit/" . model->appointment_id,
                                    "",
                                    "edit",
                                    "Edit the appointment"
                                ) .
                            "</div>
                        </div>
                        <div class='dd-box-body dd-flex'>" .
                            (new Dates())->prettyDate(model->on_date, true, false) . 
                        "</div>
                    </div>
                </div>
            </div>";
        }

        let html .= "
            <div class='dd-row'>
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title'>
                            <span>Ranking</span>
                        </div>
                        <div class='dd-box-body dd-flex'>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='terrible' " . 
                                        (model->ranking == "terrible" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingTerrible() .
                                    "   <small class='dd-radio-on'>Terrible</small>
                                        <small class='dd-radio-off'>Terrible</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='poor' " . 
                                        (model->ranking == "poor" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingPoor() .
                                    "   <small class='dd-radio-on'>Poor</small>
                                        <small class='dd-radio-off'>Poor</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='ok' " . 
                                        (model->ranking == "ok" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingOK() .
                                    "   <small class='dd-radio-on'>OK</small>
                                        <small class='dd-radio-off'>OK</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='good' " . 
                                        (model->ranking == "good" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingGood() .
                                    "   <small class='dd-radio-on'>Good</small>
                                        <small class='dd-radio-off'>Good</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='ranking' 
                                        value='excellent' " . 
                                        (model->ranking == "excellent" ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingExcellent() .
                                    "   <small class='dd-radio-on'>Excellent</small>
                                        <small class='dd-radio-off'>Excellent</small>
                                    </span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='lead-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>
                                    <div class='dd-row'>
                                    <div class='dd-col-12'>" . 
                                            this->inputs->toggle("Live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                        "</div>
                                        <div class='dd-col-12'>" . 
                                            this->userSelect(model->user_id) .
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("First name", "first_name", "Set their first name", true, model->first_name) .
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Last name", "last_name", "Set their last name", false, model->last_name) .
                                        "</div>
                                    </div> 
                                    <div class='dd-row'>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Email", "email", "Set their email", false, model->email) .
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Phone", "phone", "Set their phone", false, model->phone) .
                                        "</div>
                                    </div> 
                                    <div class='dd-row'>
                                        <div class='dd-col-6'>" . 
                                            this->inputs->select(
                                                "Title",
                                                "title",
                                                "Their title",
                                                this->person_titles,
                                                false,
                                                model->title
                                            ) .
                                        "</div>
                                        <div class='dd-col-6'>" .
                                            this->inputs->text("Position", "position", "What is their position?", false, model->position) .
                                        "</div>
                                    </div>" . 
                                    this->inputs->text("Website", "website", "Do they have a website?", false, model->website) .
                                    this->inputs->tags("Tags", "tags", "Tag the lead", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>";

        if (mode == "edit") {
            let html .= this->renderMessages(model->id);
            let html .= this->notes->render(model->id);
        }

        let html .= "</div>" .
            this->renderSidebar(model, mode) .
            "</div>
        </form>";

        return html;
    }

    public function renderList(path)
    {
        var data = [], query;

        let query = this->query_list;

        if (isset(_POST["q"])) {
            let query .= " AND contacts.first_name=:first_name";
            let data["first_name"] = this->database->encrypt(_POST["q"]);
        }
        if (isset(_GET["tag"])) {
            let query .= " AND leads.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }

        if (!this->database->isManager()) {
            let query .= " AND leads.user_id=:user_id";
            let data["user_id"] = this->getUserId();
        }

        return this->tables->build(
            this->list,
            this->decryptData(this->database->all(query, data)),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderMessages(string lead_id)
    {
        var message, data, html, dates, messages;

        let dates = new Dates();
        let messages = new Messages();

        let data = this->database->all(
            "SELECT 
                contacts.*,
                messages.* 
            FROM messages 
            JOIN contacts ON contacts.id = messages.contact_id 
            WHERE messages.lead_id=:lead_id AND messages.deleted_at IS NULL",
            [
                "lead_id": lead_id
            ]
        );

        let html = "
        <div id='messages-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title'>Messages</div>
                    <div class='dd-box-body'>
                        <div class='dd-row'>";
        if (count(data)) {
            for message in data {
                let message = this->database->decrypt(messages->decrypt, message);
                let html .= "
                            <div class='dd-col-12 dd-note'>
                                <div class='dd-row'>
                                    <div class='dd-message-header dd-pb-3'>
                                        <div class='dd-float-left'>
                                            <p>" . message->subject . "</p>
                                        </div>
                                        <div class='dd-float-right'>" .
                                        this->buttons->delete(
                                            message->id,
                                            "delete_message",
                                            "delete_message",
                                            "Delete the message"
                                        ) . 
                                    "   </div>
                                    </div>
                                    <div class='dd-message-body'>
                                        <div class='dd-input-group'>
                                            <label>From</label>
                                            <span class='dd-form-control'>" .
                                                message->full_name .
                                                (message->company ? " @" . message->company : "") . 
                                                "&nbsp;&lt;<a href='mailto:" . message->email . "'>" . message->email . "</a>" .
                                                (message->phone ? " | <a href='tel:" . message->phone . "'>". message->phone . "</a>" : "") . 
                                                "&gt;" . 
                                            "</span>
                                        </div>
                                        <div class='dd-input-group'>
                                            <label>Message</label>
                                            <span class='dd-form-control'>" .
                                                message->message .
                                            "</span>
                                        </div>
                                    </div>
                                </div>
                            </div>";
            }
        } else {
            let html .= "<div class='dd-col-12 dd-note'><strong>No messages</strong></div>";
        }
                        
        let html .= "   </div>
                    </div>
                </div>
            </div>
        </div>";

        return html;
    }

    public function renderSidebar(model, mode = "add")
    {
        var html = "";

        let html = "
        <ul class='dd-col dd-nav-tabs' role='tablist'>
            <li class='dd-nav-item' role='presentation'>
                <div id='dd-tabs-toolbar'>
                    <div id='dd-tabs-toolbar-buttons' class='dd-flex'>". 
                        this->buttons->generic(
                            this->global_url,
                            "",
                            "back",
                            "Go back to the list"
                        ) .                  
                        this->buttons->generic(
                            this->global_url . "/add",
                            "",
                            "add",
                            "Add a new lead"
                        );
        if (mode == "edit") {
            if (model->website) {
                let html .= this->buttons->view(
                    model->website,
                    "View their website"
                );
            }
            if (model->deleted_at) {
                let html .= this->buttons->recover(model->id);
            } else {
                let html .= this->buttons->delete(model->id);
            }
        }
        let html .= this->buttons->save() . "</div>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#content-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='content-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("content-tab") .
                        "Lead
                    </span>
                </div>
            </li>";

        if (mode == "edit") {
            let html .= "
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#messages-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='messages-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("messages-tab") .
                        "Messages
                    </span>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#notes-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='notes-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("notes-tab") .
                        "Notes
                    </span>
                </div>
            </li>";

            if (empty(model->appointment_id)) {
                let html .= "<li class='dd-nav-item' role='presentation'>
                    <div class='dd-nav-link dd-flex'>
                        <span class='dd-tab-link dd-col'>" .
                            this->buttons->generic(
                                this->cfg->dumb_dog_url . "/appointments/add?lead_id=" . model->id,
                                "",
                                "appointments",
                                "Create an appointment"
                            ) .
                            "Add appointment
                        </span>
                    </div>
                </li>";
            }
        }

        let html .= "</ul>";
        return html;
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->add(this->global_url . "/add") .
        "</div>";
    }

    public function saveContact(array data, user_id = null, model = null)
    {
        return this->save(this->setData(data, user_id, model));
    }

    public function setData(array data, user_id = null, model = null)
    {
        let data["first_name"] = _POST["first_name"];

        let data["title"] = isset(_POST["title"]) ?
            _POST["title"] :
            (model ? model->title : "");

        if (!in_array(data["title"], array_keys(this->person_titles))) {
            throw new ValidationException(
                "Invalid title",
                400,
                array_values(this->person_titles)
            );
        }

        if (data["title"] == "Unknown") {
            let data["title"] = "";
        }

        let data["last_name"] = isset(_POST["last_name"]) ?
            _POST["last_name"] :
            (model ? model->last_name : null);

        let data["email"] = isset(_POST["email"]) ?
            _POST["email"] :
            (model ? model->email : null);

        let data["phone"] = isset(_POST["phone"]) ?
            _POST["phone"] :
            (model ? model->phone : null);

        let data["website"] = isset(_POST["website"]) ?
            _POST["website"] :
            (model ? model->website : null);

        let data["position"] = isset(_POST["position"]) ?
            _POST["position"] :
            (model ? model->position : null);

        let data["tags"] = isset(_POST["tags"]) ?
            (this->inputs->isTagify(_POST["tags"]) ? _POST["tags"] : this->createTags(_POST["tags"])) : 
            (model ? model->tags : null);

        let data["status"] = isset(_POST["status"]) ?
            "live" :
            (model ? model->status : "offline");

        let data["updated_by"] = user_id ? user_id : this->database->getUserId();

        return data;
    }

    public function setLeadData(array data, user_id = null, model = null)
    {    
        let data["ranking"] = isset(_POST["ranking"]) ?
            _POST["ranking"] :
            (model ? model->ranking : "ok");

        if (!in_array(data["ranking"], this->rankings)) {
            throw new ValidationException(
                "Invalid ranking",
                400,
                this->rankings
            );
        }

        let data["user_id"] = isset(_POST["user_id"]) ?
            _POST["user_id"] :
            (model ? model->user_id : null);

        let data["updated_by"] = user_id ? user_id : this->database->getUserId();

        return data;
    }

    public function updateContact(array data, user_id = null, model = null)
    {
        return this->update(this->setData(data, user_id, model));
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
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->nickname;
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Owner",
            "user_id",
            "Who owns this lead?",
            select,
            false,
            selected
        );
    }
}