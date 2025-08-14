/**
 * Validation exception
 *
 * @package     DumbDog\Exceptions\ValidationException
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *

 */
namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class ValidationException extends Exception
{    
	public function __construct(string message, int code = 400, data = null)
	{
        //Trigger the parent construct.
        parent::__construct(message, code, data);

        let this->code = code;
        let this->data = data;
    }
}
