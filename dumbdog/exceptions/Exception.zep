/**
 * Generic exception
 *
 * @package     DumbDog\Exceptions\Exception
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 */

namespace DumbDog\Exceptions;

use DumbDog\Helper\HttpStatus;
use DumbDog\Ui\Head;
use DumbDog\Ui\Javascript;
use DumbDog\Ui\Gfx\Titles;

class Exception extends \Exception
{
    public code;
    public cli;
    public data = null;
    
	public function __construct(string message, code = 500, data = null, bool cli = false)
	{
        if (is_string(code) || code == 0) {
            let code = 500;
        }

        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
        let this->cli = cli;
        let this->data = data;
    }

    public function getData()
    {
        return this->data;
    }
    
    /**
     * Override the default string to we can have our grumpy cat.
     */
    public function __toString()
    {
        var html, titles, head, javascript;

        let titles = new Titles();
        let head = new Head();
        let javascript = new Javascript();

        if (this->cli) {
            return "ERROR: " . this->getMessage();
        }

        if (headers_sent()) {
            return "<p><strong>DUMB DOG ERROR</strong><br/>" . this->getMessage() . "</p>";
        }

        (new HttpStatus())->setHttpStatus(this->code);

        let html = "<!DOCTYPE html><html lang='en'>" . head->build("error") .
            "<body id='dd-error' class='dd-error'>
                <div class='dd-background-image'></div>
                <main class='dd-main'>";
        let html .= titles->page("bad doggie!", "error");
        let html .= "<div class='dd-box'>
            <div class='dd-box-body'>
                <p>" . this->getMessage() . "</p>
            </div>
            <div class='dd-box-footer'>
                <a class='dd-button'";
        if (isset(_GET["back"])) {
            var from;
            if (isset(_GET["from"])) {
                let from = "?from=" . _GET["from"];
            }
            let html .= " href='" . urldecode(_GET["back"]) . from . "'";
        } else {
            let html .= " onclick='window.history.back()'";
        }
        let html .= ">back</a>
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
