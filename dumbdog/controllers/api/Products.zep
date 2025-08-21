/**
 * DumbDog API for products controller
 *
 * @package     DumbDog\Controllers\Api\Products
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers\Api;

use DumbDog\Controllers\Api\Controller;
use DumbDog\Controllers\Products as Main;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;

class Products extends Controller
{
    public api_routes = [
        "/api/products/add": [
            "Products",
            "add"
        ],
        "/api/products/delete": [
            "Products",
            "delete"
        ],
        "/api/products/edit": [
            "Products",
            "edit"
        ],
        "/api/products/recover": [
            "Products",
            "recover"
        ],
        "/api/products/view": [
            "Products",
            "view"
        ],
        "/api/products": [
            "Products",
            "list"
        ]
    ];

    private query = "";

    public valid_sorts = ["name", "created_at"];

    public function __globals()
    {
        let this->query = "
        SELECT
            content.*,
            products.code,
            products.stock,
            products.on_offer, 
            products.id AS product_id, 
            IF(products.on_offer,product_prices.offer_price,product_prices.price) AS price,
            currencies.symbol,
            currencies.locale_code,
            IFNULL(templates.name, 'No template') AS template, 
            IFNULL(parent_page.name, 'No parent') AS parent 
        FROM content  
        JOIN products ON products.content_id = content.id 
        JOIN templates ON templates.id=content.template_id 
        LEFT JOIN content AS parent_page ON parent_page.id=content.parent_id 
        LEFT JOIN product_prices ON 
            product_prices.id = 
            (
                SELECT id
                FROM product_prices AS pp
                WHERE
                    pp.product_id = products.id AND
                    pp.deleted_at IS NULL 
                LIMIT 1
            )
        LEFT JOIN currencies ON currencies.id = product_prices.currency_id AND currencies.deleted_at IS NULL";
    }
    
    public function add(path)
    {
        var data = [], model = null, status = false, controller;

        this->secure();

        if (!empty(_POST)) {
            let controller = new Main();

            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            }

            let data["id"] = this->database->uuid();
            let data["created_by"] = this->api_app->created_by;
            let data["type"] = "product";

            let data = controller->setData(data, this->api_app->created_by);

            let status = this->database->execute(
                controller->query_insert,
                data
            );

            if (!is_bool(status)) {
                throw new SaveException(
                    "Failed to save the product",
                    400
                );
            } else {
                let model = this->database->get(
                    "SELECT content.* FROM content WHERE id=:id",
                    [
                        "id": data["id"]
                    ]
                );

                controller->updateExtra(model, path, this->api_app->created_by);

                let model = this->database->get(
                    this->query . 
                    " WHERE content.id=:id",
                    [
                        "id": data["id"]
                    ]
                );

                return this->createReturn(
                    "Product successfully created",
                    model
                );
            }
        }

        throw new SaveException(
            "Failed to save the product, no post data",
            400
        );
    }

    public function delete(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        let data["type"] = "product";

        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Product not found");
        }

        controller->triggerDelete("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            this->query . 
            " WHERE content.id=:id",
            [
                "id": data["id"]
            ]
        );

        return this->createReturn(
            "Product successfully marked as deleted",
            model
        );
    }

    public function edit(path)
    {
        var model, data = [], controller, status = false;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        let data["type"] = "product";
        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Product not found");
        }

        if (!empty(_POST)) {
            if (!controller->validate(_POST, controller->required)) {
                throw new ValidationException(
                    "Missing required fields",
                    400,
                    controller->required
                );
            } else {
                let data = controller->setData(data, this->api_app->created_by, model);
                
                let status = this->database->execute(
                    controller->query_update,
                    data
                );
            
                if (!is_bool(status)) {
                    throw new SaveException(
                        "Failed to update the product",
                        400
                    );
                } else {
                    let model = this->database->get(
                        "SELECT content.* FROM content WHERE id=:id",
                        [
                            "id": data["id"]
                        ]
                    );
    
                    controller->updateExtra(model, path, this->api_app->created_by);

                    let model = this->database->get(
                        this->query . 
                        " WHERE content.id=:id",
                        [
                            "id": data["id"]
                        ]
                    );
    
                    return this->createReturn(
                        "Product successfully updated",
                        model
                    );
                }
            }
        }

        throw new SaveException(
            "Failed to update the product, no post data",
            400
        );
    }

    public function list(path)
    {       
        var data = [], query, results, sort_dir = "ASC";

        this->secure();

        let query = this->query;

        if (isset(_GET["query"])) {
            let query .= " AND content.name LIKE :query";
            let data["query"] = "%" . _GET["query"] . "%";
        }

        if (isset(_GET["tag"])) {
            let query .= " AND content.tags LIKE :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }

        if (isset(_GET["sort_dir"])) {
            if (!in_array(strtoupper(_GET["sort_dir"]), this->valid_sort_dir)) {
                throw new ValidationException(
                    "Invalid sort direction",
                    400,
                    this->valid_sort_dir
                );
            }

            let sort_dir = strtoupper(_GET["sort_dir"]);
        }

        if (isset(_GET["sort"])) {
            if (!in_array(strtolower(_GET["sort"]), this->valid_sorts)) {
                throw new ValidationException(
                    "Invalid sort",
                    400,
                    this->valid_sorts
                );
            }

            let query .= " ORDER BY content." . strtolower(_GET["sort"]) . " " . sort_dir;
        } else {
            let query .= " ORDER BY content.name " . sort_dir;
        }        

        let results = this->database->all(query, data);

        return this->createReturn(
            "Products",
            results,
            isset(_GET["query"]) ? _GET["query"] : null
        );
    }

    public function recover(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();

        let data["id"] = controller->getPageId(path);
        let data["type"] = "product";

        let model = this->database->get(
            "SELECT content.* FROM content WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Product not found");
        }

        controller->triggerRecover("content", path, data["id"], this->api_app->created_by, false);

        let model = this->database->get(
            this->query . 
            "WHERE content.id=:id",
            [
                "id": data["id"]
            ]
        );

        return this->createReturn(
            "Product successfully recovered from the deleted state",
            model
        );
    }

    public function view(path)
    {
        var model, data = [], controller;

        this->secure();

        let controller = new Main();
                
        let data["id"] = controller->getPageId(path);
        let data["type"] = "product";
        let model = this->database->get(
            this->query . " WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Product not found");
        }

        let model->prices = this->database->all(
            "SELECT * FROM product_prices WHERE product_id=:id",
            [
                "id": model->product_id
            ]
        );

        return this->createReturn(
            "Product",
            model
        );
    }
}