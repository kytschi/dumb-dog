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

    public function __construct(object cfg)
    {
        let this->cfg = cfg;    
    }

    public function all()
    {
        var database;
        let database = new Database(this->cfg);

        return database->all("
        SELECT
            pages.name,
            pages.url,
            pages.content,
            pages.meta_keywords,
            pages.meta_description,
            pages.meta_author,
            templates.file AS template
        FROM pages 
        JOIN templates ON templates.id=pages.template_id 
        WHERE pages.status='live' AND pages.deleted_at IS NULL");
    }

    public function add(string path)
    {
        var titles, html, data, database;
        let titles = new Titles();
        let database = new Database(this->cfg);

        let html = titles->page("Create a page", "add");

        let html .= "<div class='page-toolbar'><a href='/dumb-dog/pages' class='button icon icon-back' title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, ["name", "url", "template_id"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["status"] = isset(_POST["status"]) ? "live" : "offline";
                    let data["name"] = _POST["name"];
                    let data["url"] = _POST["url"];
                    let data["content"] = str_replace("\\", "&#92;", _POST["content"]);
                    let data["menu_item"] = _POST["menu_item"];
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
                            menu_item,
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
                            :menu_item,
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
                    <textarea class='wysiwyg' name='content' rows='7' placeholder='the page content'></textarea>
                </div>
                <div class='input-group'>
                    <span>template<span class='required'>*</span></span>
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
                    <span>menu item</span>
                    <select name='menu_item'>
                        <option value=''>none</option>
                        <option value='header'>header</option>
                        <option value='footer'>footer</option>
                        <option value='both'>both</option>
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

    public function delete(string path)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM pages WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Page not found");
        }

        let html = titles->page("Delete the page", "delete");
        
        if (!empty(_POST)) {
            if (isset(_POST["delete"])) {
                var status = false, err;
                try {
                    let data["updated_by"] = this->getUserId();
                    let status = database->execute("UPDATE pages SET deleted_at=NOW(), deleted_by=:updated_by, updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);
                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to delete the page");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/pages?deleted=true");
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
                <a href='/dumb-dog/pages/edit/" . model->id . "' class='button-blank'>cancel</a>
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
        let model = database->get("SELECT * FROM pages WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Page not found");
        }

        let html = titles->page("Edit the page", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'><a href='/dumb-dog/pages' class='button icon icon-back' title='Back to list'>&nbsp;</a>";
        let html .= "<a href='" . model->url . "' target='_blank' class='button icon icon-web' title='View me live'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/pages/recover/" . model->id . "' class='button icon icon-recover' title='Recover the page'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/pages/delete/" . model->id . "' class='button icon icon-delete' title='Delete the page'>&nbsp;</a>";
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
                    let data["url"] = _POST["url"];
                    let data["content"] = str_replace("\\", "&#92;", _POST["content"]);
                    let data["menu_item"] = _POST["menu_item"];
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
                            menu_item=:menu_item,
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
                        this->redirect("/dumb-dog/pages/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the page");
        }

        let html .= "<form method='post'><div class='box wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the page</span>
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
                </div>
                <div class='input-group'>
                    <span>template<span class='required'>*</span></span>
                    <select name='template_id'>";
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
                    <textarea rows='4' name='meta_description' placeholder='add a description'>" . model->meta_descrption . "</textarea>
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

    public function index(string path)
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Pages", "pages");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the page");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages/add' class='button icon' title='Add a page'>&nbsp;</a>
            <a href='/dumb-dog/files' class='button icon icon-files' title='Managing the files and media'>&nbsp;</a>
            <a href='/dumb-dog/templates' class='button icon icon-templates' title='Managing the templates'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM pages ORDER BY name"),
            "/dumb-dog/pages/edit/"
        );

        return html;
    }

    public function recover(string path)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM pages WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Page not found");
        }

        let html = titles->page("Recover the page", "recover");

        if (!empty(_POST)) {
            if (isset(_POST["recover"])) {
                var status = false, err;
                try {
                    let data["updated_by"] = this->getUserId();
                    let status = database->execute("UPDATE pages SET deleted_at=NULL, deleted_by=NULL, updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to recover the page");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/pages/edit/" . model->id);
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
                <a href='/dumb-dog/pages/edit/" . model->id . "' class='button-blank'>cancel</a>
                <button type='submit' name='recover'>recover</button>
            </div>
        </div></form>";

        return html;
    }
}