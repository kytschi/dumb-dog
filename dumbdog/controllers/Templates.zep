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
    private cfg;

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function add()
    {
        var titles, html;
        let titles = new Titles();
        let html = titles->page("Create a template", "/assets/add-page.png");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = 0;
                    let data["created_at"] = date("Y-m-d H:i:s");
                    let data["created_by"] = this->getUserId();
                    let data["updated_at"] = date("Y-m-d H:i:s");
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "INSERT INTO templates 
                            (id, name, file, `default`, created_at, created_by, updated_at, updated_by) 
                        VALUES 
                            (UUID(), :name, :file, :default, :created_at, :created_by, :updated_at, :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the template");
                        let html .= "<script type='text/javascript'>console.log(JSON.parse(" . json_encode(status) . "));</script>";
                    } else {
                        let html .= this->saveSuccess("I've saved the template");
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
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
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/templates' class='button-blank'>cancel</a>
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
        let page = database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(page)) {
            throw new NotFoundException("Template page not found");
        }

        let html = titles->page("Edit the template", "/assets/edit-page.png");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = 0;
                    let data["updated_at"] = date("Y-m-d H:i:s");
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE templates SET 
                            name=:name, file=:file, `default`=:default, updated_at=:updated_at, updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the template");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've updated the template");
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the page</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . page->name . "'>
                </div>
                <div class='input-group'>
                    <span>file<span class='required'>*</span></span>
                    <input type='text' name='file' placeholder='where am I located and with what file?' value='" . page->file . "'>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/templates' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index()
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Templates", "/assets/templates.png");
        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/templates/add' class='button' title='Add a template'>
                <img src='/assets/add-page.png'>
            </a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM templates"),
            "/dumb-dog/templates/edit/"
        );

        return html;
    }
}