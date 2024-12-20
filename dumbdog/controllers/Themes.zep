/**
 * Dumb Dog themes
 *
 * @package     DumbDog\Controllers\Themes
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;

class Themes extends Content
{
    public global_url = "/themes";

    public function add(string path)
    {
        var html, data = [], status = false;
        let html = this->titles->page("Add a theme", "add");
        let html .= "<div class='dd-page-toolbar'>
            <a href='" . this->global_url . "' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                if (!this->validate(_POST, ["name", "folder"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["folder"] = _POST["folder"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["created_by"] = this->database->getUserId();
                    let data["updated_by"] = this->database->getUserId();

                    let status = this->database->execute(
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

        let html .= "<form method='post'><div class='dd-box dd-wfull'>
            <div class='dd-box-title'>
                <span>the theme</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>name<span class='dd-required'>*</span></span>
                    <input type='text' name='name' placeholder='give me a name' value=''>
                </div>
                <div class='dd-input-group'>
                    <span>folder<span class='dd-required'>*</span></span>
                    <input type='text' name='folder' placeholder='where am I located?' value=''>
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
        return this->triggerDelete(path, "themes");
    }

    public function edit(string path)
    {
        var html, model, data = [], status = false;
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("SELECT * FROM themes WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Theme not found");
        }

        let html = this->titles->page("Edit the theme", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'><a href='" . this->global_url . "' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/" . this->global_url . "/recover/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-recover' title='Recover the theme'>&nbsp;</a>";
        } else {
            let html .= "<a href='" . this->global_url . "/delete/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-delete' title='Delete the theme'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                if (!this->validate(_POST, ["name", "folder"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["folder"] = _POST["folder"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["updated_by"] = this->database->getUserId();

                    let status = this->database->execute(
                        "UPDATE themes SET 
                            name=:name, folder=:folder, `default`=:default, updated_at=NOW(), updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the theme");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("" . this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the theme");
        }

        let html .= "<form method='post'><div class='dd-box dd-wfull";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <div class='dd-box-title'>
                <span>the theme</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>name<span class='dd-required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . model->name . "'>
                </div>
                <div class='dd-input-group'>
                    <span>folder<span class='dd-required'>*</span></span>
                    <input type='text' name='folder' placeholder='where am I located?' value='" . model->folder . "'>
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
                
        let html = this->titles->page("Themes", "themes");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the theme");
        }

        let html .= "<div class='dd-page-toolbar'>
            <a href='" . this->global_url . "/add' class='dd-link dd-round dd-icon' title='Add a theme'>&nbsp;</a>
        </div>";

        /*let html = html . this->tiles->build(
            this->database->all("SELECT * FROM themes"),
            this->global_url . "/edit/"
        );*/

        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "themes");
    }
}