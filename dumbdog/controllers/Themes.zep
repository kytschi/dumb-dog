/**
 * Dumb Dog themes builder
 *
 * @package     DumbDog\Controllers\Themes
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

class Themes extends Controller
{
    private cfg;

    public function __construct(object cfg)
    {
        let this->cfg = cfg;    
    }

    public function add(string path)
    {
        var titles, html;
        let titles = new Titles();
        let html = titles->page("Add a theme", "/assets/add-page.png");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["name", "folder"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["folder"] = _POST["folder"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "INSERT INTO themes 
                            (id, name, folder, `default`, created_at, created_by, updated_at, updated_by, status) 
                        VALUES 
                            (UUID(), :name, :folder, :default, NOW(), :created_by, NOW(), :updated_by, 'active')",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the theme");
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the theme</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='give me a name' value=''>
                </div>
                <div class='input-group'>
                    <span>folder<span class='required'>*</span></span>
                    <input type='text' name='folder' placeholder='where am I located?' value=''>
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
                <a href='/dumb-dog/themes' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function delete(string path)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM themes WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Theme not found");
        }

        let html = titles->page("Delete the theme", "/assets/delete.png");

        if (!empty(_POST)) {
            if (isset(_POST["delete"])) {
                var status = false, err;
                try {                    
                    let data["updated_by"] = this->getUserId();
                    let status = database->execute("UPDATE themes SET deleted_at=NOW(), deleted_by=:updated_by, updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to delete the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/themes?deleted=true");
                    }
                } catch \Exception, err {
                    let html .= this->saveFailed(err->getMessage());
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>are your sure?</span>
            </div>
            <div class='box-body'>
                <p>I'll bury you <strong>" . model->name . "</strong> like I bury my bone...</p>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/themes/edit/" . model->id . "' class='button-blank'>cancel</a>
                <button type='submit' name='delete'>delete</button>
            </div>
        </div></form>";

        return html;
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM themes WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Theme not found");
        }

        let html = titles->page("Edit the theme", "/assets/edit-page.png");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted'>";
            let html .= "<a href='/dumb-dog/themes/recover/" . model->id . "' class='button' title='Recover the theme'>
                <img src='/assets/recover.png'>
            </a>";
        } else {
            let html .= "'><a href='/dumb-dog/themes/delete/" . model->id . "' class='button' title='Delete the theme'>
                <img src='/assets/delete.png'>
            </a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "folder"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["folder"] = _POST["folder"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE themes SET 
                            name=:name, folder=:folder, `default`=:default, updated_at=NOW(), updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/themes/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the theme");
        }

        let html .= "<form method='post'><div class='box wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the theme</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . model->name . "'>
                </div>
                <div class='input-group'>
                    <span>folder<span class='required'>*</span></span>
                    <input type='text' name='folder' placeholder='where am I located?' value='" . model->folder . "'>
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
                <a href='/dumb-dog/themes' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Themes", "/assets/templates.png");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the theme");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/themes/add' class='button' title='Add a theme'>
                <img src='/assets/add-page.png'>
            </a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM themes"),
            "/dumb-dog/themes/edit/"
        );

        return html;
    }

    public function recover(string path)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM themes WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Themes not found");
        }

        let html = titles->page("Recover the theme", "/assets/recover.png");

        if (!empty(_POST)) {
            if (isset(_POST["recover"])) {
                var status = false, err;
                try {
                    let data["updated_by"] = this->getUserId();
                    let status = database->execute("UPDATE themes SET deleted_at=NULL, deleted_by=NULL, updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to recover the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/themes/edit/" . model->id);
                    }
                } catch \Exception, err {
                    let html .= this->saveFailed(err->getMessage());
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>are your sure?</span>
            </div>
            <div class='box-body'>
                <p>Dig up <strong>" . model->name . "</strong>...</p>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/themes/edit/" . model->id . "' class='button-blank'>cancel</a>
                <button type='submit' name='recover'>recover</button>
            </div>
        </div></form>";

        return html;
    }
}