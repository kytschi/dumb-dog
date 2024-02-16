/**
 * Dumb Dog titles builder
 *
 * @package     DumbDog\Ui\Gfx\Titles
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Ui\Gfx;

use DumbDog\Ui\Gfx\Icons;

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

    public function page(string title, string icon = "")
    {
        var icons;
        let icons = new Icons();

        return "
        <div class='dd-h1 dd-page-title'>
            <div>" .
                (icon ? icons->{icon}() : "") . 
                "<span>" . title . "</span>
            </div>
        </div>";
    }
}