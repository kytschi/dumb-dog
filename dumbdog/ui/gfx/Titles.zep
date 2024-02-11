/**
 * Dumb Dog titles builder
 *
 * @package     DumbDog\Ui\Gfx\Titles
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
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

class Titles
{
    public function noResults()
    {
        return "
        <div>
            <h2 class='dd-h2 no-results'>
                <span>no results</span>
            </h2>
        </div>";
    }

    public function page(string title, string image = "")
    {
        return "
        <h1 class='dd-h1 dd-page-title'>
            <span" . (image ? " class='dd-icon dd-icon-" . image . "'" : "") . ">" .
                title .
            "</span>
        </h1>";
    }
}