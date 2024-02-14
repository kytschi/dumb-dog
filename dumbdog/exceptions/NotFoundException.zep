/**
 * Not Found exception
 *
 * @package     DumbDog\Exceptions\NotFoundException
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
 */
namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class NotFoundException extends Exception
{    
	public function __construct(string message, int code = 404)
	{
        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
    }
}
