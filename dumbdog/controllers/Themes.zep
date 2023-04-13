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

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function add()
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

    public function edit(string path)
    {
        var titles, html, database, splits, id, page, data = [];
        let titles = new Titles();

        let splits = explode("/", path);
        let id = array_pop(splits);

        let database = new Database(this->cfg);
        let data["id"] = id;
        let page = database->get("SELECT * FROM themes WHERE id=:id", data);

        if (empty(page)) {
            throw new NotFoundException("Theme page not found");
        }

        let html = titles->page("Edit the theme", "/assets/edit-page.png");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "file"])) {
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
                        this->redirect("/dumb-dog/themes/edit/" . page->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the theme");
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the theme</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . page->name . "'>
                </div>
                <div class='input-group'>
                    <span>folder<span class='required'>*</span></span>
                    <input type='text' name='folder' placeholder='where am I located?' value='" . page->folder . "'>
                </div>
                <div class='input-group'>
                    <span>default</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='default' value='1'";

                if (page->{"default"} == 1) {
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

    public function index()
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Themes", "/assets/templates.png");
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
}