/**
 * Cfg exception
 *
 * @package     DumbDog\Exceptions\CfgException
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 */

namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class CfgException extends Exception
{    
	public function __construct(string message, code = 500, data = null, bool cli = false)
	{
        //Trigger the parent construct.
        parent::__construct(message, code, data, cli);

        let this->code = code;
        let this->cli = cli;
        let this->data = data;
    }
}
