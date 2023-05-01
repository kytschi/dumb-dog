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

use DumbDog\Ui\Gfx\Titles;

class Table
{
    public function build(array columns, array data, string url = "")
    {
        var titles, html;
        
        let html = "<div id='table'>";
        if (count(data)) {
            var iLoop, iLoop_head, key;
            let iLoop_head = 0;
            let html .= "<table class='table wfull'><thead><tr>";
            while (iLoop_head < count(columns)) {
                let html .= "<th>" . columns[iLoop_head] . "</th>";
                let iLoop_head = iLoop_head + 1;
            }
            let html .= "<th width='120px'>&nbsp;</th></tr></thead><tbody>";
            let iLoop = 0;
            while (iLoop < count(data)) {
                let html .= "<tr";
                if (data[iLoop]->deleted_at) {
                    let html .= " class='deleted'";
                }
                let html .= ">";

                let iLoop_head = 0;
                while (iLoop_head < count(columns)) {
                    let key = columns[iLoop_head];
                    let html .= "<td>" . data[iLoop]->{key} . "</td>";
                    let iLoop_head = iLoop_head + 1;
                }

                let html .= "<td><a href='" . url . data[iLoop]->id . "' class='round' title='edit me'><img src='/assets/edit-page.png' alt='edit'></a></td>";

                let html .= "</tr>";
                let iLoop = iLoop + 1;
            }
            let html .= "</tbody></table>";
        } else {
            let titles = new Titles();
            let html = html . titles->noResults();
        }
        return html . "</div>";
    }
}