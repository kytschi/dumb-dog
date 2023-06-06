/**
 * Dumb Dog file handler
 *
 * @package     DumbDog\Controllers\Files
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

class Files extends Controller
{
    public function add(string path)
    {
        var titles, html, data, database;
        let titles = new Titles();
        let database = new Database(this->cfg);

        var from = this->validFrom();

        let html = titles->page("Upload a file", "add");
        let html .= "<div class='dd-page-toolbar'>
            <a  href='/dumb-dog/files?from=" . from . "'
                class='dd-link dd-round dd-icon dd-icon-back'
                title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, ["name"]) || !this->validate(_FILES, ["file"])) {
                    let html .= this->missingRequired();
                } else {
                    var filename;
                    let filename = this->randomString(16) .
                        "-" .
                        str_replace([" ", "\"", "'", "’", "&", ":", ";"], "-", strtolower(_FILES["file"]["name"]));
                    let data["name"] = _POST["name"];
                    let data["filename"] = filename;
                    let data["mime_type"] = _FILES["file"]["type"];
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();
                    let data["tags"] = this->isTagify(_POST["tags"]);

                    if (this->cfg->save_mode != false) {
                        if (empty(_FILES["file"]["tmp_name"])) {
                            throw new \Exception("Failed to upload the file");
                        }
                        copy(
                            _FILES["file"]["tmp_name"],
                            getcwd() . "/website/files/" . filename
                        );

                        this->createThumb(filename);
                    }

                    let status = database->execute(
                        "INSERT INTO files 
                            (id,
                            name,
                            filename,
                            mime_type,
                            tags,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (UUID(),
                            :name,
                            :filename,
                            :mime_type,
                            :tags,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the file");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/files/add?from=" . from . "&saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've saved the file");
        }

        let html .= "<form method='post' action='/dumb-dog/files/add?from=" . from . "' enctype='multipart/form-data'>
            <div class='dd-box dd-wfull'>
                <div class='dd-box-title'>
                    <span>the file</span>
                </div>
                <div class='dd-box-body'>
                    <div class='dd-input-group'>
                        <span>name<span class='dd-required'>*</span></span>
                        <input type='text' name='name' placeholder='give me a name' value=''>
                    </div>
                    <div class='dd-input-group'>
                        <span>file<span class='dd-required'>*</span></span>
                        <input type='file' name='file' placeholder='upload a file' value=''>
                    </div>
                    <div class='dd-input-group'>
                        <span>tags</span>
                        <input type='text' name='tags' class='tagify' placeholder='tag the file' value=''>
                    </div>
                </div>
                <div class='dd-box-footer'>
                    <a href='/dumb-dog/files?from=" . from . "' class='dd-link dd-button-blank'>cancel</a>
                    <button type='submit' name='save' class='dd-button'>save</button>
                </div>
            </div>
        </form>";

        return html;
    }

    private function createThumb(string filename)
    {
        var width, height, desired_width = 400, desired_height, upload, save;

        let filename = "thumb-" . filename;      
        
        switch (_FILES["file"]["type"]) {
            case "image/jpeg":
                let upload = imagecreatefromjpeg(_FILES["file"]["tmp_name"]);
                break;
            case "image/png":
                let upload = imagecreatefrompng(_FILES["file"]["tmp_name"]);
                break;
            default:
                return;
        }

        let width = imagesx(upload);
        let height = imagesy(upload);

        let desired_height = floor(height * (desired_width / width));
        let save = imagecreatetruecolor(desired_width, desired_height);
        imagecopyresampled(save, upload, 0, 0, 0, 0, desired_width, desired_height, width, height);

        switch (_FILES["file"]["type"]) {
            case "image/jpeg":
                imagejpeg(save, getcwd() . "/website/files/" . filename, 60);
                break;
            case "image/png":
                imagepng(save, getcwd() . "/website/files/" . filename, 6);
                break;
        }
    }

    public function delete(string path)
    {
        return this->triggerDelete(path, "files");
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM files WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("File not found");
        }

        let html = titles->page("Edit the file", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }

        var from = this->validFrom();

        let html .= "'><a href='/dumb-dog/files?from=" . from . "' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/files/recover/" . model->id . "?from=" . from . "' class='dd-link dd-round dd-icon dd-icon-recover' title='Recover the file'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/files/delete/" . model->id . "?from=" . from . "' class='dd-link dd-round dd-icon dd-icon-delete' title='Delete the file'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["tags"] = this->isTagify(_POST["tags"]);
                    let data["updated_by"] = this->getUserId();

                    let database = new Database(this->cfg);
                    let status = database->execute(
                        "UPDATE files SET 
                            name=:name,
                            tags=:tags,
                            updated_at=NOW(),
                            updated_by=:updated_by
                        WHERE id=:id",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the file");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/files/edit/" . model->id . "?from=" . from . "&saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the file");
        }

        let html .= "<form method='post' action='/dumb-dog/files/edit/" . model->id . "?from=" . from . "' enctype='multipart/form-data'>
        <div class='dd-box dd-wfull";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <div class='dd-box-title'>
                <span>the file</span>
            </div>
            <div class='dd-box-body'>
                <div class='dd-input-group'>
                    <span>name<span class='dd-required'>*</span></span>
                    <input type='text' name='name' placeholder='the file name' value='" . model->name . "'>
                </div>
                <div class='dd-input-group'>
                    <span>tags</span>
                    <input type='text' name='tags' class='tagify' placeholder='tag the file' value='" . model->tags . "'>
                </div>
            </div>
            <div class='dd-box-footer'>
                <a href='/dumb-dog/files?from=" . from . "' class='dd-link dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var titles, tiles, database, html, data, query;

        let database = new Database(this->cfg);
        let titles = new Titles();
        let tiles = new Tiles();
        
        let html = titles->page("Files", "files");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the file item");
        }

        var from = this->validFrom();

        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/" . from . "' class='dd-link dd-round dd-icon dd-icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/files/add?from=" . from . "' class='dd-link dd-round dd-icon' title='Upload some media'>&nbsp;</a>
        </div>";

        let html .= this->tags(path, "files");

        let data = [];
        let query = "SELECT * FROM files";
        if (isset(_GET["tag"])) {
            let query .= " WHERE tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY name";
        let html = html . tiles->build(
            database->all(query, data),
            "/dumb-dog/" . path . "/edit/",
            from
        );
        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "files");
    }
}