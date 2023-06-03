/**
 * Dumb Dog controller helper
 *
 * @package     DumbDog\Controllers\Controller
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

use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Ui\Gfx\Titles;

class Controller
{   
    protected cfg;
    protected system_uuid = "00000000-0000-0000-0000-000000000000";

    public function __construct(object cfg)
    {
        let this->cfg = cfg;
    }

    public function cleanContent(string content)
    {
        var checks = [
            "\\":"&#92;",
            "’": "&#39;"
        ],
        check, replace;

        for check, replace in checks {
            let content = str_replace(check, replace, content);
        }
        return content;
    }

    public function consoleLogError(string message)
    {
        return "<script type='text/javascript'>console.log('DUMB DOG ERROR:', '" . str_replace(["\n", "\r\n"], "", strip_tags(message)) . "');</script>";
    }

    public function createInputDate(string label, string var_name, string placeholder, bool required = false, value = null)
    {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : date("Y-m-d"));
        }

        if (strpos(value, "-") !== false) {
            let value = date("d/m/Y", strtotime(value));
        }

        return "<div class='input-group'>
            <span>" . label . (required ? "<span class='required'>*</span>" : "") . "</span>
            <input
                class='datepicker' 
                type='text'
                name='" . var_name . "' 
                placeholder='' 
                value='" . value . "'>
        </div>";
    }

    public function createInputSelect(string label, string var_name, array data, bool required = false, selected = "")
    {
        var html = "", item, key;

        if (empty(selected)) {
            let selected = isset(_POST[var_name]) ? _POST[var_name] : "";
        }

        let html .= "<div class='input-group'>
                <span>" . label . (required ? "<span class='required'>*</span>" : "") . "</span>
                <select name='" . var_name . "'>";

        for key, item in data {
            let html .= "<option value='" . key . "'" . ((selected == key) ? " selected='selected'" : "") . ">" . item . "</option>";
        }

        let html .= "</select></div>";
        return html;
    }

    public function createInputSwitch(string label, string var_name, bool required = false, selected = false)
    {
        return "<div class='input-group'>
                    <span>" . label . (required ? "<span class='required'>*</span>" : "") . "</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='" . var_name . "' value='1' " . (selected ? " checked='checked'" : "") . ">
                            <span>
                                <small class='switcher-on'></small>
                                <small class='switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>";
    }

    public function createInputText(string label, string var_name, string placeholder, bool required = false, value = null, style = "")
    {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : "");
        }

        return "<div class='input-group'>
            <span>" . label . (required ? "<span class='required'>*</span>" : "") . "</span>
            <input
                type='text'
                name='" . var_name . "' 
                placeholder='' " . (style ? " class='" . style . "'" : "") .
                "value=\"" . value . "\"'>
        </div>";
    }

    public function createInputTextarea(string label, string var_name, string placeholder, bool required = false, value = null)
    {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : "");
        }
        return "<div class='input-group'>
            <span>" . label . (required ? "<span class='required'>*</span>" : "") . "</span>
            <textarea
                name='" . var_name . "' rows='4' 
                placeholder='" . placeholder . "'" . (required ? " required='required'" : "") . 
            ">" . value . "</textarea>
        </div>";
    }

    public function createInputWysiwyg(string label, string var_name, string placeholder, bool required = false, value = null)
    {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : "");
        }
        return "<div class='input-group'>
            <span>" . label . (required ? "<span class='required'>*</span>" : "") . "</span>
            <textarea
                class='wysiwyg' name='" . var_name . "' rows='7' 
                placeholder='" . placeholder . "'" . (required ? " required='required'" : "") . 
            ">" . value . "</textarea>
        </div>";
    }

    public function dateToSql(string str)
    {
        var date;
        let date = \DateTime::createFromFormat("d/m/Y H:i:s", str);
        if (empty(date)) {
            throw new \Exception("Failed to process the date");
        }

        return date->format("Y-m-d H:i:s");
    }

    public function deletedState(string message)
    {
        return "<div class='deleted alert'><span>deleted</span></div>";
    }

    public function getPageId(string path)
    {
        var splits;

        let splits = explode("/", path);
        return array_pop(splits);
    }

    public function getUserId()
    {
        if (isset(_SESSION["dd"])) {
            return _SESSION["dd"];
        }
        return this->system_uuid;
    }

    public function missingRequired(string message = "Missing required fields")
    {
        return "<div class='error box wfull'>
        <div class='box-title'>
            <span>double check your inputs</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    /**
     * Generate a random string.
     */
    public function randomString(int length = 64)
    {
        var keyspace = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        /*
         * If the length is less than one, throw an error.
         */
        if (length < 1) {
            throw new \RangeException("Length must be a positive integer");
        }

        /*
         * Define the pieces array.
         */
        var pieces = [], iLoop;

        /*
         * Loop through and build pieces.
         */
        while (iLoop < length) {
            let pieces[] = substr(keyspace, random_int(0, 53), 1);
            let iLoop = iLoop + 1;
        }

        /*
         * Implode the pieces and return the random string.
         */
        return implode("", pieces);
    }

    public function redirect(string url)
    {
        header("Location: " . url);
        die();
    }

    public function saveFailed(string message)
    {
        return "<div class='error box wfull'>
        <div class='box-title'>
            <span>save error</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function saveSuccess(string message)
    {
        return "<div class='success box wfull'>
        <div class='box-title'>
            <span>save all done</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function tags(string path, string table)
    {
        var database, data, html = "";

        let database = new Database(this->cfg);
        let data = database->all("SELECT tags FROM " . table . " WHERE tags IS NOT NULL AND tags != ''");

        if (data) {
            let html .= "<div id='tags'>";
            var selected = "";
            if (isset(_GET["tag"])) {
                let selected = urldecode(_GET["tag"]);
            }
            var tag, json, value, url, tags = [];
            for tag in data {
                let json = json_decode(tag->tags);
                if (empty(json)) {
                    continue;
                }
                for value in json {
                    let tags[value->value] = value->value;
                }
            }

            for tag in tags {
                let url = path . "?tag=" . urlencode(tag);
                if (selected == tag) {
                    let url = path;
                }
                let html .= "<a href='/dumb-dog" . url . "' class='tag". 
                    (selected == tag ? " selected" : "") . "'>" . 
                    tag .
                    (selected == tag ? " <span>x</span>" : "") . 
                    "</a>";
            }
            let html .= "</div>";
        }

        return html;
    }

    public function triggerDelete(string path, string table)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM " . table . " WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException(rtrim(table, "s") . " not found");
        }

        let html = titles->page("Delete the " . rtrim(table, "s"), "delete");

        var from = this->validFrom();

        if (!empty(_POST)) {
            if (isset(_POST["delete"])) {
                var status = false, err;
                try {
                    if (this->cfg->save_mode == true) {
                        let data["updated_by"] = this->getUserId();
                        let status = database->execute("UPDATE " . table . " SET deleted_at=NOW(), deleted_by=:updated_by, updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to delete the " . rtrim(table, "s"));
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/" . table . "?deleted=true&from=" . from);
                    }
                } catch \Exception, err {
                    let html .= this->saveFailed(err->getMessage());
                }
            }
        }

        let html .= "<form method='post' action='/dumb-dog/" . table . "/delete/" . model->id . "?from=" . from . "'><div class='error box wfull'>
            <div class='box-title'>
                <span>are your sure?</span>
            </div>
            <div class='box-body'><p>I'll bury you ";
        if (model->name) {
            let html .= "<strong>" . model->name . "</strong> ";
        }
        let html .= "like I bury my bone...</p>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/" . table . "/edit/" . model->id . "?from=" . from . "' class='button-blank'>cancel</a>
                <button type='submit' name='delete'>delete</button>
            </div>
        </div></form>";

        return html;
    }

    public function triggerRecover(string path, string table)
    {
        var titles, html, database, data = [], model;
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM " . table . " WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException(ucwords(rtrim(table, "s")) . " not found");
        }

        let html = titles->page("Recover the " . rtrim(table, "s"), "recover");

        var from = this->validFrom();

        if (!empty(_POST)) {
            if (isset(_POST["recover"])) {
                var status = false, err;
                try {
                    let data["updated_by"] = this->getUserId();
                    let status = database->execute("UPDATE " . table . " SET deleted_at=NULL, deleted_by=NULL, updated_at=NOW(), updated_by=:updated_by WHERE id=:id", data);
                    
                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to recover the " . rtrim(table, "s"));
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/" . table . "/edit/" . model->id . "?from=" . from);
                    }
                } catch \Exception, err {
                    let html .= this->saveFailed(err->getMessage());
                }
            }
        }

        let html .= "<form method='post' action='/dumb-dog/" . table . "/recover/" . model->id . "?from=" . from . "'><div class='error box wfull'>
            <div class='box-title'>
                <span>are your sure?</span>
            </div>
            <div class='box-body'><p>";
        if (model->name) {
            let html .= "Dig up <strong>" . model->name . "</strong>";
        } else {
            let html .= "Dig it up";
        }
        let html .= "...</p>
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/" . table . "/edit/" . model->id . "?from=" . from . "' class='button-blank'>cancel</a>
                <button type='submit' name='recover'>recover</button>
            </div>
        </div></form>";

        return html;
    }

    public function validate(array data, array checks)
    {
        var iLoop = 0;
        while (iLoop < count(checks)) {
            if (!isset(data[checks[iLoop]])) {
                return false;
            } elseif (empty(data[checks[iLoop]])) {
                return false;
            }
            let iLoop = iLoop + 1;
        }
        return true;
    }

    public function validFrom()
    {
        if (isset(_GET["from"])) {
            if (in_array(_GET["from"], ["pages", "products"])) {
                return _GET["from"];
            }
        }
        return "pages";
    }
}