/**
 * Dumb Dog appointments builder
 *
 * @package     DumbDog\Controllers\Appointments
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

class Appointments extends Controller
{
    public function add(string path)
    {
        var titles, html, database;
        let titles = new Titles();
        let database = new Database(this->cfg);

        let html = titles->page("Add an appointment", "add");
        let html .= "<div class='page-toolbar'><a href='/dumb-dog/appointments' class='round icon icon-back' title='Back to list'>&nbsp;</a></div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["with_name", "user_id", "on_date", "on_time"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["user_id"] = _POST["user_id"];
                    let data["with_name"] = _POST["with_name"];
                    let data["with_email"] = _POST["with_email"];
                    let data["with_number"] = _POST["with_number"];
                    let data["content"] = _POST["content"];
                    let data["on_date"] = this->dateToSql(_POST["on_date"] . " " . _POST["on_time"] . ":00");
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "INSERT INTO appointments 
                                (
                                    id,
                                    user_id,
                                    with_name,
                                    with_email,
                                    with_number,
                                    content,
                                    on_date,
                                    created_at,
                                    created_by,
                                    updated_at,
                                    updated_by
                                ) 
                            VALUES 
                                (
                                    UUID(),
                                    :user_id,
                                    :with_name,
                                    :with_email,
                                    :with_number,
                                    :content,
                                    :on_date,
                                    NOW(),
                                    :created_by,
                                    NOW(),
                                    :updated_by
                                )",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the appointment");
                        let html .= this->consoleLogError(status);
                    } else {
                        let html .= this->saveSuccess("I've saved the appointment");
                        let _POST["on_date"] = null;
                        let _POST["with_name"] = null;
                        let _POST["with_email"] = null;
                        let _POST["with_number"] = null;
                        let _POST["content"] = null;
                    }
                }
            }
        }

        let html .= "<form method='post'>
        <div class='box wfull'>
            <div class='box-title'>
                <span>the appointment</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>for user<span class='required'>*</span></span>
                    <select name='user_id'>";

        var iLoop = 0, selected = "", data;
        let data = database->all("SELECT * FROM users ORDER BY name");

        if (isset(_POST["user_id"])) {
            let selected = _POST["user_id"];
        } else {
            let selected = this->getUserId();
        }

        while (iLoop < count(data)) {
            let html .= "<option value='" . data[iLoop]->id . "'";
            if (data[iLoop]->id == selected) {
                let html .= " selected='selected'";
            }
            let html .= ">" . data[iLoop]->name . "</option>";
            let iLoop = iLoop + 1;
        }

        let html .= "</select></div>";

        let html .= 
                this->createInputDate("when its happening", "on_date", "leave a comment?", true) .
                "<div class='input-group'>
                    <span>what time, enter as hour:minutes<span class='required'>*</span></span>
                    <input type='text' name='on_time' placeholder='24 hour time please' value='" .
                    (isset(_POST["on_time"]) ? date("H:i", strtotime(_POST["on_time"])) : "00:00") . "'>
                </div> " .
                this->createInputText("name", "with_name", "give me their name", true) .
                this->createInputText("email", "with_email", "give me their email if possible") . 
                this->createInputText("number", "with_number", "give me their number if possible") .
                this->createInputTextarea("comment", "content", "leave a comment?") . 
        "</div>
            <div class='box-footer'>
                <a href='/dumb-dog/appointments' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function delete(string path)
    {
        return this->triggerDelete(path, "appointments");
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let database = new Database(this->cfg);
        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM appointments WHERE id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Appointment not found");
        }

        let html = titles->page("Edit the appointment", "edit");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let html .= "<div class='page-toolbar";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'><a href='/dumb-dog/appointments' class='round icon icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/appointments/recover/" . model->id . "' class='round icon icon-recover' title='Recover the appointment'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/appointments/delete/" . model->id . "' class='round icon icon-delete' title='Delete the appointment'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "file"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["name"] = _POST["name"];
                    let data["file"] = _POST["file"];
                    let data["default"] = isset(_POST["default"]) ? 1 : 0;
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        if (data["default"]) {
                            let status = database->execute(
                                "UPDATE appointments SET `default`=0, updated_at=NOW(), updated_by=:updated_by",
                                data
                            );
                        }
                        let status = database->execute(
                            "UPDATE appointments SET 
                                name=:name, file=:file, `default`=:default, updated_at=NOW(), updated_by=:updated_by
                            WHERE id=:id",
                            data
                        );
                    } else {
                        let status = true;
                    }

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the appointment");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect("/dumb-dog/appointments/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the appointment");
        }

        let html .= "<form method='post'><div class='box wfull";
        if (model->deleted_at) {
            let html .= " deleted";
        }
        let html .= "'>
            <div class='box-title'>
                <span>the appointment</span>
            </div>
            <div class='box-body'>
                <div class='input-group'>
                    <span>name<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='make sure to set a name' value='" . model->name . "'>
                </div>
                <div class='input-group'>
                    <span>file<span class='required'>*</span></span>
                    <input type='text' name='file' placeholder='where am I located and with what file?' value='" . model->file . "'>
                </div>
                <div class='input-group'>
                    <span>default</span>
                    <div class='switcher'>
                        <label>
                            <input type='checkbox' name='default' value='1'";

                if (model->{"default"} == 1) {
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
            </div>
            <div class='box-footer'>
                <a href='/dumb-dog/appointments' class='button-blank'>cancel</a>
                <button type='submit' name='save'>save</button>
            </div>
        </div></form>";

        return html;
    }

    public function index(string path)
    {
        var titles, tiles, database, html;

        let database = new Database(this->cfg);
        let titles = new Titles();
        let tiles = new Tiles();
        
        let html = titles->page("Appointments", "appointments");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the appointment");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/appointments/add' class='round icon' title='Add an appointment'>&nbsp;</a>
        </div>";

        var days, iLoop = 0, start, blanks = 0, data, entry;
        
        let start = date("l", strtotime(date("Y-01-01")));

        let html .= "<div id='calendar-month'><span>" . date("F Y") . "</span></div><div id='calendar'>";
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        while(iLoop < count(days)) {
            let html .= "<div class='calendar-day'>" . days[iLoop] . "</div>";
            if (days[iLoop] == start) {
                let blanks = iLoop + 1;
            }
            let iLoop = iLoop + 1;
        }

        if (blanks) {
            let iLoop = 0;
            while(iLoop < blanks) {
                let html .= "<div class='calendar-blank'></div>";
                let iLoop = iLoop + 1;
            }
        }

        let days = cal_days_in_month(CAL_GREGORIAN, date("m"), date("Y"));
        let iLoop = 1;
        while(iLoop <= days) {
            let html .= "<div class='calendar-entry'><div class='calendar-date'>" . iLoop . "</div>";
            let data = database->all(
                "SELECT * FROM appointments WHERE on_date BETWEEN CONCAT(:on_date, ' 00:00') AND CONCAT(:on_date, ' 23:59')",
                [
                    "on_date": date("Y-m-" . iLoop)
                ]
            );
            if (data) {
                for entry in data {
                    let html .= "<div class='calendar-event'><small>" .
                        date("H:i", strtotime(entry->on_date)) . "</small><br/>" . 
                        entry->with_name . 
                    "</div>";
                }
            }
            let html .= "</div>";
            let iLoop = iLoop + 1;
        }
        let html .= "</div>";
        
        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "appointments");
    }
}