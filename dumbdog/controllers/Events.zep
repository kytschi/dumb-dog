/**
 * Dumb Dog event builder
 *
 * @package     DumbDog\Controllers\Events
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

use DumbDog\Controllers\Pages;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class Events extends Pages
{
    public global_url = "/dumb-dog/events";
    
    public function add(string path, string type = "event")
    {
        return parent::add(path, type);
    }

    public function addHtml()
    {
        return this->createInputDate("when its on", "event_on", "please set a date if required") . 
            this->createInputText("what time its on, enter as hour:minutes", "event_time", "24 hour time please") .
            this->createInputSelect(
                "how long for",
                "event_length",
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
            );
    }

    public function edit(string path, string type = "event")
    {
        return parent::edit(path, type);
    }

    public function editHtml(model)
    {
        return this->createInputDate("when its on", "event_on", "please set a date if required", false, date("d/m/Y", strtotime(model->event_on))) . 
            this->createInputText("what time its on, enter as hour:minutes", "event_time", "24 hour time please", false, date("H:i", strtotime(model->event_on))) .
            this->createInputSelect(
                "how long for",
                "event_length",
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
                model->event_length
            );
    }

    public function index(string path)
    {
        var titles, table, database, html, query, data;
        let titles = new Titles();
        let table = new Table(this->cfg);
        
        let html = titles->page("Events", "events");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the event");
        }

        let html .= "<div class='dd-page-toolbar'>
            <a href='/dumb-dog/pages' class='dd-link dd-round dd-icon dd-icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/events/add' class='dd-link dd-round dd-icon' title='Add an event'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);
        let data = [];
        let query = "
            SELECT main_page.*,
            IFNULL(templates.name, 'No template') AS template, 
            IFNULL(parent_page.name, 'No parent') AS parent 
            FROM pages AS main_page 
            LEFT JOIN templates ON templates.id=main_page.template_id 
            LEFT JOIN pages AS parent_page ON parent_page.id=main_page.parent_id 
            WHERE main_page.type='event'";
        if (isset(_GET["tag"])) {
            let query .= " AND main_page.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY main_page.name";

        let html = html . table->build(
            [
                "name|with_tags",
                "event_on|event_date"
            ],
            database->all(query, data),
            "/dumb-dog/" . path
        );

        return html;
    }
}