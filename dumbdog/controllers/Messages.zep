/**
 * Dumb Dog messages builder
 *
 * @package     DumbDog\Controllers\Messages
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Table;

class Messages extends Content
{
    public global_url = "/messages";
    public list = [
        "created_at|date",
        "subject|decrypt",
        "from_name|decrypt",
        "status"
    ];
    public type = "message";

    public function delete(string path)
    {
        return this->triggerDelete(path, "messages");
    }

    public function edit(string path)
    {
        var html, model, data = [], security;
        let security = new Security(this->cfg);

        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM messages WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let html = this->titles->page("Viewing the message", "messages");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
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
                                            security->decrypt(model->from_name) .
                                            (security->decrypt(model->from_company) ? " @" . security->decrypt(model->from_company) : "") . 
                                            "&nbsp;&lt;<a href='mailto:" . security->decrypt(model->from_email) . "'>" . security->decrypt(model->from_email) . "</a>" .
                                            (security->decrypt(model->from_number) ? " | <a href='tel:" . security->decrypt(model->from_number) . "'>". security->decrypt(model->from_number) . "</a>" : "") . 
                                            "&gt;" . 
                                        "</span>
                                    </div>
                                    <div class='dd-input-group'>
                                        <label>Message</label>
                                        <span class='dd-form-control'>" .
                                            security->decrypt(model->message) .
                                        "</span>
                                    </div>                               
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
                    <li class='dd-dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#user-tab'
                            aria-controls='user-tab' 
                            aria-selected='true'>Message</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'><hr/></li>";

        if (this->cfg->apps->crm) {
            let html .= "<li class='dd-nav-item' role='presentation'>". 
                        this->buttons->generic(
                            this->cfg->dumb_dog_url . "/messages/convert-to-lead/" . model->id,
                            "Convert to lead",
                            "leads",
                            "Convert to a lead") .   
                    "</li>";
        }           

        let html .= "
                </ul>
            </div>
        </form>";

        /*let html .= "'>
            <div class='dd-box-title'>
                <span>the message</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>from</span>
                    <input value='" .  . "' readonly='readonly'>
                </div>
                <div class='dd-input-group'>
                    <span>email</span>
                    <input value='" . security->decrypt(model->from_email) . "' readonly='readonly'>
                </div>
                <div class='dd-input-group'>
                    <span>number</span>
                    <input value='" . security->decrypt(model->from_number) . "' readonly='readonly'>
                </div>
                <div class='dd-input-group'>
                    <span>message</span>
                    <textarea readonly='readonly'>" . security->decrypt(model->message) . "</textarea>
                </div>
            </div>
        </div>";*/

        return html;
    }

    public function index(string path)
    {
        var html;        
        let html = this->titles->page("Messages", "messages");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the message");
        }

        let html .= this->renderToolbar();

        let html .= 
            this->searchBox() . 
            this->tags(path, "messages") .
            this->renderList(path);
        
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

    public function recover(string path)
    {
        return this->triggerRecover(path, "messages");
    }

    public function renderList(string path)
    {
        var data = [], query, table;

        let table = new Table(this->cfg);

        let query = "
            SELECT messages.* 
            FROM messages
            WHERE messages.id IS NOT NULL";
        if (isset(_POST["q"])) {
            let query .= " AND messages.subject LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND messages.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY messages.created_at";

        return table->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
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

    
}