/**
 * Dumb Dog page builder
 *
 * @package     DumbDog\Controllers\Pages
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
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Pages extends Controller
{
    private cfg;

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function add()
    {
        var titles, html, data, database;
        let titles = new Titles();
        let database = new Database(this->cfg);

        let html = titles->page("Create a page", "/assets/add-page.png");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["status"] = isset(_POST["status"]) ? "live" : "offline";
                    let data["name"] = _POST["name"];
                    let data["url"] = _POST["url"];
                    let data["content"] = _POST["content"];
                    let data["template_id"] = _POST["template_id"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_description"] = _POST["meta_description"];
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();

                    let status = database->execute(
                        "INSERT INTO pages 
                            (id,
                            status,
                            name,
                            url,
                            content,
                            template_id,
                            meta_keywords,
                            meta_author,
                            meta_description,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (UUID(),
                            :status,
                            :name,
                            :url,
                            :content,
                            :template_id,
                            :meta_keywords,
                            :meta_author,
                            :meta_description,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the page");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the page");
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
                    <span>live</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='status' value='1'>
                            <span>
                                <small class='switcher-on'></small>
                                <small class='switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='give me a name' value=''>
                </div>
                <div class='input-group'>
                    <span>url<span class='required'>*</span></span>
                    <input type='text' name='url' placeholder='how will I be reached' value=''>
                </div>
                <div class='input-group'>
                    <span>template</span>
                    <select name='template_id'>";
        let data = database->all("SELECT * FROM templates WHERE deleted_at IS NULL ORDER BY `default` DESC");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->{"default"}) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>meta keywords</span>
                    <input type='text' name='meta_keywords' placeholder='add some keywords if you like'>
                </div>
                <div class='input-group'>
                    <span>meta author</span>
                    <input type='text' name='meta_author' placeholder='add an author'>
                </div>
                <div class='input-group'>
                    <span>meta description</span>
                    <textarea rows='4' name='meta_description' placeholder='add a description'></textarea>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/pages' class='button-blank'>cancel</a>
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
        let page = database->get("SELECT * FROM pages WHERE id=:id", data);

        if (empty(page)) {
            throw new NotFoundException("Page not found");
        }

        let html = titles->page("Edit the page", "/assets/edit-page.png");
        let html .= "<div class='page-toolbar'>
            <a href='" . page->url . "' target='_blank' class='button' title='View me live'>
                <img src='/assets/web.png'>
            </a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "url", "template_id"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["status"] = isset(_POST["status"]) ? "live" : "offline";
                    let data["name"] = _POST["name"];
                    let data["url"] = _POST["url"];
                    let data["content"] = _POST["content"];
                    let data["template_id"] = _POST["template_id"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_description"] = _POST["meta_description"];
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE pages SET 
                            status=:status,
                            name=:name,
                            url=:url,
                            template_id=:template_id,
                            content=:content,
                            meta_keywords=:meta_keywords,
                            meta_author=:meta_author,
                            meta_description=:meta_description,
                            updated_at=NOW(),
                            updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the page");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/pages/edit/" . page->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the page");
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the page</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>live</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='status' value='1'";
                if (page->{"status"} == "live") {
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
                <div class='input-group'>
                    <span>url<span class='required'>*</span></span>
                    <input type='text' name='url' placeholder='the page url' value='" . page->url . "'>
                </div>
                <div class='input-group'>
                    <span>title<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='the page title' value='" . page->name . "'>
                </div>
                <div class='input-group'>
                    <span>content</span>
                    <textarea class='wysiwyg' name='content' rows='7' placeholder='the page content'>" . page->content . "</textarea>
                </div>
                <div class='input-group'>
                    <span>template</span>
                    <select name='template_id'>";
        let data = database->all("SELECT * FROM templates WHERE deleted_at IS NULL ORDER BY `default` DESC");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == page->template_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>meta keywords</span>
                    <input type='text' name='meta_keywords' placeholder='add some keywords if you like' value='" . page->meta_keywords . "'>
                </div>
                <div class='input-group'>
                    <span>meta author</span>
                    <input type='text' name='meta_author' placeholder='add an author' value='" . page->meta_author . "'>
                </div>
                <div class='input-group'>
                    <span>meta description</span>
                    <textarea rows='4' name='meta_description' placeholder='add a description'>" . page->meta_descrption . "</textarea>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/pages' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index()
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Pages", "/assets/pages.png");
        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages/add' class='button' title='Add a page'>
                <img src='/assets/add-page.png'>
            </a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM pages"),
            "/dumb-dog/pages/edit/"
        );

        return html;
    }
}