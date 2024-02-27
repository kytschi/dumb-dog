/**
 * Access exception
 *
 * @package     DumbDog\Exceptions\AccessException
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

 */
namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class AccessException extends Exception
{    
	public function __construct(string message, int code = 403)
	{
        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
    }
}
