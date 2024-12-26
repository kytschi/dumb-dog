/**
 * DumbDog products
 *
 * @package     DumbDog\Controllers\Products
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\ValidationException;

class Products extends Content
{
    public global_url = "/products";
    public type = "product";
    public title = "Products";
    public back_url = "";
    public category = "product-category";
    public list = [
        "name|with_tags",
        "code",
        "parent",
        "status"
    ];

    private valid_columns = [
        "url",
        "name",
        "status",
        "meta_keywords",
        "meta_author",
        "meta_description",
        "price",
        "stock",
        "code",
        "created_at",
        "updated_at"
    ];

    private valid_dir = [
        "ASC",
        "DESC"
    ];

    private function createPrice(id)
    {
        var data = [
            "product_id": id,
            "created_by": this->getUserId(),
            "updated_by": this->getUserId()
        ], status;

        let data["name"] = _POST["create_price"];
        
        let status = this->database->execute(
            "INSERT INTO product_prices 
                (id,
                product_id,
                name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :product_id,
                :name,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to save the product price");
        }
    }

    private function createShipping(id)
    {
        var data = [
            "product_id": id,
            "created_by": this->getUserId(),
            "updated_by": this->getUserId()
        ], status;

        let data["name"] = _POST["create_shipping"];
        
        let status = this->database->execute(
            "INSERT INTO product_shipping 
                (id,
                product_id,
                name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :product_id,
                :name,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to save the product shipping");
        }
    }

    private function countriesSelect(selected)
    {
        var select = [], data;
        let data = this->database->all("
            SELECT * FROM countries 
            ORDER BY is_default DESC, name");
        var iLoop = 0;

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            if (data[iLoop]->is_default && empty(selected)) {
                let selected = data[iLoop]->id;
            }
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Country",
            "country_id[]",
            "The country",
            select,
            true,
            selected
        );
    }

    private function currenciesSelect(selected)
    {
        var select = [], data;
        let data = this->database->all("
            SELECT * FROM currencies 
            ORDER BY is_default DESC, name");
        var iLoop = 0;

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            if (data[iLoop]->is_default && empty(selected)) {
                let selected = data[iLoop]->id;
            }
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Currency",
            "currency_id[]",
            "The currency",
            select,
            true,
            selected
        );
    }

    /**
    * I'm used by the helper for the frontend.
    */
    public function get(array filters = [])
    {
        var query, where, join, data = [], order = "", item, item_sub, key, currency_id = "";
                
        let query = "
            SELECT
                content.*,
                templates.file AS template,
                products.stock,
                products.code,
                products.on_offer,
                IF(products.on_offer,product_prices.offer_price,product_prices.price) AS price,
                currencies.symbol,
                currencies.locale_code 
            FROM content ";

        let join = "JOIN templates ON templates.id=content.template_id 
        JOIN products ON products.content_id = content.id
        LEFT JOIN product_prices ON 
            product_prices.id = 
            (
                SELECT id
                FROM product_prices AS pp
                WHERE
                    pp.product_id = products.id AND
                    pp.deleted_at IS NULL AND
                    pp.currency_id=:currency_id
                LIMIT 1
            )
        LEFT JOIN currencies ON currencies.id = product_prices.currency_id AND currencies.deleted_at IS NULL";

        let where = " WHERE content.status='live' AND content.deleted_at IS NULL AND content.type = 'product'";
        
        let currency_id = this->session("currency");
        if (empty(currency_id)) {
            let item_sub = this->database->get("SELECT currencies.id FROM currencies WHERE is_default=1");
            if (!empty(item_sub)) {
                let currency_id = item_sub->id;
                this->session("currency", currency_id);
            }
        }
        let data["currency_id"] = currency_id;

        if (count(filters)) {
            for key, item in filters {
                switch (key) {
                    case "children":
                        let where .= " AND parent_id=:parent_id";
                        let data["parent_id"] = item;
                        break;
                    case "random":
                        let order .= " ORDER BY RAND() LIMIT " . intval(item);
                        break;
                    case "order":
                        var splits, check, id = 0;
                        let splits = explode(" ", item);
                        let check = reset(splits);
                        if (in_array(check, this->valid_columns)) {
                            let order = " ORDER BY ". check;
                            let id = count(splits);
                            let id -= 1;
                            let check = splits[id];
                            if (in_array(strtoupper(check), this->valid_dir)) {
                                let order .= " ". check;
                            }
                        }
                        break;
                    case "tag":
                        let where .= " AND tags like :tag";
                        let data["tag"] = "%{\"value\":\"" . item . "\"}%";
                        break;
                    case "where":
                        if (isset(item["query"])) {
                            let where .= " AND " . item["query"];
                        }
                        if (isset(item["data"])) {
                            if (isset(item["data"]["country_id"])) {
                                let join .= " LEFT JOIN 
                                    product_shipping ON product_shipping.product_id = products.id AND 
                                        product_shipping.deleted_at IS NULL AND 
                                        product_shipping.status = 'active'";
                            }
                            let data = array_merge(data, item["data"]);
                        }
                        break;
                    default:
                        continue;
                }
            }
        }
        
        let data = this->database->all(query . join . where . order, data);

        for item in data {
            let item->stacks = this->database->all("
                SELECT *
                FROM content_stacks
                WHERE content_id='" . item->id . "' AND deleted_at IS NULL AND content_stack_id IS NULL");
            for item_sub in item->stacks {
                let item_sub->stacks = this->database->all("
                SELECT *
                FROM content_stacks
                WHERE content_stack_id='" . item_sub->id . "' AND deleted_at IS NULL");                
            }

            let item->parent = this->database->get("
                SELECT
                    content.*,
                    IF(banner.filename IS NOT NULL, CONCAT('" . this->files->folder . "', banner.filename), '') AS banner_image,
                    IF(banner.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', banner.filename), '') AS banner_thumbnail,
                    templates.file AS template 
                FROM content
                LEFT JOIN files AS banner ON banner.resource_id = content.id AND resource='banner-image'
                JOIN templates ON templates.id=content.template_id 
                WHERE 
                    content.id=:id AND 
                    content.status='live' AND 
                    content.public_facing=1 AND 
                    content.deleted_at IS NULL",
                [
                    "id": item->parent_id
                ]
            );

            let item->images = this->database->all(
                "SELECT 
                    IF(filename IS NOT NULL, CONCAT('" . this->files->folder . "', filename), '') AS image,
                    IF(filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', filename), '') AS thumbnail 
                FROM files 
                WHERE resource_id=:resource_id AND resource='content-image' AND deleted_at IS NULL AND visible=1
                ORDER BY sort ASC",
                [
                    "resource_id": item->id
                ]
            );
        }

        return data;
    }

    public function renderExtra(model, mode = "add")
    {
        var data, item, html;
        
        let model->price = 0;

        if (model->id) {
            let data = this->database->get("
                SELECT *
                FROM products 
                WHERE content_id='" . model->id . "'");

            if (!empty(data)) {
                let model->price = data->price;
                let model->on_offer = data->on_offer;
                let model->stock = data->stock;
                let model->code = data->code;

                let model->prices = this->database->all("
                    SELECT product_prices.* 
                    FROM product_prices 
                    WHERE product_id='" . data->id . "' AND deleted_at IS NULL");

                let model->shipping = this->database->all("
                    SELECT product_shipping.* 
                    FROM product_shipping 
                    WHERE product_id='" . data->id . "' AND deleted_at IS NULL");
            }
        }

        let html = "
        <div id='product-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title'>Product</div>
                    <div class='dd-box-body'>" .
                        this->inputs->toggle("On offer", "on_offer", false, model->on_offer) . 
                        this->inputs->text("Code", "code", "The product code", true, model->code) .
                        this->inputs->number("Stock", "stock", "The stock", true, model->stock) .
                    "</div>
                </div>
            </div>
        </div>";
        if (mode == "edit") {
            let html .= "
            <div class='dd-row'>
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title dd-flex dd-border-none'>
                            <div class='dd-col'>Prices</div>
                            <div class='dd-col-auto'>" . 
                                this->inputs->inputPopup("create-price", "create_price", "Create a new price") .
                            "</div>
                        </div>
                    </div>";
                    if (count(model->prices)) {
                        for item in model->prices {
                            let html .= "
                            <div class='dd-box'>
                                <div class='dd-box-title dd-flex'>
                                    <div class='dd-col'>" . item->name . "</div>
                                    <div class='dd-col-auto'>" .
                                        this->buttons->delete(
                                            item->id, 
                                            "delete-price-" . item->id,
                                            "delete_price[]",
                                            ""
                                        ) .
                                "   </div>
                                </div>
                                <div class='dd-box-body'>" .
                                    this->inputs->text("Name", "price_name[]", "The price name", true, item->name) .
                                    this->currenciesSelect(item->currency_id) . 
                                    this->taxesSelect(item->tax_id) . 
                                    this->inputs->text("Price", "price[]", "The price", true, item->price) .
                                    this->inputs->text("Offer price", "offer_price[]", "The offer price", false, item->offer_price) .
                                    this->inputs->hidden("price_id[]", item->id) . 
                            "   </div>
                            </div>";
                        }
                    }
            let html .= "
                </div>
            </div>
            <div id='shipping-tab' class='dd-row'>
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title dd-flex dd-border-none'>
                            <div class='dd-col'>Shipping</div>
                            <div class='dd-col-auto'>" . 
                                this->inputs->inputPopup("create-shipping", "create_shipping", "Create a new shipping location") .
                        "   </div>
                        </div>
                    </div>";
                    if (count(model->shipping)) {
                        for item in model->shipping {
                            let html .= "
                            <div class='dd-box'>
                                <div class='dd-box-title dd-flex'>
                                    <div class='dd-col'>" . item->name . "</div>
                                    <div class='dd-col-auto'>" .
                                        this->buttons->delete(
                                            item->id,
                                            "delete-shpping-" . item->id,
                                            "delete_shpping[]",
                                            ""
                                        ) .
                                "   </div>
                                </div>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Active", "shipping_status[]", false, (item->status == "active" ? 1 : 0)) . 
                                    this->inputs->text("Name", "shipping_name[]", "The shpping name", true, item->name) .
                                    this->countriesSelect(item->country_id) . 
                                    this->inputs->text("Price", "shipping_price[]", "The shipping price", false, item->price) .
                                    this->inputs->hidden("shipping_id[]", item->id) . 
                            "   </div>
                            </div>";
                        }
                    }
            let html .= "
                </div>
            </div>";
        }

        return html;
    }

    public function renderExtraMenu(mode = "add")
    {
        var html;
        
        let html = "<li class='dd-nav-item' role='presentation'>
            <div class='dd-nav-link dd-flex'>
                <span 
                    data-tab='#product-tab'
                    class='dd-tab-link dd-col'
                    role='tab'
                    aria-controls='product-tab' 
                    aria-selected='true'>" .
                    this->buttons->tab("product-tab") .
                    "Product
                </span>
            </div>
        </li>";

        if (mode == "edit") {
            let html .= "
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#shipping-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='shipping-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("shipping-tab") .
                        "Shipping
                    </span>
                </div>
            </li>";
        }

        return html;
    }

    public function renderList(string path)
    {
        var data = [], query;

        let query = "
            SELECT
                main_page.*,
                products.code,    
                IFNULL(parent_page.name, 'No parent') AS parent
            FROM content AS main_page 
            LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id 
            LEFT JOIN products ON products.content_id=main_page.id  
            WHERE main_page.type='" . this->type . "'";
        if (isset(_POST["q"])) {
            let query .= " AND main_page.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND main_page.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY main_page.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    private function taxesSelect(selected)
    {
        var select = [], data;
        
        let data = this->database->all("
            SELECT * FROM taxes 
            ORDER BY is_default DESC, name");
        var iLoop = 0;

        let select = ["": "None"];
        if (is_null(selected)) {
            let selected = "";
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Tax rate",
            "tax_id[]",
            "The tax rate",
            select,
            false,
            selected
        );
    }

    public function updateExtra(model, path)
    {
        var data, status = false, required = ["code"];

        let data = this->database->get("SELECT * FROM products WHERE content_id=:id", ["id":model->id]);

        if (!empty(data)) {
            if (!this->validate(_POST, required)) {
                throw new ValidationException("Missing required data");
            }

            let status = this->database->get("
                UPDATE products SET
                    stock=:stock,
                    code=:code,
                    on_offer=:on_offer 
                WHERE id=:id",
                [
                    "id": data->id,
                    "stock": intval(_POST["stock"]),
                    "code": _POST["code"],
                    "on_offer": isset(_POST["on_offer"]) ? 1 : 0
                ]
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to update the product");
            }

            if (isset(_POST["create_price"])) {
                if (!empty(_POST["create_price"])) {
                    this->createPrice(data->id);
                    let path = path . "&scroll=product-tab";
                }
            }
            
            if (isset(_POST["delete_price"])) {
                if (!empty(_POST["delete_price"])) {
                    this->triggerDelete("product_prices", path, reset(_POST["delete_price"]));
                }
            }

            if (isset(_POST["create_shipping"])) {
                if (!empty(_POST["create_shipping"])) {
                    this->createShipping(data->id);
                    let path = path . "&scroll=shipping-tab";
                }
            }
            
            if (isset(_POST["delete_shipping"])) {
                if (!empty(_POST["delete_shipping"])) {
                    this->triggerDelete("product_shipping", path, reset(_POST["delete_shipping"]));
                }
            }

            this->updatePrices();
            this->updateShipping();
        } else {
            let status = this->database->get("
                INSERT INTO products 
                (
                    id,
                    content_id,
                    code,
                    stock,
                    on_offer
                ) VALUES
                (
                    UUID(),
                    :content_id,
                    :code,
                    :stock,
                    :on_offer
                )",
                [
                    "content_id": model->id,
                    "code": _POST["code"],
                    "stock": intval(_POST["stock"]),
                    "on_offer": isset(_POST["on_offer"]) ? 1 : 0
                ]
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to create the product");
            }
        }

        return path;
    }

    private function updatePrices()
    {
        if (!isset(_POST["price_id"])) {
            return;
        }

        var key, id, status, data = [];
        for key, id in _POST["price_id"] {
            let data = [
                "id": id,
                "name": "",
                "price": 0.00,
                "offer_price": 0.00
            ];

            if (!isset(_POST["price_name"][key])) {
                throw new ValidationException("Missing name for the price");
            } elseif (empty(_POST["price_name"][key])) {
                throw new ValidationException("Missing name for the price");
            }

            if (!isset(_POST["currency_id"][key])) {
                throw new ValidationException("Missing currency for the price");
            } elseif (empty(_POST["currency_id"][key])) {
                throw new ValidationException("Missing currency for the price");
            }

            if (!isset(_POST["price"][key])) {
                throw new ValidationException("Missing price");
            } elseif (empty(_POST["price"][key]) && floatval(_POST["price"][key]) != 0.00) {
                throw new ValidationException("Missing price");
            }

            let data["currency_id"] = _POST["currency_id"][key];
            let data["tax_id"] = isset(_POST["tax_id"][key]) ? _POST["tax_id"][key] : null;
            let data["name"] = _POST["price_name"][key];
            let data["price"] = floatval(_POST["price"][key]);
            if (isset(_POST["offer_price"][key])) {
                if (!empty(_POST["offer_price"][key])) {
                    let data["offer_price"] = floatval(_POST["offer_price"][key]);
                }
            }
            
            let status = this->database->execute(
                "UPDATE product_prices SET 
                    name=:name,
                    price=:price,
                    offer_price=:offer_price,
                    currency_id=:currency_id,
                    tax_id=:tax_id 
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the price");
            }
        }
    }

    private function updateShipping()
    {
        if (!isset(_POST["shipping_id"])) {
            return;
        }

        var key, id, status, data = [];
        for key, id in _POST["shipping_id"] {
            let data = [
                "id": id,
                "name": "",
                "price": 0.00,
                "status": "active"
            ];

            if (!isset(_POST["shipping_name"][key])) {
                throw new ValidationException("Missing name for the shipping");
            } elseif (empty(_POST["shipping_name"][key])) {
                throw new ValidationException("Missing name for the shipping");
            }

            if (!isset(_POST["country_id"][key])) {
                throw new ValidationException("Missing currency for the shipping");
            } elseif (empty(_POST["country_id"][key])) {
                throw new ValidationException("Missing currency for the shipping");
            }

            let data["status"] = isset(_POST["shipping_status"][key]) ? "active" : "inactive";
            let data["name"] = _POST["shipping_name"][key];
            let data["price"] = floatval(_POST["shipping_price"][key]);
            let data["country_id"] = _POST["country_id"][key];
                        
            let status = this->database->execute(
                "UPDATE product_shipping SET 
                    status=:status,
                    name=:name,
                    price=:price,
                    country_id=:country_id
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the shipping");
            }
        }
    }
}