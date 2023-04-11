/**
 * Dumb Dog head builder
 *
 * @package     DumbDog\Ui\Head
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
namespace DumbDog\Ui;

use DumbDog\Ui\Style;

class Head
{
    private cfg;

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function build()
    {
        var html, style;
        let style = new Style(this->cfg);
        let html = style->build();
        return "<head><link rel='icon' type='image/png' sizes='64x64' href='/assets/dumbdog.png'>" . html . "</head>";
    }
}