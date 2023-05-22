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
    public required = ["name", "url", "template_id"];

    public function add(string path, string type = "page")
    {
        var titles, html, data, database;
        let titles = new Titles();
        let database = new Database(this->cfg);

        let html = titles->page("Create the " . type, "add");

        let html .= "<div class='page-toolbar'><a href='" . this->global_url . "' class='round icon icon-back' title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
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
                    let data["event_length"] = isset(_POST["event_length"]) ? _POST["event_length"] : null;
                    let data["tags"] = _POST["tags"];
                    let data["parent_id"] = _POST["parent_id"];
                    let data["price"] = 0.00;
                    let data["stock"] = 0;
                    let data["code"] = null;

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
                    if (isset(_POST["stock"])) {
                        let data["stock"] = intval(_POST["stock"]);
                    }
                    if (isset(_POST["code"])) {
                        let data["code"] = _POST["code"];
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
                            stock,
                            code,
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
                            :stock,
                            :code,
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
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've saved the file");
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-title'>
                <span>the " . type . "</span>
            </div>
            <div class='box-body'>";

        let html .= this->createInputSwitch("live", "status") . 
            this->createInputText("url", "url", "how will I be reached", true) .
            this->createInputText("title", "name", "give me a name", true) .
            this->templatesSelect(database) . 
            this->createInputWysiwyg("content", "content", "the content") .        
            this->addHtml();

        /* Parent page */
        let html .= this->parentSelect(type, database, null);

        let html .= this->createInputText("tags", "tags", "tag the content", false, null, "tags") .
            this->createInputSelect(
                "menu item",
                "menu_item",
                [
                    "none": "none",
                    "header": "header",
                    "footer": "footer",
                    "both": "both"
                ],
                false
            ) . 
            this->createInputText("meta keywords", "meta_keywords", "add some keywords if you like") .
            this->createInputText("meta author", "meta_author", "add an author") .
            this->createInputTextarea("meta description", "meta_description", "add a description");

        let html .= "
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

                if (!this->validate(_POST, this->required)) {
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
                    let data["stock"] = 0;
                    let data["code"] = null;

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
                    if (isset(_POST["stock"])) {
                        let data["stock"] = intval(_POST["stock"]);
                    }
                    if (isset(_POST["code"])) {
                        let data["code"] = _POST["code"];
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
                            price=:price,
                            stock=:stock,
                            code=:code 
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

        let html .= "<form method='post'>
        <div class='box wfull" . (model->deleted_at ? " deleted" : "") . "'>
            <div class='box-title'><span>the " . type . "</span></div>
            <div class='box-body'>";

        let html .= this->createInputSwitch("live", "status", false, model->status) . 
            this->createInputText("url", "url", "how will I be reached", true, model->url) .
            this->createInputText("title", "name", "give me a name", true, model->name) .
            this->templatesSelect(database, model->template_id) . 
            this->createInputWysiwyg("content", "content", "the content", false, model->content) . 
            this->editHtml(model);

        /* Parent page */
        let html .= this->parentSelect(type, database, model->parent_id, model->id);

        let html .= this->createInputText("tags", "tags", "tag the content", false, model->tags, "tags") .
            this->createInputSelect("menu item", "menu_item", ["none", "header", "footer", "both"], false, model->menu_item) . 
            this->createInputText("meta keywords", "meta_keywords", "add some keywords if you like", false, model->meta_keywords) .
            this->createInputText("meta author", "meta_author", "add an author", false, model->meta_author) .
            this->createInputTextarea("meta description", "meta_description", "add a description", false, model->meta_description);

        let html .= "
            </div>
            <div class='box-footer'>
                <a href='" . this->global_url . "' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";
        
        let html .= this->stats(database, model);

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
        let query = "SELECT * FROM pages WHERE type='page'";
        if (isset(_GET["tag"])) {
            let query .= " AND tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY name";
        let html = html . tiles->build(
            database->all(query, data),
            "/dumb-dog/" . path . "/edit/"
        );

        return html . "</div>";
    }

    private function parentSelect(type, database, model = null, exclude = null)
    {
        var select = ["": "no parent"], selected = null, data;
        let data = database->all(
            "SELECT * FROM pages WHERE type ='" . type . "'" . (exclude ? " AND id != '" . exclude . "'" : "") . " ORDER BY name"
        );
        var iLoop = 0;

        if (model) {
            let selected = model;
        } elseif (isset(_POST["parent_id"])) {
            let selected = _POST["parent_id"];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            let iLoop = iLoop + 1;
        }

        return this->createInputSelect("parent", "parent_id", select, false, selected);
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "pages");
    }

    private function stats(database, model)
    {
        var query, html = "", iLoop, data, year, month, colours = [
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

    private function templatesSelect(database, model = null)
    {
        var select = [], selected = null, data;
        let data = database->all("SELECT * FROM templates WHERE deleted_at IS NULL ORDER BY `default` DESC, name");
        var iLoop = 0;

        if (model) {
            let selected = model;
        } elseif (isset(_POST["template_id"])) {
            let selected = _POST["template_id"];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            if (data[iLoop]->{"default"} && empty(selected)) {
                let selected = data[iLoop]->id;
            }
            let iLoop = iLoop + 1;
        }

        return this->createInputSelect("template", "template_id", select, true, selected);
    }
}