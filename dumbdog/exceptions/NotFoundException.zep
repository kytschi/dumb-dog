/**
 * Not Found exception
 *
 * @package     DumbDog\Exceptions\NotFoundException
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 */

namespace DumbDog\Exceptions;

use DumbDog\Exceptions\Exception;

class NotFoundException extends Exception
{    
	public function __construct(string message, code = 404, data = null, bool cli = false)
	{
        //Trigger the parent construct.
        parent::__construct(message, code, data, cli);

        let this->code = code;
        let this->cli = cli;
        let this->data = data;
    }
}
