/**
 * Dumb Dog templates builder
 *
 * @package     DumbDog\Controllers\Templates
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

class Templates extends Controller
{
    public function add(string path)
    {
        var titles, html;
        let titles = new Titles();
        let html = titles->page("Add a template", "add");
        let html .= "<div class='page-toolbar'><a href='/dumb-dog/templates' class='round icon icon-back' title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "INSERT INTO templates 
                                (id, name, file, `default`, created_at, created_by, updated_at, updated_by) 
                            VALUES 
                                (UUID(), :name, :file, :default, NOW(), :created_by, NOW(), :updated_by)",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the template");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the template");
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box dd-wfull'>
            <div class='box-title'>
                <span>the template</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='give me a name' value=''>
                </div>
                <div class='input-group'>
                    <span>file<span class='required'>*</span></span>
                    <input type='text' name='file' placeholder='where am I located and with what file?' value=''>
                </div>
                <div class='input-group'>
                    <span>default</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='default' value='1'>
                            <span>
                                <small class='switcher-on'></small>
                                <small class='switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/templates' class='dd-link button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function delete(string path)
    {
        return this->triggerDelete(path, "templates");
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Template not found");
        }

        let html = titles->page("Edit the template", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'><a href='/dumb-dog/templates' class='dd-link round icon icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/templates/recover/" . model->id . "' class='dd-link round icon icon-recover' title='Recover the template'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/templates/delete/" . model->id . "' class='dd-link round icon icon-delete' title='Delete the template'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        if (data["default"]) {
                            let status = database->execute(
                                "UPDATE templates SET `default`=0, updated_at=NOW(), updated_by=:updated_by",
                                data
                            );
                        }
                        let status = database->execute(
                            "UPDATE templates SET 
                                name=:name, file=:file, `default`=:default, updated_at=NOW(), updated_by=:updated_by
                            WHERE id=:id",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the template");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/templates/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the template");
        }

        let html .= "<form method='post'><div class='box dd-wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the template</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . model->name . "'>
                </div>
                <div class='input-group'>
                    <span>file<span class='required'>*</span></span>
                    <input type='text' name='file' placeholder='where am I located and with what file?' value='" . model->file . "'>
                </div>
                <div class='input-group'>
                    <span>default</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='default' value='1'";

                if (model->{"default"} == 1) {
                    let html .= " checked='checked'";
                }
                
                let html .= ">
                            <span>
                                <small class='switcher-on'></small>
                                <small class='switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/templates' class='dd-link button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Templates", "templates");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the template");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages' class='dd-link round icon icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/templates/add' class='dd-link round icon' title='Add a template'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM templates"),
            "/dumb-dog/templates/edit/"
        );

        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "templates");
    }
}