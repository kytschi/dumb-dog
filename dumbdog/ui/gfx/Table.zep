/**
 * Dumb Dog table builder
 *
 * @package     DumbDog\Ui\Gfx\Table
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
namespace DumbDog\Ui\Gfx;

use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Titles;

class Table
{
    private cfg;

    public function __construct(object cfg)
    {
        let this->cfg = cfg;
    }

    public function build(array columns, array data, string url = "", string from = "")
    {
        var titles, html;
        
        let html = "<div id='dd-table'>";
        if (count(data)) {
            var iLoop, iLoop_head, key, splits, security, with_tags;
            let security = new Security(this->cfg);
            let iLoop_head = 0;
            let html .= "<table class='dd-table dd-wfull'><thead><tr>";
            while (iLoop_head < count(columns)) {
                let splits = explode("|", columns[iLoop_head]);
                let html .= "<th>" . str_replace("_", " ", splits[0]) . "</th>";
                let iLoop_head = iLoop_head + 1;
            }
            let html .= "<th class='dd-tools'>Tools</th></tr></thead><tbody>";
            let iLoop = 0;
            while (iLoop < count(data)) {
                let html .= "<tr";
                if (data[iLoop]->deleted_at) {
                    let html .= " class='dd-deleted'";
                }
                let html .= ">";

                let iLoop_head = 0;
                while (iLoop_head < count(columns)) {
                    let with_tags = false;
                    let splits = explode("|", columns[iLoop_head]);
                    let key = splits[0];
                    let key = data[iLoop]->{key};

                    if (isset(splits[1])) {
                        switch(splits[1]) {
                            case "bool":
                                let key = (key) ? "Yes": "No";
                                break;
                            case "date":
                                let key = date("d/m/Y", strtotime(key));
                                break;
                            case "decrypt":
                                let key = security->decrypt(key);
                                break;
                            case "event_date":
                                let key = this->eventDate(data[iLoop]->event_length, key);
                                break;
                            case "with_tags":
                                let with_tags = true;
                                break;
                        }
                    }
                    
                    let html .= "<td>" . key;
                    if (property_exists(data[iLoop], "tags") && with_tags) {
                        if (!empty(data[iLoop]->tags)) {
                            var tag;
                            let html .= "<p class='dd-tags'>";
                            for tag in json_decode(data[iLoop]->tags) {
                                let html .= "<a href='" . url . "?tag=" . urlencode(tag->value) . "' class='dd-link dd-tag'>" . tag->value . "</a>";
                            }
                            let html .= "</p>";
                        }
                    }
                    let html .= "</td>";
                    let iLoop_head = iLoop_head + 1;
                }

                let html .= "<td class='dd-tools'>";
                let html .= "<a  href='" . url . "/edit/" . data[iLoop]->id . "'
                        class='dd-link dd-mini dd-icon dd-icon-edit'
                        title='Edit me'>&nbsp;</a>";
                if (property_exists(data[iLoop], "url")) {
                    let html .= "<a  href='" . data[iLoop]->url . "' target='_blank' 
                        class='dd-link dd-mini dd-icon dd-icon-web'
                        title='View me live'>&nbsp;</a>";
                }
                let html .= "</td></tr>";

                

                let iLoop = iLoop + 1;
            }
            let html .= "</tbody></table>";
        } else {
            let titles = new Titles();
            let html = html . titles->noResults();
        }
        return html . "</div>";
    }

    private function eventDate(event_length, key)
    {
        switch (event_length) {
            case "all_day":
                let key = date("l jS F", strtotime(key));
                break;
            case "weekly":
                let key = "Every " . date("l", strtotime(key)) .
                    " &#64;" . date("H:i", strtotime(key));
                break;
        }

        return key;
    }
}