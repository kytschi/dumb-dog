/**
 * DumbDog Api control
 *
 * @package     DumbDog\Controllers\Api\ApiControl
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Api\Appointments;
use DumbDog\Controllers\Api\Blog;
use DumbDog\Controllers\Api\BlogCategories;
use DumbDog\Controllers\Api\ContentStacks;
use DumbDog\Controllers\Api\Countries;
use DumbDog\Controllers\Api\Currencies;
use DumbDog\Controllers\Api\Groups;
use DumbDog\Controllers\Api\Leads;
use DumbDog\Controllers\Api\Menus;
use DumbDog\Controllers\Api\PageCategories;
use DumbDog\Controllers\Api\Pages;
use DumbDog\Controllers\Api\PaymentGateways;
use DumbDog\Controllers\Api\Products;
use DumbDog\Controllers\Api\Reviews;
use DumbDog\Controllers\Api\Socials;
use DumbDog\Controllers\Api\Taxes;
use DumbDog\Controllers\Api\Templates;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\HttpStatus;

class ApiControl extends Controller
{
    public api_routes = [
        "/api/hi": [
            "this",
            "hi"
        ]
    ];

    public controllers = [];

    public function __globals()
    {
        var controller;

        let this->controllers = [
            "this": "this",
            "Appointments": new Appointments(),
            "BlogCategories": new BlogCategories(),
            "Blog": new Blog(),
            "ContentStacks": new ContentStacks(),
            "Countries": new Countries(),
            "Currencies": new Currencies(),
            "Groups": new Groups(),
            "Leads": new Leads(),
            "Menus": new Menus(),
            "PageCategories": new PageCategories(),
            "Pages": new Pages(),
            "PaymentGateways": new PaymentGateways(),
            "Products": new Products(),
            "Reviews": new Reviews(),
            "Socials": new Socials(),
            "Taxes": new Taxes(),
            "Templates": new Templates()
        ];

        for controller in this->controllers {
            if (controller == "this") {
                continue;
            }
            let this->api_routes = array_merge(this->api_routes, controller->api_routes);
        }
    }

    public function hi(path)
    {       
        this->secure();
        return this->createReturn("Hi there");
    }

    public function process(path)
    {
        var url, route, controller, found = false, err;

        try {
            for url, route in this->api_routes {
                if (strpos(path, url) === false) {
                    continue;
                }

                if (!isset(route[0]) && !isset(route[1])) {
                    continue;
                }

                if (!isset(this->controllers[route[0]])) {
                    continue;
                }

                let controller = (route[0] == "this" ? this : this->controllers[route[0]]);
                if (!method_exists(controller, route[1])) {
                    continue;
                }
                
                let found = true;
                call_user_func([controller, route[1]], path);
            }

            if (!found) {
                return this->jsonError(new NotFoundException("Invalid route", 404));
            }
        } catch \Exception, err {
            return this->jsonError(err);
        }
    }
}