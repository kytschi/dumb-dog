/**
 * Twig template engine helper
 *
 * @package     DumbDog\Engines\Twig
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Engines;

use DumbDog\Ui\Captcha;

class Twig
{   
    private template_engine;
    public extension = "";

    public function __construct(template_engine)
    {
        let this->template_engine = template_engine;
    }

    public function render(string template, array vars)
    {
        var dumbdog;

        let dumbdog = new \stdClass();
        let dumbdog->page = vars[0];
        let dumbdog->site = vars[1];
        let dumbdog->pages = vars[2];
        let dumbdog->menu = vars[3];
        let dumbdog->captcha = new Captcha();

        echo this->template_engine->render(template, ["DUMBDOG": dumbdog]);
    }
}