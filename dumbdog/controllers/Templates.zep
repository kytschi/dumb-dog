/**
 * Dumb Dog templates builder
 *
 * @package     DumbDog\Controllers\Templates
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;

class Templates extends Content
{
    public global_url = "/templates";

    public function add(string path)
    {
        var  html;
        let html = this->titles->page("Add a template", "add");
        let html .= "<div class='dd-page-toolbar'>
            <a href='" . this->global_url . "' class='dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var data = [], status = false;

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["created_by"] = this->database->getUserId();
                    let data["updated_by"] = this->database->getUserId();

                    if (this->cfg->save_mode == true) {
                        let status = this->database->execute(
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

        let html .= "<form method='post'><div class='dd-box dd-wfull'>
            <div class='dd-box-title'>
                <span>the template</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>name<span class='dd-required'>*</span></span>
                    <input type='text' name='name' placeholder='give me a name' value=''>
                </div>
                <div class='dd-input-group'>
                    <span>file<span class='dd-required'>*</span></span>
                    <input type='text' name='file' placeholder='where am I located and with what file?' value=''>
                </div>
                <div class='dd-input-group'>
                    <span>default</span>
                    <div class='dd-switcher'>
                        <label>
                            <input type='checkbox' name='default' value='1'>
                            <span>
                                <small class='dd-switcher-on'></small>
                                <small class='dd-switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>
            </div>
            <div class='dd-box-footer'>
                <a href='" . this->global_url . "' class='dd-link dd-button-blank'>cancel</a>
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
        var html, model, data = [], status = false;
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM templates WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Template not found");
        }

        let html = this->titles->page("Edit the template", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'><a href='" . this->global_url . "' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='" . this->global_url . "/recover/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-recover' title='Recover the template'>&nbsp;</a>";
        } else {
            let html .= "<a href='" . this->global_url . "/delete/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-delete' title='Delete the template'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["updated_by"] = this->database->getUserId();

                    if (this->cfg->save_mode == true) {
                        if (data["default"]) {
                            let status = this->database->execute(
                                "UPDATE templates SET `default`=0, updated_at=NOW(), updated_by=:updated_by",
                                data
                            );
                        }
                        let status = this->database->execute(
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
                        this->redirect(this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the template");
        }

        let html .= "<form method='post'><div class='dd-box dd-wfull";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <div class='dd-box-title'>
                <span>the template</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>name<span class='dd-required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . model->name . "'>
                </div>
                <div class='dd-input-group'>
                    <span>file<span class='dd-required'>*</span></span>
                    <input type='text' name='file' placeholder='where am I located and with what file?' value='" . model->file . "'>
                </div>
                <div class='dd-input-group'>
                    <span>default</span>
                    <div class='dd-switcher'>
                        <label>
                            <input type='checkbox' name='default' value='1'";

                if (model->{"default"} == 1) {
                    let html .= " checked='checked'";
                }
                
                let html .= ">
                            <span>
                                <small class='dd-switcher-on'></small>
                                <small class='dd-switcher-off'></small>
                            </span>
                        </label>
                    </div>
                </div>
            </div>
            <div class='dd-box-footer'>
                <a href='" . this->global_url . "' class='dd-link dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var html;
                
        let html = this->titles->page("Templates", "templates");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the template");
        }

        let html .= "<div class='dd-page-toolbar'>
            <a href='" . this->cfg->dumb_dog_url . "/pages' class='dd-link dd-round dd-icon dd-icon-up' title='Back to pages'>&nbsp;</a>
            <a href='" . this->global_url . "/add' class='dd-link dd-round dd-icon' title='Add a template'>&nbsp;</a>
        </div>";

        let html .= this->tables->build(
            [
                "name",
                "default|bool"
            ],
            this->database->all("SELECT * FROM templates ORDER BY `default` DESC, name ASC"),
            this->global_url
        );

        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "templates");
    }
}