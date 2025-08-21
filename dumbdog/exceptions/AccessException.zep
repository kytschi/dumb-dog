/**
 * Access exception
 *
 * @package     DumbDog\Exceptions\AccessException
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 */

namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class AccessException extends Exception
{    
	public function __construct(string message, code = 403, data = null, bool cli = false)
	{
        //Trigger the parent construct.
        parent::__construct(message, code, data, cli);

        let this->code = code;
        let this->cli = cli;
        let this->data = data;
    }
}
