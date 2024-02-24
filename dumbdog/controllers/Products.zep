/**
 * DumbDog products builder
 *
 * @package     DumbDog\Controllers\Products
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Input;
use DumbDog\Ui\Gfx\Table;

class Products extends Content
{
    public global_url = "/DumbDog/products";
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
        "type",
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
        var select = [], data, input;
        let input = new Input();
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

        return input->select(
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
        var select = [], data, input;
        let input = new Input();
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

        return input->select(
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
        var query, where, join, data = [], order = "", item, item_sub, key, files;
        let files = new Files();
        
        let query = "
        SELECT
            content.*,
            IF(banner.filename IS NOT NULL, CONCAT('" . files->folder . "', banner.filename), '') AS banner_image,
            IF(banner.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', banner.filename), '') AS banner_thumbnail,
            templates.file AS template,
            products.stock,
            products.code,
            products.on_offer,
            IF(products.on_offer,product_prices.offer_price,product_prices.price) AS price,
            currencies.symbol,
            currencies.locale_code 
        FROM content ";

        let join = "LEFT JOIN files AS banner ON banner.resource_id = content.id AND resource='banner-image'
        JOIN templates ON templates.id=content.template_id 
        JOIN products ON products.content_id = content.id
        JOIN product_prices ON 
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
        JOIN currencies ON currencies.id = product_prices.currency_id AND currencies.deleted_at IS NULL";

        let where = " WHERE content.status='live' AND content.deleted_at IS NULL AND content.type = 'product'";
        
        let item = this->session("currency");
        if (empty(item)) {
            let item_sub = this->database->get("SELECT currencies.id FROM currencies WHERE is_default=1");
            if (!empty(item_sub)) {
                let item = item_sub->id;
                this->session("currency", item);
            }
        }
        let data["currency_id"] = item;

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
        }

        return data;
    }

    public function renderExtra(model)
    {
        var input, data, item, button, html;
        let input = new Input();
        let button = new Button();

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
        <div id='product-tab' class='row'>
            <div class='col-12'>
                <article class='card'>
                    <header>Product</header>
                    <div class='card-body'>" .
                        input->toggle("On offer", "on_offer", false, model->on_offer) . 
                        input->text("Code", "code", "The product code", true, model->code) .
                        input->number("Stock", "stock", "The stock", true, model->stock) .
                    "</div>
                </article>
            </div>
            <div class='col-12'>
                <article class='card'>
                    <header>
                        <span>Prices</span>" . 
                        input->inputPopup("create-price", "create_price", "Create a new price") .
                    "</header>
                    <div class='card-body'>";
                    if (count(model->prices)) {
                        let html .= "<div class='stacks'>";
                        for item in model->prices {
                            let html .= "
                            <div class='stack'>
                                <div class='stack-header'>
                                    <h3>" . item->name . "</h3>" .
                                    button->delete(item->id, "delete-price-" . item->id, "delete_price[]") .
                                "</div>
                                <div class='stack-body'>" .
                                input->text("Name", "price_name[]", "The price name", true, item->name) .
                                this->currenciesSelect(item->currency_id) . 
                                this->taxesSelect(item->tax_id) . 
                                input->text("Price", "price[]", "The price", true, item->price) .
                                input->text("Offer price", "offer_price[]", "The offer price", false, item->offer_price) .
                                input->hidden("price_id[]", item->id) . 
                            "   </div>
                            </div>";
                        }
                        let html .= "</div>";
                    }
        let html .= "</div>
                </article>
            </div>
        </div>
        <div id='shipping-tab' class='row'>
            <div class='col-12'>
                <article class='card'>
                    <header>
                        <span>Shipping</span>" . 
                        input->inputPopup("create-shipping", "create_shipping", "Create a new shipping location") .
                    "</header>
                    <div class='card-body'>";
                    if (count(model->shipping)) {
                        let html .= "<div class='stacks'>";
                        for item in model->shipping {
                            let html .= "
                            <div class='stack'>
                                <div class='stack-header'>
                                    <h3>" . item->name . "</h3>" .
                                    button->delete(item->id, "delete-shpping-" . item->id, "delete_shpping[]") .
                                "</div>
                                <div class='stack-body'>" .
                                input->toggle("Active", "shipping_status[]", false, (item->status == "active" ? 1 : 0)) . 
                                input->text("Name", "shipping_name[]", "The shpping name", true, item->name) .
                                this->countriesSelect(item->country_id) . 
                                input->text("Price", "shipping_price[]", "The shipping price", false, item->price) .
                                input->hidden("shipping_id[]", item->id) . 
                            "   </div>
                            </div>";
                        }
                        let html .= "</div>";
                    }
        let html .= "</div>
                </article>
            </div>
        </div>";

        return html;
    }

    public function renderExtraMenu()
    {
        return "<li class='nav-item' role='presentation'>
            <button
                data-tab='#product-tab'
                class='nav-link'
                type='button'
                role='tab'
                aria-controls='product-tab' data
                aria-selected='true'>Product</button>
        </li>
        <li class='nav-item' role='presentation'>
            <button
                data-tab='#shipping-tab'
                class='nav-link'
                type='button'
                role='tab'
                aria-controls='shipping-tab' data
                aria-selected='true'>Shipping</button>
        </li>";
    }

    public function renderList(string path)
    {
        var data, query, table;

        let table = new Table();

        let data = [];
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

        return table->build(
            this->list,
            this->database->all(query, data),
            "/DumbDog/" . ltrim(path, "/")
        );
    }

    private function taxesSelect(selected)
    {
        var select = [], data, input;
        let input = new Input();
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

        return input->select(
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
        var data, status = false;

        let data = this->database->get("
            SELECT *
            FROM products 
            WHERE content_id='" . model->id . "'");

        if (!empty(data)) {
            if (!isset(_POST["code"])) {
                throw new ValidationException("Missing product code");
            } elseif (empty(_POST["code"])) {
                throw new ValidationException("Missing product code");
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
                    stock,
                    on_offer
                ) VALUES
                (
                    UUID(),
                    :content_id,
                    :stock,
                    :on_offer
                )",
                [
                    "content_id": model->id,
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