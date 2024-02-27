/**
 * Validation exception
 *
 * @package     DumbDog\Exceptions\ValidationException
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

 */
namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class ValidationException extends Exception
{    
	public function __construct(string message, int code = 400)
	{
        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
    }
}
