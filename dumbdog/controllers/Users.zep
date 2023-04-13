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
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Users extends Controller
{
    private cfg;

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function add(string path)
    {
        var titles, html;
        let titles = new Titles();
        let html = titles->page("Add a user", "/assets/add-page.png");

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

                        let status = database->execute(
                            "INSERT INTO users 
                                (
                                    id,
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

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the user</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>username<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='what is their username?' value=''>
                </div>
                <div class='input-group'>
                    <span>nickname</span>
                    <input type='text' name='nickname' placeholder='what shall I call them?' value=''>
                </div>
                <div class='input-group'>
                    <span>password<span class='required'>*</span></span>
                    <input type='password' name='password' placeholder='sssh, it's our secret!' value=''>
                </div>
                <div class='input-group'>
                    <span>password check<span class='required'>*</span></span>
                    <input type='password' name='password_check' placeholder='same again please!' value=''>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/users' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function edit(string path)
    {
        var titles, html, database, splits, id, page, data = [];
        let titles = new Titles();

        let splits = explode("/", path);
        let id = array_pop(splits);

        let database = new Database(this->cfg);
        let data["id"] = id;
        let page = database->get("SELECT * FROM users WHERE id=:id", data);

        if (empty(page)) {
            throw new NotFoundException("User not found");
        }

        let html = titles->page("Edit the user", "/assets/edit-page.png");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["username", "nickname"])) {
                    let html .= this->missingRequired();
                } else {
                    if (isset(_POST["password"]) && isset(_POST["password_check"])) {
                        if (_POST["password"] != _POST["password_check"]) {
                            throw new \Exception("passwords do not match!");
                        }
                    }

                    let data["name"] = _POST["name"];
                    let data["nickname"] = _POST["nickname"];
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE users SET 
                            name=:name,
                            nickname=:nickname,
                            updated_at=NOW(),
                            updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the user");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/users/edit/" . page->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the user");
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the user</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>username<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='what is their username?' value='" . page->name . "'>
                </div>
                <div class='input-group'>
                    <span>nickname</span>
                    <input type='text' name='nickname' placeholder='what shall I call them?' value='" . page->nickname . "'>
                </div>
                <div class='input-group'>
                    <span>password<span class='required'>*</span></span>
                    <input type='password' name='password' placeholder='sssh, it's our secret!' value=''>
                </div>
                <div class='input-group'>
                    <span>password check<span class='required'>*</span></span>
                    <input type='password' name='password_check' placeholder='same again please!' value=''>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/users' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Users", "/assets/templates.png");
        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/users/add' class='button' title='Add a user'>
                <img src='/assets/add-page.png'>
            </a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM users"),
            "/dumb-dog/users/edit/"
        );

        return html;
    }
}