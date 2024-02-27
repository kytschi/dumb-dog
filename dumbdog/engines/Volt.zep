/**
 * Volt template engine helper
 *
 * @package     DumbDog\Engines\Volt
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Engines;

class Volt
{   
    private template_engine;
    public extension = "";

    public function __construct(template_engine)
    {
        let this->template_engine = template_engine;
    }

    public function render(string template, array vars)
    {
        this->template_engine->addFilter(
            "replace",
            function (res_args, exp_args) {
                var args, str;
                let args = explode(",", res_args);
                let str = args[0];
                unset(args[0]);
                return "str_replace(" . implode(",", args)  . ", " . str . ")";
            }
        );

        this->template_engine->compile("./website/" . template);
        require this->template_engine->getCompiledTemplatePath();
    }
}