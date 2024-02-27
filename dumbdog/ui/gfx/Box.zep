/**
 * Dumb Dog box builder
 *
 * @package     DumbDog\Ui\Gfx\Box
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Ui\Gfx;

class Box
{
    public function build(string title)
    {
        return "<div class='dd-box'>
            <div class='dd-box-title'><span>" . title . "</span></div>
            <div class='dd-box-body'></div>
        </div>";
    }
}