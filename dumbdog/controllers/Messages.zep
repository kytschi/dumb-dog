/**
 * Dumb Dog messages
 *
 * @package     DumbDog\Controllers\Messages
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Contacts;
use DumbDog\Controllers\Content;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Security;

class Messages extends Content
{
    public decrypt = [
        "subject",
        "message",
        "first_name",
        "last_name",
        "email",
        "phone",
        "website",
        "position"
    ];
    public encrypt = ["subject", "message"];
    public global_url = "/messages";
    public list = [
        "created_at|date",
        "subject|decrypt",
        "full_name",
        "status"
    ];
    public required = ["first_name", "email", "message"];
    public title = "Messages";
    public type = "message";

    public routes = [
        "/messages/convert-to-group-lead": [
            "Messages",
            "convertToGroupsLead",
            "group lead"
        ],
        "/messages/convert-to-my-lead": [
            "Messages",
            "convertToMyLead",
            "my lead"
        ],
        "/messages/edit": [
            "Messages",
            "edit",
            "view the message"
        ],
        "/messages/read": [
            "Messages",
            "read",
            "mark the message as read"
        ],
        "/messages": [
            "Messages",
            "index",
            "messages"
        ]
    ];

    public function convertToGroupsLead(string path)
    {
        this->convertToLead(path);
    }

    public function convertToMyLead(string path)
    {
        this->convertToLead(path, this->database->getUserId());
    }

    private function convertToLead(string path, string user_id = null)
    {
        var id, model, status = false;
        let id = this->getPageId(path);

        let model = this->database->get(
            "SELECT
                contacts.*,
                messages.*  
            FROM messages 
            JOIN contacts ON contacts.id = messages.contact_id 
            WHERE messages.id=:id",
            [
                "id": id
            ]
        );

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let id = this->database->uuid();

        let status = this->database->execute("
            INSERT INTO leads
                (id, contact_id, user_id, created_by, created_at, updated_by, updated_at)
            VALUES
                (:id, :contact_id, :user_id, :created_by, NOW(), :updated_by, NOW())
            ",
            [
                "id": id,
                "contact_id": model->contact_id,
                "user_id": user_id,
                "created_by": this->database->getUserId(),
                "updated_by": this->database->getUserId()
            ]
        );

        if (!is_bool(status)) {
            throw new SaveException("Failed to convert the message to a lead", status);
        }

        let status = this->database->execute(
            "UPDATE messages SET lead_id=:lead_id WHERE id=:id",
            [
                "lead_id": id,
                "id": model->id
            ]
        );

        if (!is_bool(status)) {
            throw new SaveException("Failed to update the message with the lead", status);
        }

        this->redirect(this->global_url . "/edit/" . model->id);
    }

    public function edit(string path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get(
            "SELECT
                contacts.*,
                messages.* 
            FROM messages 
            JOIN contacts ON contacts.id = messages.contact_id 
            WHERE messages.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let model = this->database->decrypt(this->decrypt, model);
        let model->full_name = model->first_name;
        if (!empty(model->last_name)) {
            let model->full_name = model->full_name . " " . model->last_name;
        }

        let html = this->titles->page("Viewing the message", "messages");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("messages", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("messages", path);
                }
            }
        }

        let html .= "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs dd-mt-4'>
                <div class='dd-tabs-content dd-col'>
                    <div id='user-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>
                                    <div class='dd-input-group'>
                                        <label>From</label>
                                        <span class='dd-form-control'>" .
                                            model->full_name .
                                            (model->company ? " @" . model->company : "") . 
                                            "&nbsp;&lt;<a href='mailto:" . model->email . "'>" . model->email . "</a>" .
                                            (model->phone ? " | <a href='tel:" . model->phone . "'>". model->phone . "</a>" : "") . 
                                            "&gt;" . 
                                        "</span>
                                    </div>
                                    <div class='dd-input-group'>
                                        <label>Message</label>
                                        <span class='dd-form-control'>" .
                                            model->message .
                                        "</span>
                                    </div>                               
                                </div>
                            </div>
                        </div>
                    </div>
                </div>" . 
                this->renderSidebar(model, "edit") .   
            "</div>
        </form>";

        return html;
    }

    public function read(string path)
    {
        var html, data = [], model;

        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM messages WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let html = this->titles->page("Mark the message as read", "messages");

        if (!empty(_POST)) {
            if (isset(_POST["read"])) {
                var status = false, err;
                try {
                    let data["updated_by"] = this->database->getUserId();
                    let status = this->database->execute(
                        "UPDATE
                            messages
                        SET 
                            status='read',
                            updated_at=NOW(),
                            updated_by=:updated_by 
                        WHERE id=:id",
                        data
                    );
                    
                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to mark as read");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "/view/" . model->id);
                    }
                } catch \Exception, err {
                    let html .= this->saveFailed(err->getMessage());
                }
            }
        }

        let html .= "
        <form method='post'>
            <div class='dd-error dd-box dd-wfull'>
                <div class='dd-box-title'>
                    <span>are your sure?</span>
                </div>
                <div class='dd-box-body'>
                    <p>I've read it already!</p>
                </div>
                <div class='dd-box-footer'>
                    <a 
                        href='" . this->global_url . "/view/" . model->id . "'
                        class='dd-button-blank'>cancel</a>
                    <button type='submit' name='read' class='dd-button'>read</button>
                </div>
            </div>
        </form>";

        return html;
    }

    public function renderList(string path)
    {
        var data = [], query;

        let query = "
            SELECT
                contacts.*,
                messages.*
            FROM messages
            JOIN contacts ON contacts.id = messages.contact_id 
            WHERE messages.id IS NOT NULL";
        if (isset(_POST["q"])) {
            let query .= " AND messages.subject LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND messages.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY messages.created_at DESC";

        let data = this->database->all(query, data);
        for query in data {
            if (isset(query->first_name) && isset(query->last_name)) {
                let query->full_name = this->database->decrypt(query->first_name) . " " . this->database->decrypt(query->last_name);
            } elseif (isset(query["first_name"])) {
                let query->full_name = this->database->decrypt(query->first_name);
            }
        }

        return this->tables->build(
            this->list,
            data,
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderSidebar(model, mode = "add")
    {
        var html = "";
        let html = "
        <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
            <li class='dd-nav-item' role='presentation'>
                <div id='dd-tabs-toolbar'>
                    <div id='dd-tabs-toolbar-buttons' class='dd-flex'>". 
                        this->buttons->generic(
                            this->global_url,
                            "",
                            "back",
                            "Go back to the list"
                        );
        if (mode == "edit") {
            if (model->deleted_at) {
                let html .= this->buttons->recover(model->id);
            } else {
                let html .= this->buttons->delete(model->id);
            }
        }
        let html .= "</div>
                </div>
            </li>";

        if (this->cfg->apps->crm) {
            if (model->lead_id) {
                let html .= "
                    <li class='dd-dd-nav-item' role='presentation'>
                        <a
                            class='dd-button'
                            href='" . this->cfg->dumb_dog_url . "/leads/edit/" . model->lead_id . "'>".
                            this->icons->leads() .
                            "<span>Lead</span>
                        </a>
                    </li>";
            } else {
                let html .= "
                        <li class='dd-nav-item' role='presentation'>
                            <button
                                type='button'
                                class='dd-button'
                                data-inline-popup='#convert-to-lead'
                                titile='Convert to a lead'>" . 
                                this->icons->leads() .
                            "   <span>Convert to lead</span>
                            </button>
                            <div 
                                id='convert-to-lead' 
                                class='dd-inline-popup'>
                                <div class='dd-inline-popup-body dd-flex'>
                                    <span class='dd-col'>Lead type</span>
                                    <div class='dd-col-auto'>
                                        <a 
                                            href='" . this->cfg->dumb_dog_url . "/messages/convert-to-my-lead/" . model->id . "'
                                            class='dd-button'
                                            title='Convert to my lead'>" .
                                            this->icons->contactMine() .
                                        "</a>
                                        <a 
                                            href='" . this->cfg->dumb_dog_url . "/messages/convert-to-group-lead/" . model->id . "'
                                            class='dd-button'
                                            title='Convert and give to the group'>" .
                                            this->icons->groups() .
                                        "</a>
                                        <button 
                                            type='button'
                                            class='dd-button'
                                            data-inline-popup-close='#convert-to-lead'>" . 
                                            this->icons->cancel() .
                                        "</button>
                                    </div>
                                </div>
                            </div> 
                        </li>";
            }
        }           

        let html .= "
        </ul>";
        return html;
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a message"
            ) .
        "</div>";
    }

    public function save(array data)
    {
        var status, err, save = [];

        if (!isset(data["subject"])) {
            let save["subject"] = "Web form contact";
        } elseif (empty(data["subject"])) {
            let save["subject"] = "Web form contact";
        }

        if (isset(data["full_name"])) {
            let status = [];
            let err = explode(" ", data["full_name"]);
            let data["first_name"] = err[0];
            let data["last_name"] = count(err) > 1 ? err[1] : null;
            unset(data["full_name"]);
        }

        if (!this->validate(data, this->required)) {
            throw new ValidationException("Missing required data");
        }

        try {
            let save["contact_id"] = (new Contacts())->save(data);
            let save["subject"] = data["subject"];
            let save["message"] = data["message"];
            let save["type"] = data["type"];
            let save["created_by"] = this->database->getUserId();
            let save["updated_by"] = this->database->getUserId();

            let save = this->database->encrypt(this->encrypt, save);

            let status = this->database->execute(
                "INSERT INTO messages 
                    (id,
                    contact_id,
                    subject,
                    message,
                    type,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by) 
                VALUES 
                    (UUID(),
                    :contact_id,
                    :subject,
                    :message,
                    :type,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by)",
                    save
            );

            if (!is_bool(status)) {
                throw new SaveException("Failed to save the message", status);
            }

            return true;
        } catch \Exception, err {
            throw err;
        }
    }
}