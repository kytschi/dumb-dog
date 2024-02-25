/**
 * Dumb Dog Inputs
 *
 * @package     DumbDog\Ui\Gfx\Inputs
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Ui\Gfx;

use DumbDog\Controllers\Database;
use DumbDog\Exceptions\Exception;
use DumbDog\Ui\Gfx\Buttons;
use DumbDog\Ui\Gfx\Icons;

class Inputs
{
    protected cfg;

    public function __construct()
    {
        let this->cfg = constant("CFG");
    }

    public function date(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = null
    ) {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : date("Y-m-d"));
        }

        if (strpos(value, "-") !== false) {
            let value = date("d/m/Y", strtotime(value));
        }

        var style = "";
        let style = this->setStyle(required, var_name);

        return "<div class='dd-input-group'>
            <label>" . label . (required ? "<span class='dd-required'>*</span>" : "") . "</label>
            <input
                type='text'
                name='" . var_name . "' 
                placeholder='' 
                class='datepicker dd-form-control" . (style ? " " . trim(style) . "" : "") . "' 
                value=\"" . htmlspecialchars(value, ENT_QUOTES) . "\">
        </div>";
    }

    public function file(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = ""
    ) {
        return this->generic(label, var_name, placeholder, required, value, "file");
    }

    private function generic(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = "",
        string type = "text",
        bool disabled = false
    ) {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : "");
            if (type == "password") {
                let value = "";
            }
        }

        var style = "";
        let style = this->setStyle(required, var_name);

        if (type == "tagify") {
            let type = "text";
            let style .= " tagify";
        }

        return "<div class='dd-input-group'>" .
            (label ? ("<label>" . label . (required ? "<span class='dd-required'>*</span>" : "") . "</label>") : "") .
            "<input 
                type='" . type . "'
                name='" . var_name . "' 
                placeholder='" . placeholder.  "' 
                class='dd-form-control" . (style ? " " . trim(style) . "" : "") . "' " . 
                (disabled ? "disabled='disabled' " : "") . 
                "value=\"" . htmlspecialchars(value, ENT_QUOTES) . "\">
      </div>";
    }

    public function hidden(string var_name, value)
    {
        return "<input 
            type='hidden'
            name='" . var_name . "' 
            value=\"" . htmlspecialchars(value, ENT_QUOTES) . "\">";
    }

    public function image(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        model = null
    ) {
        var style = "", image = "", buttons;
        let style = this->setStyle(required, var_name);
        let buttons = new Buttons();

        if (is_object(model)) {
            if (file_exists(model->thumbnail)) {
                let image = model->thumbnail;
            } else {
                let image = model->image;
            }
        } else {
            let image = model;
        }

        return "
        <div class='dd-row'>
            <div class='dd-col-6'>
                <div class='dd-input-group'>" . 
                    (label ? ("<label>" . label . (required ? "<span class='dd-required'>*</span>" : "") . "</label>") : "") .
                    "<input
                        type='file'
                        name='" . var_name . "' 
                        accept='image/*;capture=camera' 
                        class='dd-form-control" . (style ? " " . trim(style) . "" : "") . "' 
                        placeholder='" . placeholder.  "'/>
                </div>
            </div>
            <div class='dd-col-6 dd-image-preview dd-flex'>
                <div class='dd-col'>" .
                    (image ? "<img src='" . image . "'/>" : "<p>No image</p>") .
                "</div>" . 
                (image ? "<div class='dd-col-auto'>" . buttons->delete("", "deleted-image", "delete_image", "", true) . "</div>" : "") .
            "</div>
        </div>";
    }

    public function inputPopup(string id, string name, string title, string label = "Create")
    {
        var icons;
        let icons = new Icons();

        return "<button
            type='button'
            class='dd-button'
            data-inline-popup='#" . id . "'
            titile='" . title . "'>" . 
            icons->add() .
        "</button>
        <div 
            id='" . id . "' 
            class='dd-inline-popup'>
            <div class='dd-inline-popup-body'>
                <input class='dd-form-control' name='" . name . "' type='text'>
                <div class='dd-inline-popup-buttons'>
                    <button 
                        type='button'
                        class='dd-button'
                        data-inline-popup-close='#" . id . "'>" . 
                        icons->cancel() .
                    "</button>
                    <button type='submit' class='dd-button'>" . 
                        icons->accept() .
                    "</button>
                </div>
            </div>
        </div>";
    }

    public function isTagify(string tags)
    {
        if (strpos(tags, "[{") !== false) {
            return tags;
        }
        return "";
    }

    public function number(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = ""
    ) {
        return this->generic(label, var_name, placeholder, required, value, "number");
    }

    public function password(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = ""
    ) {
        return this->generic(label, var_name, placeholder, required, value, "password");
    }

    public function searchBox(string url, string label = "Search the entries")
    {
        var html = "", buttons;
        let buttons = new Buttons();

        let html = "
        <form class='dd-box' action='" . url . "' method='post'>
            <div class='dd-box-body'>
                <div class='dd-flex'>
                    <div class='dd-col'>
                        <input 
                            class='dd-form-control dd-wfull'
                            name='q'
                            type='text' 
                            placeholder='Search the entries'
                            value='" . (isset(_POST["q"]) ? _POST["q"]  : ""). "'>
                    </div>
                    <div class='dd-col-auto dd-pl-4'>";

        if (isset(_POST["q"])) {
            let html .= "<a href='" . url . "' class='dd-button-blank dd-mr-3'>clear</a>";
        }
            
        let html .= "   <button 
                            type='submit'
                            name='search' 
                            class='dd-button' 
                            value='search'>search</button>
                    </div>
                </div>
            </div>
        </form>";

        return html;
    }

    public function select(
        string label, 
        string var_name, 
        string placeholder,
        array data, 
        bool required = false, 
        selected = ""
    ) {
        var html = "", item, key, style = "";

        if (empty(selected)) {
            let selected = isset(_POST[var_name]) ? _POST[var_name] : "";
        }

        let style = this->setStyle(required, var_name);

        let html .= "<div class='dd-input-group'>
                <label>" . 
                    label . 
                    (required ? "<span class='dd-required'>*</span>" : "") .
                "</label>
                <select 
                    name='" . var_name . "' 
                    class='dd-form-control" . (style ? " " . trim(style) . "" : "") . "'>";

        if (count(data)) {
            for key, item in data {
                let html .= "<option value='" . key . "'" . 
                    ((selected == key) ? " selected='selected'" : "") . ">" . 
                    item . 
                    "</option>";
            }
        } else {
            let html .= "<option value=''>Nothing available</option>";
        }

        let html .= "</select></div>";
        return html;
    }

    public function selectDB(
        string label, 
        string var_name, 
        string placeholder,
        string query, 
        bool required = false, 
        selected = ""
    ) {
        var database, results, data = [], iLoop = 0;

        let database = new Database();
        let results = database->all(query);

        while (iLoop < count(results)) {
            let data[results[iLoop]->id] = results[iLoop]->name;
            let iLoop += 1;
        }

        return this->select(label, var_name, placeholder, data, required, selected);
    }

    private function setStyle(bool required, string var_name)
    {
        if (required && count(_POST)) {
            if (!isset(_POST[var_name])) {
                return "required";
            } else {
                if (empty(_POST[var_name])) {
                    return "required";
                }
            }
        }

        return "";
    }

    public function tags(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = ""
    ) {
        if (value) {
            let value = str_replace("'", "&#39;", value);
        }

        return this->generic(label, var_name, placeholder, required, value, "tagify");
    }

    public function text(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = "",
        bool disabled = false
    ) {
        return this->generic(label, var_name, placeholder, required, value, "text", disabled);
    }

    public function textarea(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = null,
        int length = 1000
    ) {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : "");
        }

        var style = "";
        let style = this->setStyle(required, var_name);

        return "<div class='dd-input-group'>
            <label>" . label . (required ? "<span class='dd-required'>*</span>" : "") . "</label>
            <textarea
                name='" . var_name . "' 
                rows='4' 
                maxlength'" . length . "' 
                class='dd-form-control" . (style ? " " . trim(style) . "" : "") . "' 
                placeholder='" . placeholder . "'" . 
                (required ? " required='required'" : "") . 
            ">" . value . "</textarea>
        </div>";
    }

    public function toggle(
        string label,
        string var_name,
        bool required = false,
        selected = false
    ) {
        var style = "";
        let style = this->setStyle(required, var_name);

        return "<div class='dd-input-group'>
            <label>" .
                label .
                (required ? "<span class='dd-required'>*</span>" : "") .
            "</label>
            <div class='dd-switcher'>
                <label>
                    <input 
                        type='checkbox'
                        name='" . var_name . "' 
                        value='1' " . 
                        (selected ? " checked='checked'" : "") . ">
                    <span" . (style ? " class='" . trim(style) . "'" : "") . ">
                        <small class='dd-switcher-on'></small>
                        <small class='dd-switcher-off'></small>
                    </span>
                </label>
            </div>
        </div>";
    }

    public function wysiwyg(
        string label,
        string var_name,
        string placeholder,
        bool required = false,
        value = null
    ) {
        if (empty(value)) {
            let value = (isset(_POST[var_name]) ? _POST[var_name] : "");
        }

        var style = "";
        let style = this->setStyle(required, var_name);

        return "<div class='dd-input-group'>
            <label>" . label . (required ? "<span class='dd-required'>*</span>" : "") . "</label>
            <textarea
                class='dd-form-control wysiwyg" . (style ? " " . trim(style) . "" : "") . "' 
                name='" . var_name . "' 
                rows='7' 
                placeholder='" . placeholder . "'" . 
                (required ? " required='required'" : "") . 
            ">" . value . "</textarea>
        </div>";
    }
}
