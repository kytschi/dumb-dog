/**
 * Dumb Dog tiles builder
 *
 * @package     DumbDog\Ui\Gfx\Tiles
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

use DumbDog\Ui\Gfx\Titles;

class Tiles
{
    public function build(array data, string url = "")
    {
        var titles, html;
        
        let html = "<div id='tiles'>";
        if (count(data)) {
            var iLoop;
            let iLoop = 0;
            while (iLoop < count(data)) {
                let html .= "<div class='tile'>
                    <div class='box wfull";
                if (data[iLoop]->deleted_at) {
                    let html .= " deleted";
                }
                let html .= "'>
                        <div class='box-title'>
                            <span>" . data[iLoop]->name . "</span>
                        </div>
                        <div class='box-body'>
                        </div>
                        <div class='box-footer'>";
                if (property_exists(data[iLoop], "default")) {
                    if (data[iLoop]->{"default"}) {
                        let html .= "<span class='default-item'>*default*</span>";
                    }
                }
                if (property_exists(data[iLoop], "url")) {
                    let html .= "<a href='" . data[iLoop]->url . "' target='_blank' class='round' title='View me live'><img src='/assets/web.png'></a>";
                }
                let html .="<a href='" . url . data[iLoop]->id . "' class='round' title='edit the page'><img src='/assets/edit-page.png' alt='edit'></a>
                        </div>
                    </div>
                </div>";
                let iLoop = iLoop + 1;
            }
        } else {
            let titles = new Titles();
            let html = html . titles->noResults();
        }
        return html . "</div>";
    }
}