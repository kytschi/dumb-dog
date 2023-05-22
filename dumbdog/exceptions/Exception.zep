/**
 * Generic exception
 *
 * @package     DumbDog\Exceptions\Exception
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
namespace DumbDog\Exceptions;

use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;
use DumbDog\Ui\Gfx\Titles;

class Exception extends \Exception
{
    public code;
    
	public function __construct(string message, int code = 500)
	{
        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
    }

    /**
     * Override the default string to we can have our grumpy cat.
     */
    public function __toString()
    {
        var html, titles, head, javascript;

        let titles = new Titles();
        let head = new Head(new \stdClass());
        let javascript = new Javascript();

        if (headers_sent()) {
            return "<p><strong>DUMB DOG ERROR</strong><br/>" . this->getMessage() . "</p>";
        }

        if (this->code == 404) {
            header("HTTP/1.1 404 Not Found");
        } elseif (this->code == 400) {
            header("HTTP/1.1 400 Bad Request");
        } else {
            header("HTTP/1.1 500 Internal Server Error");
        }

        let html = "<!DOCTYPE html><html lang='en'>" . head->build("error") . "<body id='error' class='error'><div class='background-image'></div><main>";
        let html .= titles->page("bad doggie!", "error");
        let html .= "<div class='box'>
            <div class='box-body'>
                <p>" . this->getMessage() . "</p>
            </div>
            <div class='box-footer'>
                <button type='button' onclick='window.history.back()'>back</button>
            </div>
        </div>";
        let html .= "</main></body>" . javascript->logo() . "</html>";

        return html;
    }

    /**
     * Fatal error just lets us dumb the error out faster and kill the site
     * so we can't go any futher.
     */
    public function fatal(string template = "", int line = 0)
    {
        echo this;
        if (template && line) {
            echo "<p>&nbsp;&nbsp;<strong>Trace</strong><br/>&nbsp;&nbsp;Source <strong>" . str_replace(getcwd(), "", template) . "</strong> at line <strong>" . line . "</strong></p>";
        }
        die();
    }
}
