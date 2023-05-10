/**
 * Dumb Dog messages builder
 *
 * @package     DumbDog\Controllers\Messages
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
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
    public function __construct(object cfg)
    {
        let this->cfg = cfg;
    }

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

        let html = titles->page("Viewing the message", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'><a href='/dumb-dog/messages' class='button icon icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/messages/recover/" . model->id . "' class='button icon icon-recover' title='Recover the message'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/messages/delete/" . model->id . "' class='button icon icon-delete' title='Delete the message'>&nbsp;</a>";
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

        let html .= "<div class='box wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the message</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>from</span>
                    <input value='" . security->decrypt(model->from_name) . "' readonly='readonly'>
                </div>
                <div class='input-group'>
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

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/dashboard' class='button icon icon-up' title='Back to the dashboard'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let table = new Table(this->cfg);
        let html = html . table->build(
            [
                "subject",
                "from_name|decrypt",
                "status"
            ],
            database->all("SELECT * FROM messages"),
            "/dumb-dog/messages/view/"
        );
        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "messages");
    }
}