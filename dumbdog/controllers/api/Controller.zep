/**
 * DumbDog Api controller
 *
 * @package     DumbDog\Controllers\Api\Controller
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Database;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\HttpStatus;

class Controller
{
    public api_app;
    protected cfg;
    protected libs;
    public database;

    public valid_sorts = [];
    public valid_sort_dir = ["ASC", "DESC"];

    public pagination_per_page = 30;
    public pagination_page = 1;

    public function __construct()
    {
        let this->cfg = constant("CFG");
        let this->libs = constant("LIBS");
        let this->database = new Database();

        if (isset(_GET["per_page"])) {
            let this->pagination_per_page = intval(_GET["per_page"]);
            if (this->pagination_per_page <= 0) {
                let this->pagination_per_page = 30;
            }
        }
        if (isset(_GET["page"])) {
            let this->pagination_page = intval(_GET["page"]);
            if (this->pagination_page <= 0) {
                let this->pagination_page = 1;
            }
        }

        this->__globals();
    }

    public function __globals()
    {
        //Nothing.
    }

    public function createReturn(message, data = null, query = null, code = 200)
    {
        var obj, pagination, pages = 1, check, offset = 0, err;

        try {
            let obj = new \stdClass();

            let obj->copyright = "(c)" . date("Y") . " Mike Welsh";
            let obj->website = "https://dumb-dog.kytschi.com";
            let obj->code = code;
            let obj->message = message;
            let obj->query = query;

            if (is_array(data)) {
                let pages = intval(count(data) / this->pagination_per_page);
                if (pages < 1) {
                    let pages = 1;
                }
            
                let check = pages * this->pagination_per_page;
                if (check < count(data)) {
                    let pages = pages + 1;
                }
            }

            let pagination = new \stdClass();
            let pagination->per_page = this->pagination_per_page;
            let pagination->total = is_array(data) ? count(data) : 1;
            let pagination->page_first = 1;
            let pagination->page_previous = (this->pagination_page - 1);
            if (pagination->page_previous < 1) {
                let pagination->page_previous = 1;
            }
            let pagination->page_next = (this->pagination_page + 1);
            if (pagination->page_next > pages) {
                let pagination->page_next = pages;
            }
            let pagination->page_last = pages;
            let pagination->pages = pages;

            let obj->pagination = pagination;

            let offset = (this->pagination_page - 1) * this->pagination_per_page;

            if (is_array(data)) {
                let obj->data = array_slice(
                    data,
                    offset,
                    this->pagination_per_page
                );
            } else {
                let obj->data = data;
            }

            return this->outputJson(obj, code);
        } catch \Exception, err {
            return this->jsonError(err);
        }
    }

    public function jsonError(err)
    {
        this->createReturn(
            err->getMessage(),
            method_exists(err, "getData") ? err->getData() : null,
            null,
            err->getCode()
        );
    }

    public function outputJson(data, code = 200)
    {
        (new HttpStatus())->setHttpStatus(code);

        header("Content-Type: application/json; charset=UTF-8");
        echo \json_encode(data);
        die();
    }

    /**
     * Check to see if the API call can be accessed based on the API App key given in the header.
     *
     * @return bool
     *
     * @throws DumbDog\Exceptions\AccessException
     * @throws DumbDog\Exceptions\SaveException
     */
    public function secure()
    {
        var key, status;

        if (!isset(_SERVER["HTTP_AUTHORIZATION"])) {
            this->jsonError(new AccessException("Invalid API key"));
        }

        let key = str_replace(
            ["BASIC ", "Basic ", "basic"],
            "",
            _SERVER["HTTP_AUTHORIZATION"]
        );

        if (empty(key)) {
            this->jsonError(new AccessException("Invalid API key"));
        }

        let this->api_app = this->database->get(
            "SELECT * FROM api_apps WHERE api_key=:key AND deleted_at IS NULL",
            ["key": key]
        );

        if (empty(this->api_app)) {
            this->jsonError(new AccessException("Invalid API key"));
        }

        if (this->api_app->status != "active") {
            this->jsonError(new AccessException("Invalid API key, your key is currently not active."));
        }

        let status = this->database->execute(
            "UPDATE api_apps SET 
                last_used_at=NOW()
            WHERE id=:id",
            ["id": this->api_app->id]
        );
    
        if (!is_bool(status)) {
            this->jsonError(new SaveException("Failed to update the API app"));
        }

        return true;
    }
}