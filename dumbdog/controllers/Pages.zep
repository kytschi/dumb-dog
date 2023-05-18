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
    public global_url = "/dumb-dog/pages";

    public function add(string path, string type = "page")
    {
        var titles, html, data, database, iLoop;
        let titles = new Titles();
        let database = new Database(this->cfg);

        let html = titles->page("Create the " . type, "add");

        let html .= "<div class='page-toolbar'><a href='" . this->global_url . "' class='round icon icon-back' title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, ["name", "url", "template_id"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["status"] = isset(_POST["status"]) ? "live" : "offline";
                    let data["name"] = _POST["name"];
                    let data["url"] = str_replace(" ", "-", strtolower(rtrim(_POST["url"], "/")));
                    let data["content"] = this->cleanContent(_POST["content"]);
                    let data["menu_item"] = _POST["menu_item"];
                    let data["template_id"] = _POST["template_id"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_description"] = this->cleanContent(_POST["meta_description"]);
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();
                    let data["type"] = type;
                    let data["event_on"] = null;
                    let data["price"] = 0.00;
                    let data["event_length"] = isset(_POST["event_length"]) ? _POST["event_length"] : null;
                    let data["tags"] = _POST["tags"];
                    let data["parent_id"] = _POST["parent_id"];

                    if (isset(_POST["event_on"])) {
                        if (!isset(_POST["event_time"])) {
                            let _POST["event_time"] = "00:00";
                        } elseif (empty(_POST["event_time"])) {
                            let _POST["event_time"] = "00:00";
                        }
                        let data["event_on"] = this->dateToSql(_POST["event_on"] . " " . _POST["event_time"] . ":00");
                    }

                    if (isset(_POST["price"])) {
                        let data["price"] = floatval(_POST["price"]);
                    }

                    let status = database->execute(
                        "INSERT INTO pages 
                            (id,
                            status,
                            name,
                            url,
                            content,
                            menu_item,
                            template_id,
                            meta_keywords,
                            meta_author,
                            meta_description,
                            type,
                            event_on,
                            event_length,
                            tags,
                            parent_id,
                            price,
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
                            :menu_item,
                            :template_id,
                            :meta_keywords,
                            :meta_author,
                            :meta_description,
                            :type,
                            :event_on,
                            :event_length,
                            :tags,
                            :parent_id,
                            :price,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the " . type);
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the " . type);
                    }
                }
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the " . type . "</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>live</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='status' value='1' checked='checked'>
                            <span>
                                <small class='switcher-on'></small>
                                <small class='switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>
                <div class='input-group'>
                    <span>url<span class='required'>*</span></span>
                    <input type='text' name='url' placeholder='how will I be reached' value=''>
                </div>
                <div class='input-group'>
                    <span>title<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='give me a name' value=''>
                </div>
                <div class='input-group'>
                    <span>content</span>
                    <textarea class='wysiwyg' name='content' rows='7' placeholder='the content'></textarea>
                </div>";
        
        let html .= this->addHtml();
        let html .= "
                <div class='input-group'>
                    <span>template<span class='required'>*</span></span>
                    <select name='template_id' required='required'>";
        let data = database->all("SELECT * FROM templates WHERE deleted_at IS NULL ORDER BY `default` DESC");
        let iLoop = 0;
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
                    <span>parent</span>
                    <select name='parent_id'><option value=''>no parent</option>";
        let data = database->all("SELECT * FROM pages WHERE type !='event' ORDER BY name");
        let iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'>" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>menu item</span>
                    <select name='menu_item'>
                        <option value=''>none</option>
                        <option value='header'>header</option>
                        <option value='footer'>footer</option>
                        <option value='both'>both</option>
                    </select>
                </div>
                <div class='input-group'>
                    <span>tags</span>
                    <input type='text' name='tags' class='tags' placeholder='tag the page' value=''>
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
                <a href='" . this->global_url . "' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function addHtml()
    {
        return "";
    }

    public function delete(string path)
    {
        return this->triggerDelete(path, "pages");
    }

    public function edit(string path, string type = "page")
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM pages WHERE type='" . type . "' AND id=:id", data);

        if (empty(model)) {
            throw new NotFoundException(ucwords(type) . " not found");
        }

        let html = titles->page("Edit the " . type, "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'><a href='" . this->global_url ."' class='round icon icon-back' title='Back to list'>&nbsp;</a>";
        let html .= "<a href='" . model->url . "' target='_blank' class='round icon icon-web' title='View me live'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='" . this->global_url ."/recover/" . model->id . "' class='round icon icon-recover' title='Recover the page'>&nbsp;</a>";
        } else {
            let html .= "<a href='" . this->global_url ."/delete/" . model->id . "' class='round icon icon-delete' title='Delete the page'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "url", "template_id"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["status"] = isset(_POST["status"]) ? "live" : "offline";
                    let data["name"] = _POST["name"];
                    let data["url"] = str_replace(" ", "-", strtolower(rtrim(_POST["url"], "/")));
                    let data["content"] = this->cleanContent(_POST["content"]);
                    let data["menu_item"] = _POST["menu_item"];
                    let data["template_id"] = _POST["template_id"];
                    let data["meta_keywords"] = _POST["meta_keywords"];
                    let data["meta_author"] = _POST["meta_author"];
                    let data["meta_description"] = this->cleanContent(_POST["meta_description"]);
                    let data["updated_by"] = this->getUserId();
                    let data["event_on"] = null;
                    let data["event_length"] = isset(_POST["event_length"]) ? _POST["event_length"] : null;
                    let data["tags"] = _POST["tags"];
                    let data["parent_id"] = _POST["parent_id"];
                    let data["price"] = 0.00;

                    if (isset(_POST["event_on"])) {
                        if (!isset(_POST["event_time"])) {
                            let _POST["event_time"] = "00:00";
                        } elseif (empty(_POST["event_time"])) {
                            let _POST["event_time"] = "00:00";
                        }
                        let data["event_on"] = this->dateToSql(_POST["event_on"] . " " . _POST["event_time"] . ":00");
                    }

                    if (isset(_POST["price"])) {
                        let data["price"] = floatval(_POST["price"]);
                    }

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE pages SET 
                            status=:status,
                            name=:name,
                            url=:url,
                            template_id=:template_id,
                            content=:content,
                            menu_item=:menu_item,
                            meta_keywords=:meta_keywords,
                            meta_author=:meta_author,
                            meta_description=:meta_description,
                            updated_at=NOW(),
                            updated_by=:updated_by,
                            event_on=:event_on,
                            event_length=:event_length,
                            tags=:tags,
                            parent_id=:parent_id,
                            price=:price 
                        WHERE id=:id",
                        data
                    );
                
                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the " . type);
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the " . type);
        }

        let html .= "<form method='post'><div class='box wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the " . type . "</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>live</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='status' value='1'";
                if (model->{"status"} == "live") {
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
                    <input type='text' name='url' placeholder='the page url' value='" . model->url . "'>
                </div>
                <div class='input-group'>
                    <span>title<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='the page title' value='" . model->name . "'>
                </div>
                <div class='input-group'>
                    <span>content</span>
                    <textarea class='wysiwyg' name='content' rows='7' placeholder='the page content'>" . model->content . "</textarea>
                </div>";
        let html .= this->editHtml(model);
        let html .= "<div class='input-group'>
                    <span>template<span class='required'>*</span></span>
                    <select name='template_id' required='required'>";
        let data = database->all("SELECT * FROM templates WHERE deleted_at IS NULL ORDER BY `default` DESC, name");
        var iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == model->template_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>parent</span>
                    <select name='parent_id'><option value=''>no parent</option>";
        let data = database->all("SELECT * FROM pages WHERE type !='event' ORDER BY name");
        let iLoop = 0;
        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == model->parent_id) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }
        let html .= "
                    </select>
                </div>
                <div class='input-group'>
                    <span>tags</span>
                    <input type='text' name='tags' class='tags' placeholder='tag the page' value='" . model->tags . "'>
                </div>
                <div class='input-group'>
                    <span>menu item</span>
                    <select name='menu_item'>
                    <option value=''";
            if (model->menu_item == "") {
                let html .= " selected='selected'";
            }
            let html .= ">none</option>
                        <option value='header'";
            if (model->menu_item == "header") {
                let html .= " selected='selected'";
            }
            let html .= ">header</option><option value='footer'";
            if (model->menu_item == "footer") {
                let html .= " selected='selected'";
            }
            let html .= ">footer</option><option value='both'";
            if (model->menu_item == "both") {
                let html .= " selected='selected'";
            }
            let html .= ">both</option></select>
                </div>
                <div class='input-group'>
                    <span>meta keywords</span>
                    <input type='text' name='meta_keywords' placeholder='add some keywords if you like' value='" . model->meta_keywords . "'>
                </div>
                <div class='input-group'>
                    <span>meta author</span>
                    <input type='text' name='meta_author' placeholder='add an author' value='" . model->meta_author . "'>
                </div>
                <div class='input-group'>
                    <span>meta description</span>
                    <textarea rows='4' name='meta_description' placeholder='add a description'>" . model->meta_description . "</textarea>
                </div>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/pages' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";
        
        var query, year, month, colours = [
            "visitors": "#00c129",
            "unique": "#1D8CF8",
            "bot": "#E14ECA"
        ];

        let query = "SELECT ";
        let year = date("Y");
        let iLoop = 1;
        while (iLoop <= 12) {
            let month = iLoop;
            if (month < 10) {
                let month = "0" . month;
            }

            let query .= "(SELECT count(id) FROM stats WHERE page_id=:page_id AND created_at BETWEEN '" . year . "-" .
                    month . "-01' AND '" . year . "-" .
                    month . "-31') AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . month . "-01"))) . "_visitors,";

            let query .= "(SELECT count(*) FROM (SELECT count(id) FROM stats WHERE page_id=:page_id AND bot IS NULL AND 
                    created_at BETWEEN '" . year . "-" .
                    month . "-01' AND '" . year . "-" .
                    month . "-31' GROUP BY visitor) AS total) AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . month . "-01"))) . "_unique,";

            let query .= "(SELECT count(id) FROM stats WHERE page_id=:page_id AND bot IS NOT NULL AND 
                    created_at BETWEEN '" . year . "-" . month . "-01' AND '" . year . "-" .
                    month . "-31') AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . month . "-01"))) . "_bot,";
            let iLoop = iLoop + 1;
        }
        let data = database->all(rtrim(query, ','), ["page_id": model->id]);

        //I'm reusing vars here, keep an eye.
        let query = [];
        for month in data {
            for year, iLoop in get_object_vars(month) {
                let iLoop = explode("_", year);
                let iLoop = array_pop(iLoop);
                if (!isset(query[iLoop])) {
                    let query[iLoop] = [];
                }
                let query[iLoop][] = month->{year};
            }
        }
        let html .= "<div class='box'><div class='box-title'><span>annual stats</span></div><div class='box-body'>
        <canvas id='visitors' width='600' height='200'></canvas></div></div>
        <script type='text/javascript'>
        var ctx = document.getElementById('visitors').getContext('2d');
        var orders = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
                datasets: [";                    
        
        for month, year in query {
            let html .= "
            {
                label: '" . ucwords(month) . "',
                data: [". rtrim(implode(",", year), ",") . "],
                fill: false,
                backgroundColor: '" . colours[month] . "',
                borderColor: '" . colours[month] . "',
                tension: 0.1
            },";
        }

        let html .= "]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
        </script>";

        return html;
    }

    public function editHtml(model)
    {
        return "";
    }

    public function index(string path)
    {
        var titles, tiles, database, html, query, data;
        let titles = new Titles();
        let database = new Database(this->cfg);
        let tiles = new Tiles();
        
        let html = titles->page("Pages", "pages");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the page");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages/add' class='round icon' title='Add a page'>&nbsp;</a>
            <a href='/dumb-dog/events' class='round icon icon-events' title='Events'>&nbsp;</a>
            <a href='/dumb-dog/products' class='round icon icon-products' title='Products'>&nbsp;</a>
            <a href='/dumb-dog/comments' class='round icon icon-comments' title='Comments'>&nbsp;</a>
            <a href='/dumb-dog/files' class='round icon icon-files' title='Managing the files and media'>&nbsp;</a>
            <a href='/dumb-dog/templates' class='round icon icon-templates' title='Managing the templates'>&nbsp;</a>
        </div>";

        let html .= this->tags(path, "pages");

        let html .= "<div id='pages'>";

        let data = [];
        let query = "SELECT * FROM pages";
        if (isset(_GET["tag"])) {
            let query .= " WHERE tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY name";
        let html = html . tiles->build(
            database->all(query, data),
            "/dumb-dog/" . path . "/edit/"
        );

        return html . "</div>";
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "pages");
    }
}