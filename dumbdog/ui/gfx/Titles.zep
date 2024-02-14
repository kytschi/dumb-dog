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