/**
 * Save exception
 *
 * @package     DumbDog\Exceptions\SaveException
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
 */
namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class SaveException extends Exception
{    
	public function __construct(string message, int code = 400)
	{
        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
    }
}
