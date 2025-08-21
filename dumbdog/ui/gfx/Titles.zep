/**
 * Dumb Dog titles builder
 *
 * @package     DumbDog\Ui\Gfx\Titles
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 
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
                "<span>" . title . "</span>
            </div>
        </div>";
    }
}