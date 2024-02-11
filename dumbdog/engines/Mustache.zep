/**
 * Mustache template engine helper
 *
 * @package     DumbDog\Engines\Mustache
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
namespace DumbDog\Engines;

use DumbDog\Ui\Captcha;

class Mustache
{   
    private template_engine;
    public extension = "";

    public function __construct(template_engine)
    {
        let this->template_engine = template_engine;
    }

    public function render(string template, array vars)
    {
        var dumbdog, loader;

        let dumbdog = new \stdClass();
        let dumbdog->page = vars[0];
        let dumbdog->site = vars[1];
        let dumbdog->pages = vars[2];
        let dumbdog->menu = vars[3];
        let dumbdog->captcha = new Captcha();

        let loader = this->template_engine->loadTemplate(template);
        echo loader->render(["DUMBDOG": dumbdog]);
    }
}