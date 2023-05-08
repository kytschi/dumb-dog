/**
 * Dumb Dog comments builder
 *
 * @package     DumbDog\Controllers\Comments
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

class Comments extends Controller
{
    public function __construct(object cfg)
    {
        let this->cfg = cfg;
    }

    public function add(string path)
    {
        var titles, html, data, database;
        let titles = new Titles();

        let database = new Database(this->cfg);

        let html = titles->page("Add a comment", "add");
        let html .= "<div class='page-toolbar'><a href='/dumb-dog/comments' class='button icon icon-back' title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["content"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["page_id"] = _POST["page_id"];
                    let data["user_id"] = _POST["user_id"];
                    let data["content"] = this->cleanContent(_POST["content"]);
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "INSERT INTO comments 
                                (id, name, page_id, user_id, content, created_at, created_by, updated_at, updated_by) 
                            VALUES 
                                (UUID(), :name, :page_id, :user_id, :content, NOW(), :created_by, NOW(), :updated_by)",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the comment");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the comment");
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the comment</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>comment<span class='required'>*</span></span>
                    <textarea class='wysiwyg' name='content' rows='7' placeholder='the comment' required='required'></textarea>
                </div>
                <div class='input-group'>
                    <span>name</span>
                    <input type='text' name='name' placeholder='who said it?' value=''>
                </div>
                <div class='input-group'>
                    <span>attach to page</span>
                    <select name='page_id'><option value=''>not required</option>";
        let data = database->all("SELECT * FROM pages ORDER BY name");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'>" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>user said it</span>
                    <select name='user_id'><option value=''>not required</option>";
        let data = database->all("SELECT * FROM users ORDER BY name");
        let iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'>" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/comments' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function delete(string path)
    {
        return this->triggerDelete(path, "comments");
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM comments WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Comment not found");
        }

        let html = titles->page("Edit the comment", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'><a href='/dumb-dog/comments' class='button icon icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/comments/recover/" . model->id . "' class='button icon icon-recover' title='Recover the comment'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/comments/delete/" . model->id . "' class='button icon icon-delete' title='Delete the comment'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["content"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["page_id"] = _POST["page_id"];
                    let data["user_id"] = _POST["user_id"];
                    let data["content"] = _POST["content"];
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "UPDATE comments SET 
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
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the comment");
        }

        let html .= "<form method='post'><div class='box wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the comment</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>comment<span class='required'>*</span></span>
                    <textarea class='wysiwyg' name='content' rows='7' placeholder='the comment' required='required'>" . model->content . "</textarea>
                </div>
                <div class='input-group'>
                    <span>commentor's name</span>
                    <input type='text' name='name' placeholder='who said it?' value='" . model->name . "'>
                </div>
                <div class='input-group'>
                    <span>attach to page</span>
                    <select name='page_id'><option value=''>not required</option>";
        let data = database->all("SELECT * FROM pages ORDER BY name");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == model->page_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>user said it</span>
                    <select name='user_id'><option value=''>not required</option>";
        let data = database->all("SELECT * FROM users ORDER BY name");
        let iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == model->user_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/comments' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var titles, database, html, data;
        let titles = new Titles();
        
        let html = titles->page("Comments", "comments");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the comment");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages' class='button icon icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/comments/add' class='button icon' title='Add a comment'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let html = "<div id='tiles'>";

        let data = database->all("SELECT * FROM comments");
        if (count(data)) {
            var iLoop, str;
            let iLoop = 0;
            while (iLoop < count(data)) {
                let html .= "
                <div class='tile'>
                    <div class='box wfull";
                    if (data[iLoop]->deleted_at) {
                        let html .= " deleted";
                    }
                    let str = strip_tags(data[iLoop]->content);
                    let html .= "'>
                        <div class='box-body'><p>" . substr(str, 0, 120) . ((strlen(str) > 120) ? "..." : "") . "</p></div>
                        <div class='box-footer'>
                            <a href='/dumb-dog/comments/edit/" . data[iLoop]->id . "' class='round icon icon-edit' title='edit me'>&nbsp;</a>
                        </div>
                    </div>
                </div>";
                let iLoop = iLoop + 1;
            }
        } else {
            let html = html . titles->noResults();
        }
        return html . "</div>";
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "comments");
    }
}