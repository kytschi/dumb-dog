/**
 * Dumb Dog appointments builder
 *
 * @package     DumbDog\Controllers\Appointments
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
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
    /*public function add(string path)
    {
        var titles, html, database;
        let titles = new Titles();
        let database = new Database(this->cfg);

        let html = titles->page("Add an appointment", "add");
        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/appointments' class='dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>
        </div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, data = [], status = false;

                if (!this->validate(_POST, ["name", "user_id", "on_date", "on_time"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["user_id"] = _POST["user_id"];
                    let data["name"] = _POST["name"];
                    let data["with_email"] = _POST["with_email"];
                    let data["with_number"] = _POST["with_number"];
                    let data["content"] = _POST["content"];
                    let data["free_slot"] = isset(_POST["free_slot"]) ? 1 : 0;
                    let data["appointment_length"] = isset(_POST["appointment_length"]) ? _POST["appointment_length"] : null;
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
                                    name,
                                    with_email,
                                    with_number,
                                    content,
                                    on_date,
                                    free_slot,
                                    appointment_length,
                                    created_at,
                                    created_by,
                                    updated_at,
                                    updated_by
                                ) 
                            VALUES 
                                (
                                    UUID(),
                                    :user_id,
                                    :name,
                                    :with_email,
                                    :with_number,
                                    :content,
                                    :on_date,
                                    :free_slot,
                                    :appointment_length,
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
                        this->redirect("/dumb-dog/appointments/add?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've created the appointment");
        }

        let html .= "<form method='post'>
        <div class='dd-box dd-wfull'>
            <div class='dd-box-title'>
                <span>the appointment</span>
            </div>
            <div class='dd-box-body'>";
        let html .= this->createInputSwitch("free slot", "free_slot", false, isset(_POST["free_slot"]) ? _POST["free_slot"] : false);
        let html .= "<div class='dd-input-group'>
                    <span>for user<span class='dd-required'>*</span></span>
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
                this->createInputText(
                    "what time, enter as hour:minutes",
                    "on_time",
                    "24 hour time please",
                    true,
                    (isset(_POST["on_time"]) ? date("H:i", strtotime(_POST["on_time"])) : "")
                ) .
                this->createInputSelect(
                    "how long for",
                    "appointment_length",
                    [
                        "1": "1 hour",
                        "2": "2 hours",
                        "4": "4 hours",
                        "all_day": "all day",
                        "daily": "daily",
                        "weekly": "weekly",
                        "monthly": "monthly",
                        "annually": "annually"
                    ]
                ) .
                this->createInputText("label", "name", "give me a label", true) .
                this->createInputText("email", "with_email", "give me their email if possible") . 
                this->createInputText("number", "with_number", "give me their number if possible") .
                this->createInputTextarea("details", "content", "any details?") . 
        "</div>
            <div class='dd-box-footer'>
                <a href='/dumb-dog/appointments' class='dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
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

        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <a href='/dumb-dog/appointments' class='dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/appointments/recover/" . model->id . "' class='dd-round dd-icon dd-icon-recover' title='Recover the appointment'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/appointments/delete/" . model->id . "' class='dd-round dd-icon dd-icon-delete' title='Delete the appointment'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var database, status = false;

                if (!this->validate(_POST, ["name", "user_id", "on_date", "on_time"])) {
                    let html .= this->missingRequired();
                } else {
                    let data["user_id"] = _POST["user_id"];
                    let data["name"] = _POST["name"];
                    let data["with_email"] = _POST["with_email"];
                    let data["with_number"] = _POST["with_number"];
                    let data["content"] = _POST["content"];
                    let data["free_slot"] = isset(_POST["free_slot"]) ? 1 : 0;
                    let data["appointment_length"] = isset(_POST["appointment_length"]) ? _POST["appointment_length"] : null;
                    let data["on_date"] = this->dateToSql(_POST["on_date"] . " " . _POST["on_time"] . ":00");
                    let data["updated_by"] = this->getUserId();

                    if (this->cfg->save_mode == true) {
                        let database = new Database(this->cfg);
                        let status = database->execute(
                            "UPDATE appointments SET 
                                user_id=:user_id,
                                name=:name, 
                                with_email=:with_email, 
                                with_number=:with_number, 
                                content=:content, 
                                on_date=:on_date, 
                                free_slot=:free_slot,
                                appointment_length=:appointment_length, 
                                updated_at=NOW(), 
                                updated_by=:updated_by
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

        let html .= "<form method='post'>
        <div class=dd-box dd-wfull";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'>
            <div class='dd-box-title'>
                <span>the appointment</span>
            </div>
            <div class='dd-box-body'>";
        let html .= this->createInputSwitch("free slot", "free_slot", false, model->free_slot);
        let html .= "<div class='dd-input-group'>
                    <span>for user<span class='dd-required'>*</span></span>
                    <select name='user_id'>";

        var iLoop = 0, selected = "";
        let data = database->all("SELECT * FROM users ORDER BY name");

        if (isset(_POST["user_id"])) {
            let selected = _POST["user_id"];
        } else {
            let selected = model->user_id;
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
                this->createInputDate("when its happening", "on_date", "leave a comment?", true, model->on_date) .
                this->createInputText(
                    "what time, enter as hour:minutes",
                    "on_time",
                    "24 hour time please",
                    true,
                    (isset(_POST["on_time"]) ? date("H:i", strtotime(_POST["on_time"])) : date("H:i", strtotime(model->on_date)))
                ) .
                this->createInputSelect(
                    "how long for",
                    "appointment_length",
                    [
                        "1": "1 hour",
                        "2": "2 hours",
                        "4": "4 hours",
                        "all_day": "all day",
                        "daily": "daily",
                        "weekly": "weekly",
                        "monthly": "monthly",
                        "annually": "annually"
                    ],
                    false,
                    model->appointment_length
                ) .
                this->createInputText("label", "name", "give me a label", true, model->name) .
                this->createInputText("email", "with_email", "give me their email if possible", false, model->with_email) . 
                this->createInputText("number", "with_number", "give me their number if possible", false, model->with_number) .
                this->createInputTextarea("details", "content", "any details?", false, model->content) . 
        "</div>
            <div class='dd-box-footer'>
                <a href='/dumb-dog/appointments' class='dd-button-blank'>cancel</a>
                <button type='submit' name='save' class='dd-button'>save</button>
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

        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/appointments/add' class='dd-round dd-icon' title='Add an appointment'>&nbsp;</a>
        </div>";

        var days, iLoop = 0, start, blanks = 0, data, entry, today = 0, date;
        
        if (isset(_GET["date"])) {
            let date = _GET["date"];
        } else {
            let date = date("Y-m");
        }

        let start = date("l", strtotime(date(date . "-01")));
        if (date("Y-m") == date) {
            let today = intval(date("d"));
        }
        
        let html .= "<div id='dd-calendar-month'>
            <div>
                <span>
                    " . date("F Y", strtotime(date . "-01")) . "
                </span>
                <a href='/dumb-dog/appointments?date=" . date("Y-m", strtotime("-1 months", strtotime(date . "-01"))) . "' class='dd-link dd-icon dd-icon-prev'>&nbsp;</a>
                <a href='/dumb-dog/appointments?date=" . date("Y-m", strtotime("+1 months", strtotime(date . "-01"))) . "' class='dd-link dd-icon dd-icon-next'>&nbsp;</a>
            </div>
        </div><div id='dd-calendar'>";
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        while(iLoop < count(days)) {
            let html .= "<div class='dd-calendar-day'>" . days[iLoop] . "</div>";
            if (days[iLoop] == start) {
                let blanks = iLoop;
            }
            let iLoop = iLoop + 1;
        }

        if (blanks) {
            let iLoop = 0;
            while(iLoop < blanks) {
                let html .= "<div class='dd-calendar-blank'></div>";
                let iLoop = iLoop + 1;
            }
        }

        let days = cal_days_in_month(CAL_GREGORIAN, date("m"), date("Y"));
        let iLoop = 1;
        while(iLoop <= days) {
            let html .= "<div class='dd-calendar-entry";
            if (iLoop == today) {
                let html .= " dd-calendar-today";
            } elseif (iLoop < today) {
                let html .= " dd-calendar-blank";
            }
            let html .= "'><div class='dd-calendar-date'>" . iLoop ."</div>";
            let data = database->all(
                "SELECT * FROM appointments WHERE on_date BETWEEN CONCAT(:on_date, ' 00:00') AND CONCAT(:on_date, ' 23:59') ORDER BY on_date",
                [
                    "on_date": date(date . "-" . iLoop)
                ]
            );
            if (data) {
                for entry in data {
                    let html .= "<div class='dd-calendar-event";
                    if (entry->free_slot) {
                        let html .= " dd-calendar-free-slot";
                    }
                    let html .= "'><a href='/dumb-dog/appointments/edit/" . entry->id . "' class='dd-link'>
                        <small>" .date("H:i", strtotime(entry->on_date));
                    if (entry->free_slot) {
                        let html .= "&nbsp;<span>free slot</span>";
                    }
                    let html .= "</small><br/>" . 
                        entry->name . 
                    "</a></div>";
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
    }*/
}