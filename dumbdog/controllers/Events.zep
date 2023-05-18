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
use DumbDog\Ui\Gfx\Tiles;
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
        return "
            <div class='input-group'>
                <span>when its on</span>
                <input type='text' class='datepicker' name='event_on'>
            </div>
            <div class='input-group'>
                <span>what time its on, enter as hour:minutes</span>
                <input type='text' name='event_time' placeholder='24 hour time please' value=''>
            </div>
            <div class='input-group'>
                <span>how long for</span>
                <select name='event_length'>
                    <option value='1'>1 hour</option>
                    <option value='2'>2 hours</option>
                    <option value='4'>4 hours</option>
                    <option value='all_day'>all day</option>
                    <option value='daily'>daily</option>
                    <option value='weekly'>weekly</option>
                    <option value='monthly'>monthly</option>
                    <option value='annually'>annually</option>
                </select>
            </div>";
    }

    public function edit(string path, string type = "event")
    {
        return parent::edit(path, type);
    }

    public function editHtml(model)
    {
        return "
        <div class='input-group'>
            <span>when its on</span>
            <input type='text' class='datepicker' name='event_on' value='" . date("d/m/Y", strtotime(model->event_on)) . "'>
        </div>
        <div class='input-group'>
            <span>what time its on, enter as hour:minutes</span>
            <input type='text' name='event_time' placeholder='24 hour time please' value='" . date("H:i", strtotime(model->event_on)) . "'>
        </div>
        <div class='input-group'>
            <span>how long for</span>
            <select name='event_length'>
                <option value='1'" . (model->event_length == "1" ? " selected='selected'" : "") . ">1 hour</option>
                <option value='2'" . (model->event_length == "2" ? " selected='selected'" : "") . ">2 hours</option>
                <option value='4'" . (model->event_length == "4" ? " selected='selected'" : "") . ">4 hours</option>
                <option value='all_day'" . (model->event_length == "all_day" ? " selected='selected'" : "") . ">all day</option>
                <option value='daily'" . (model->event_length == "daily" ? " selected='selected'" : "") . ">daily</option>
                <option value='weekly'" . (model->event_length == "weekly" ? " selected='selected'" : "") . ">weekly</option>
                <option value='monthly'" . (model->event_length == "monthly" ? " selected='selected'" : "") . ">monthly</option>
                <option value='annually'" . (model->event_length == "annually" ? " selected='selected'" : "") . ">annually</option>
            </select>
        </div>";
    }

    public function index(string path)
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Events", "events");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the event");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages' class='round icon icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/events/add' class='round icon' title='Add an event'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM pages WHERE type='event' ORDER BY name"),
            "/dumb-dog/events/edit/"
        );

        return html;
    }
}