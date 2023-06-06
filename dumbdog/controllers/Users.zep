/**
 * Dumb Dog users builder
 *
 * @package     DumbDog\Controllers\Users
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
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class Users extends Controller
{
    public function add(string path)
    {
        var titles, html;
        let titles = new Titles();
        let html = titles->page("Add a user", "add");
        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/users' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false, err;

                if (!this->validate(_POST, ["name", "password", "password_check"])) {
                    let html .= this->missingRequired();
                } else {
                    try {
                        if (_POST["password"] != _POST["password_check"]) {
                            throw new \Exception("passwords do not match!");
                        }

                        let data["name"] = _POST["name"];
                        let database = new Database(this->cfg);

                        var user;                        
                        let user = database->get("SELECT * FROM users WHERE name=:name", data);
                        if (user) {
                            throw new \Exception("username already taken");
                        }
                        
                        let data["nickname"] = _POST["nickname"];
                        let data["password"] = password_hash(_POST["password"], PASSWORD_DEFAULT);
                        let data["created_by"] = this->getUserId();
                        let data["updated_by"] = this->getUserId();
                        let data["file"] = null;

                        if (!empty(_FILES["file"])) {
                            let data["file"] = this->createFilename();
                            this->saveFile(data["file"]);
                        }

                        let status = database->execute(
                            "INSERT INTO users 
                                (
                                    id,
                                    file,
                                    name,
                                    nickname,
                                    `password`,
                                    created_at,
                                    created_by,
                                    updated_at,
                                    updated_by,
                                    status
                                ) 
                            VALUES 
                                (
                                    UUID(),
                                    :file,
                                    :name,
                                    :nickname,
                                    :password,
                                    NOW(),
                                    :created_by,
                                    NOW(),
                                    :updated_by,
                                    'active'
                                )",
                            data
                        );

                        if (!is_bool(status)) {
                            let html .= this->saveFailed("Failed to save the user");
                            let html .= this->consoleLogError(status);
                        } else {
                            let html .= this->saveSuccess("I've saved the user");
                        }
                    } catch \Exception, err {
                        let html .= this->saveFailed(err->getMessage());
                    }
                }
            }
        }

        let html .= "<form method='post' enctype='multipart/form-data'>
        <div class='dd-box dd-wfull'>
            <div class='dd-box-title'>
                <span>the user</span>
            </div>
            <div class='dd-box-body'>" .
                this->createInputText("username", "name", "what is their username?", true) .
                this->createInputText("nickname", "nickname", "what shall I call them?", true) .
                this->createInputFile("picture", "file", "upload a picture?") .
                this->createInputPassword("password", "password", "sssh, it's our secret!") .
                this->createInputPassword("password check", "password_check", "same again please!") .
            "</div>
            <div class='dd-box-footer'>
                <a href='/dumb-dog/users' class='dd-link dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function delete(string path)
    {
        return this->triggerDelete(path, "users");
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT
            *,
            CONCAT('/website/files/thumb-', file) AS thumbnail 
        FROM users 
        WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("User not found");
        }

        let html = titles->page("Edit the user", "edit");
        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }
        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'><a href='/dumb-dog/users' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/users/recover/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-recover' title='Recover the user'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/users/delete/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-delete' title='Delete the user'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false, query;

                if (!this->validate(_POST, ["name", "nickname"])) {
                    let html .= this->missingRequired();
                } else {
                    let query = "
                        UPDATE
                            users
                        SET 
                            name=:name,
                            nickname=:nickname,
                            updated_at=NOW(),
                            updated_by=:updated_by,
                            file=:file
                    ";
                
                    if (isset(_POST["password"]) && isset(_POST["password_check"])) {
                        if (!empty(_POST["password"]) && !empty(_POST["password_check"])) {
                            if (_POST["password"] != _POST["password_check"]) {
                                throw new \Exception("passwords do not match!");
                            }
                            let data["password"] = password_hash(_POST["password"], PASSWORD_DEFAULT);
                            let query .= ", password=:password";
                        }
                    }

                    let data["name"] = _POST["name"];
                    let data["nickname"] = _POST["nickname"];
                    let data["updated_by"] = this->getUserId();
                    let data["file"] = null;

                    if (!empty(_FILES["file"])) {
                        let data["file"] = this->createFilename();
                        this->saveFile(data["file"]);
                    }

                    let query .= " WHERE id=:id";

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        query,
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the user");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/users/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the user");
        }

        let html .= "<form method='post' enctype='multipart/form-data'>
            <div class='dd-box dd-wfull";
            if (model->deleted_at) {
                let html .= " dd-deleted";
            }
            let html .= "'>
                <div class='dd-box-title'>
                    <span>the user</span>
                </div>
                <div class='dd-box-body'>" .
                    this->createInputText("username", "name", "what is their username?", true, model->name) .
                    this->createInputText("nickname", "nickname", "what shall I call them?", true, model->nickname) .
                    this->createInputFile("picture", "file", "upload a picture?");

            if (!empty(model->file)) {
                let html .= "<div class='dd-input-group dd-user'>
                    <div class='dd-thumb'>
                        <img src='" . model->thumbnail . "'>
                    </div>
                </div>";
            }
            
            let html .= this->createInputPassword("password", "password", "sssh, it's our secret!") .
                    this->createInputPassword("password check", "password_check", "same again please!") .
                "</div>
                <div class='dd-box-footer'>
                    <a href='/dumb-dog/users' class='dd-link dd-button-blank'>cancel</a>
                    <button type='submit' name='save' class='dd-button'>save</button>
                </div>
            </div>
        </form>";

        return html;
    }

    public function index(string path)
    {
        var titles, table, database, html;
        let titles = new Titles();
        
        let html = titles->page("Users", "users");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the user");
        }

        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/users/add' class='dd-link dd-round dd-icon' title='Add a user'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let table = new Table(this->cfg);
        let html = html . table->build(
            [
                "name",
                "status"
            ],
            database->all("SELECT * FROM users"),
            "/dumb-dog/users/edit/"
        );

        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "users");
    }
}