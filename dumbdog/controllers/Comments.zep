/**
 * Dumb Dog comments builder
 *
 * @package     DumbDog\Controllers\Comments
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
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
    /*public function add(string path)
    {
        var titles, html, database;
        let titles = new Titles();

        let database = new Database();

        let html = titles->page("Add a comment", "add");
        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/comments' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["content"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["page_id"] = _POST["page_id"];
                    let data["user_id"] = _POST["user_id"];
                    let data["reviewed"] = isset(_POST["reviewed"]) ? 1 : 0;
                    let data["content"] = this->cleanContent(_POST["content"]);
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database();
                        let status = database->execute(
                            "INSERT INTO comments 
                                (
                                    id,
                                    name,
                                    page_id,
                                    user_id,
                                    reviewed,
                                    content,
                                    created_at,
                                    created_by,
                                    updated_at,
                                    updated_by
                                ) 
                            VALUES 
                                (
                                    UUID(),
                                    :name,
                                    :page_id,
                                    :user_id,
                                    :reviewed,
                                    :content,
                                    NOW(),
                                    :created_by,
                                    NOW(),
                                    :updated_by
                                )",
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

        let html .= "<form method='post'>
            <div class='dd-box dd-wfull'>
                <div class='dd-box-title'>
                    <span>the comment</span>
                </div>
                <div class='dd-box-body'>" .
                    this->createInputSwitch("can go live", "reviewed", false) .
                    this->createInputWysiwyg("content", "content", "the comment", true) .
                    this->createInputText("name", "name", "who said it?");
        let html .= this->createSelects(database);
        let html .= "</div><div class='dd-box-footer'>
                <a href='/dumb-dog/comments' class='dd-link dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div></div></form>";

        return html;
    }

    private function createSelects(database, model = null)
    {
        var data, html;

        let html = "<div class='dd-input-group'>
            <span>attach to page</span>
            <select name='page_id'><option value=''>not required</option>";

        let data = database->all("SELECT * FROM content ORDER BY name");
        var iLoop = 0, selected;

        if (model) {
            let selected = model->page_id;
        } elseif (isset(_POST["page_id"])) {
            let selected = _POST["page_id"];
        }

        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == selected) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }

        let html .= "
                    </select>
                </div>
                <div class='dd-input-group'>
                    <span>user said it</span>
                    <select name='user_id'><option value=''>not required</option>";

        let data = database->all("SELECT * FROM users ORDER BY name");
        let iLoop = 0;

        if (model) {
            let selected = model->user_id;
        } elseif (isset(_POST["user_id"])) {
            let selected = _POST["user_id"];
        }

        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == selected) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }

        let html .= "</select></div>";
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

        let database = new Database();
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM comments WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Comment not found");
        }

        let html = titles->page("Edit the comment", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <a href='/dumb-dog/comments' class='dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/comments/recover/" . model->id . "' class='dd-round dd-icon dd-icon-recover' title='Recover the comment'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/comments/delete/" . model->id . "' class='dd-round dd-icon dd-icon-delete' title='Delete the comment'>&nbsp;</a>";
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
                    let data["reviewed"] = isset(_POST["reviewed"]) ? 1 : 0;
                    let data["content"] = _POST["content"];
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database();
                        let status = database->execute(
                            "UPDATE comments SET 
                                name=:name, 
                                reviewed=:reviewed,
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

        let html .= "<form method='post'><div class='dd-box dd-wfull";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <div class='dd-box-title'>
                <span>the comment</span>
            </div>
            <div class='dd-box-body'>" .
                this->createInputSwitch("can go live", "reviewed", false, model->reviewed) .
                this->createInputWysiwyg("content", "content", "the comment", true, model->content) .
                this->createInputText("name", "name", "who said it?", false, model->name);
        let html .= this->createSelects(database, model);
        let html .= "</div>
            <div class='dd-box-footer'>
                <a href='/dumb-dog/comments' class='dd-link dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
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

        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/pages' class='dd-link dd-round dd-icon dd-icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/comments/add' class='dd-link dd-round dd-icon' title='Add a comment'>&nbsp;</a>
        </div>";

        let database = new Database();

        let html .= "<div id='dd-tiles'>";
        let data = database->all("SELECT * FROM comments");
        if (count(data)) {
            var iLoop, str;
            let iLoop = 0;
            while (iLoop < count(data)) {
                let html .= "
                <div class='dd-tile'>
                    <div class='dd-box dd-wfull";
                    if (data[iLoop]->deleted_at) {
                        let html .= " dd-deleted";
                    }
                    let str = strip_tags(data[iLoop]->content);
                    let html .= "'>
                        <div class='dd-box-body'><p>" . substr(str, 0, 120) . ((strlen(str) > 120) ? "..." : "") . "</p></div>
                        <div class='dd-box-footer'>
                            <a  href='/dumb-dog/comments/edit/" . data[iLoop]->id . "'
                                class='dd-link dd-round dd-icon dd-icon-edit'
                                title='edit me'>&nbsp;</a>
                        </div>
                    </div>
                </div>";
                let iLoop = iLoop + 1;
            }
        } else {
            let html .= titles->noResults();
        }
        return html . "</div>";
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "comments");
    }*/
}