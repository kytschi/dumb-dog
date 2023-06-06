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

use DumbDog\Controllers\Controller;
use DumbDog\Ui\Gfx\Titles;

class Tiles
{
    public function build(array data, string url = "", string from = "")
    {
        var titles, html;
        
        let html = "<div id='dd-tiles'>";

        if (count(data)) {
            var iLoop, link_url;
            let iLoop = 0;
            while (iLoop < count(data)) {
                let html .= "<div class='dd-tile'>
                    <div class='dd-box dd-wfull";
                if (data[iLoop]->deleted_at) {
                    let html .= " deleted";
                }
                let html .= "'>
                        <div class='dd-box-title'>
                            <span>" . data[iLoop]->name . "</span>
                        </div>
                        <div class='dd-box-body'><div class='dd-thumb'>";
                if (property_exists(data[iLoop], "filename")) {
                    if (data[iLoop]->filename) {
                        let html .= "<img src='/website/files/thumb-" . data[iLoop]->filename . "' alt='" . data[iLoop]->name . "'>";
                        let html .= "<input type='hidden' value='/website/files/" .  data[iLoop]->filename . "'>";
                    }
                }
                let html .= "</div>";
                if (property_exists(data[iLoop], "stock")) {
                    if (data[iLoop]->stock) {
                        let html .= "<span class='dd-product-stock' title='In stock'>" . data[iLoop]->stock . "</span>";
                    }
                }
                if (property_exists(data[iLoop], "price")) {
                    if (data[iLoop]->price) {
                        let html .= "<span class='dd-product-price' title='Product price'>&pound;" . data[iLoop]->price . "</span>";
                    }
                }
                if (property_exists(data[iLoop], "tags")) {
                    if (!empty(data[iLoop]->tags)) {
                        var tag;
                        let html .= "<div class='dd-tags'>";
                        for tag in json_decode(data[iLoop]->tags) {
                            let html .= "<span class='dd-tag'>" . tag->value . "</span>";
                        }
                        let html .= "</div>";
                    }
                }
                let html .= "</div>

                        <div class='dd-box-footer'>";
                if (property_exists(data[iLoop], "default")) {
                    if (data[iLoop]->{"default"}) {
                        let html .= "<span class='dd-default-item'>*default*</span>";
                    }
                }
                if (property_exists(data[iLoop], "url")) {
                    let html .= "<a 
                        href='" . data[iLoop]->url . "' 
                        target='_blank' 
                        class='dd-link dd-round dd-icon dd-icon-web' 
                        title='View me live'>&nbsp;</a>";
                }
                if (property_exists(data[iLoop], "filename")) {
                    if (data[iLoop]->filename) {
                        let html .= "<span 
                            onclick='copyTextToClipboard(\"/website/files/".  data[iLoop]->filename . "\")'
                            class='dd-round dd-icon dd-icon-copy' title='Copy URL to clipboard'>&nbsp;</span>";
                    }
                }
                let link_url = url . data[iLoop]->id;
                if (from) {
                    let link_url .= "?from=" . from;
                }
                let html .="<a href='" . link_url . "' class='dd-link dd-round dd-icon dd-icon-edit' title='Edit me'>&nbsp;</a>
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