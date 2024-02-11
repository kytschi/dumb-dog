/**
 * Dumb Dog messages builder
 *
 * @package     DumbDog\Controllers\Messages
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class Messages extends Controller
{
    public function delete(string path)
    {
        return this->triggerDelete(path, "messages");
    }

    public function view(string path)
    {
        var titles, html, database, model, data = [], security;
        let security = new Security(this->cfg);
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM messages WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let html = titles->page("Viewing the message", "message-view");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'><a href='/dumb-dog/messages' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->status != "read") {
            let html .= "<a href='/dumb-dog/messages/read/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-message-read' title='Mark as read'>&nbsp;</a>";
        }
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/messages/recover/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-recover' title='Recover the message'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/messages/delete/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-delete' title='Delete the message'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            /*if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["message"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["message"] = _POST["message"];
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "UPDATE messages SET 
                                name=:name, 
                                page_id=:page_id,
                                user_id=:user_id,
                                content=:content, 
                                updated_at=NOW(), 
                                updated_by=:updated_by
                            WHERE id=:id",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the comment");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/comments/edit/" . model->id . "?saved=true");
                    }
                }
            }*/
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the message");
        }

        let html .= "<div class='dd-box dd-wfull";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <div class='dd-box-title'>
                <span>the message</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>from</span>
                    <input value='" . security->decrypt(model->from_name) . "' readonly='readonly'>
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
        </div>";

        return html;
    }

    public function index(string path)
    {
        var titles, database, html, table;
        let titles = new Titles();
        
        let html = titles->page("Messages", "messages");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the message");
        }

        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/dashboard' class='dd-link dd-round dd-icon dd-icon-up' title='Back to the dashboard'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let table = new Table(this->cfg);
        let html = html . table->build(
            [
                "created_at|date",
                "subject",
                "from_name|decrypt",
                "status"
            ],
            database->all("SELECT * FROM messages ORDER BY created_at DESC"),
            "/dumb-dog/messages/view/"
        );
        return html;
    }

    public function read(string path)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM messages WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Message not found");
        }

        let html = titles->page("Mark the message as read", "message-read");

        if (!empty(_POST)) {
            if (isset(_POST["read"])) {
                var status = false, err;
                try {
                    let data["updated_by"] = this->getUserId();
                    let status = database->execute("UPDATE messages SET status='read', updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);
                    
                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to mark as read");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/messages/view/" . model->id);
                    }
                } catch \Exception, err {
                    let html .= this->saveFailed(err->getMessage());
                }
            }
        }

        let html .= "<form method='post'><div class='dd-error dd-box dd-wfull'>
            <div class='dd-box-title'>
                <span>are your sure?</span>
            </div>
            <div class='dd-box-body'><p>I've read it already!</p>
            </div>
            <div class='dd-box-footer'>
                 href='/dumb-dog/messages/view/" . model->id . "' class='dd-button-blank'>cancel</a>
                <button type='submit' name='read' class='dd-button'>read</button>
            </div>
        </div></form>";

        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "messages");
    }
}