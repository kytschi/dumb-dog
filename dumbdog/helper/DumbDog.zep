/**
 * Dumb Dog helper
 *
 * @package     DumbDog\Helper\DumbDog
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
*/
namespace DumbDog\Helper;

use DumbDog\Controllers\Database;
use DumbDog\Controllers\Pages;
use DumbDog\Exceptions\Exception;
use DumbDog\Helper\Security;
use DumbDog\Ui\Captcha;

class DumbDog
{
    private cfg;
    protected system_uuid = "00000000-0000-0000-0000-000000000000";

    public captcha;
    public page;
    public menu;
    public site;

    public function __construct(object cfg, object page)
    {
        var database, data, site, menu;

        let this->cfg = cfg;
        let this->page = page;

        let database = new Database(cfg);

        let site = database->get("
        SELECT
            settings.name,
            settings.meta_keywords,
            settings.meta_description,
            settings.meta_author,
            settings.status,
            themes.folder AS theme
        FROM 
            settings
        JOIN themes ON themes.id=settings.theme_id LIMIT 1");

        let site->theme_folder = "/website/themes/" . site->theme;
        let site->theme = site->theme_folder . "/theme.css";

        let this->site = site;

        let this->captcha = new Captcha();

        let menu = new \stdClass();
        let menu->header = [];
        let menu->footer = [];
        let menu->both = [];

        let data = database->all("SELECT name, url FROM pages WHERE menu_item='header' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
        if (data) {
            let menu->header = data;
        }

        let data = database->all("SELECT name, url FROM pages WHERE menu_item='footer' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
        if (data) {
            let menu->footer = data;
        }

        let data = database->all("SELECT name, url FROM pages WHERE menu_item='both' AND status='live' AND deleted_at IS NULL ORDER BY created_at ASC");
        if (data) {
            let menu->both = data;
        }
        let this->menu = menu;
    }

    public function addComment(array data)
    {
        var database, security, status;
        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let data["content"] = security->clean(data["content"]);
        let data["created_by"] = this->system_uuid;
        let data["updated_by"] = this->system_uuid;

        let status = database->execute(
            "INSERT INTO comments 
                (id,
                content,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :content,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            return false;
        }

        return true;
    }

    public function addMessage(array data)
    {
        var database, security, status;
        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let data["from_email"] = security->encrypt(data["from_email"]);
        let data["from_name"] = security->encrypt(data["from_name"]);
        let data["from_number"] = security->encrypt(data["from_number"]);
        let data["message"] = security->encrypt(security->clean(data["message"]));
        let data["to_name"] = "dumb dog";
        let data["created_by"] = this->system_uuid;
        let data["updated_by"] = this->system_uuid;

        let status = database->execute(
            "INSERT INTO messages 
                (id,
                subject,
                from_email,
                from_name,
                from_number,
                message,
                to_name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :subject,
                :from_email,
                :from_name,
                :from_number,
                :message,
                :to_name,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            return false;
        }

        return true;
    }

    public function appointments(array filters = [])
    {
        var database, query, data = [];
        let database = new Database(this->cfg);

        let query = "SELECT * FROM appointments WHERE free_slot=1 AND appointments.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "order":
                        let query .= " " . value;
                        break;
                    case "where":
                        if (isset(value["query"])) {
                            let query .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        let query .= "";
                        continue;
                }
            }
        }

        return database->all(query, data);
    }

    public function basketAddTo(string product_code, int quantity)
    {
        var database, product, order_product, status, data = [], sub_total = 0.00, sub_total_tax = 0.00, total = 0.00;
        let database = new Database(this->cfg);

        let product = database->get(
            "SELECT * FROM pages WHERE code=:code AND deleted_at IS NULL",
            ["code": product_code]
        );
        if (empty(product)) {
            throw new Exception("Failed to find the product");
        }

        if (quantity <= 0) {
            let quantity = 1;
        }

        if (isset(_SESSION["dd_basket"])) {
            let order_product = database->get(
                "SELECT * FROM orders WHERE id=:id AND deleted_at IS NULL",
                ["id": _SESSION["dd_basket"]]
            );

            if (empty(order_product)) {
                unset(_SESSION["dd_basket"]);
            }
        }

        if (!isset(_SESSION["dd_basket"])) {
            var id, security, status;
            let security = new Security(this->cfg);
            let id = security->uuid();

            let data = database->get("SELECT count(id) AS order_number FROM orders");

            let status = database->execute(
                "INSERT INTO orders 
                    (id, order_number, created_at, created_by, updated_at, updated_by)
                VALUES
                    (:id, :order_number, NOW(), :created_by, NOW(), :updated_by)",
                [
                    "id": id,
                    "order_number": sprintf("%08d", (!data->order_number ? 1 : data->order_number)),
                    "created_by": this->system_uuid,
                    "updated_by": this->system_uuid
                ]
            );
            if (!is_bool(status)) {
                throw new Exception("Failed to create the basket");
            }

            let _SESSION["dd_basket"] = id;
            session_write_close();
        }

        let order_product = database->get(
            "SELECT * FROM order_products WHERE order_id=:order_id AND product_id=:product_id",
            [
                "order_id": _SESSION["dd_basket"],
                "product_id": product->id
            ]
        );

        let total = product->price * quantity;
        let sub_total = total;
        let sub_total_tax = 0;

        let data = [
            "order_id": _SESSION["dd_basket"],
            "product_id": product->id,
            "price": product->price,
            "quantity": quantity,
            "sub_total": sub_total,
            "sub_total_tax": sub_total_tax,
            "total": total,
            "updated_by": this->system_uuid
        ];
        
        if (order_product) {
            if (product->stock < order_product->stock) {
                let quantity += quantity;
            }
            let status = database->execute(
                "UPDATE
                    order_products
                SET
                    quantity=:quantity,
                    price=:price,
                    sub_total=:sub_total,
                    sub_total_tax=:sub_total_tax,
                    total=:total,
                    updated_by=:updated_by,
                    updated_at=NOW(),
                    deleted_at=NULL,
                    deleted_by=NULL
                WHERE 
                    order_id=:order_id AND
                    product_id=:product_id",
                data
            );
        } else {
            let data["created_by"] = this->system_uuid;
            let status = database->execute(
                "INSERT INTO order_products 
                    (
                        id,
                        order_id,
                        product_id,
                        price,
                        quantity,
                        sub_total,
                        sub_total_tax,
                        total,
                        created_at,
                        created_by,
                        updated_at,
                        updated_by
                    )
                VALUES
                    (
                        UUID(),
                        :order_id,
                        :product_id,
                        :price,
                        :quantity,
                        :sub_total,
                        :sub_total_tax,
                        :total,
                        NOW(),
                        :created_by,
                        NOW(),
                        :updated_by
                    )",
                data
            );
        }

        if (!is_bool(status)) {
            throw new Exception("Failed to add the product to the basket");
        }

        this->updateBasket();
    }

    public function basket()
    {
        if (!isset(_SESSION["dd_basket"])) {
            return null;
        }

        var database, model;
        let database = new Database(this->cfg);

        let model = database->get(
            "SELECT * FROM orders WHERE id=:id AND deleted_at IS NULL",
            ["id": _SESSION["dd_basket"]]
        );

        if (empty(model)) {
            unset(_SESSION["dd_basket"]);
            return null;
        }

        let model->items = database->all(
            "SELECT
                order_products.*,
                pages.name,
                pages.content,
                pages.meta_keywords,
                pages.meta_description,
                pages.meta_author,
                pages.tags,
                pages.code,
                pages.stock 
            FROM 
                order_products 
            LEFT JOIN pages ON pages.id=order_products.product_id 
            WHERE order_id=:order_id AND order_products.deleted_at IS NULL AND pages.deleted_at IS NULL",
            [
                "order_id": model->id
            ]
        );
                
        return model;
    }

    public function basketAddBilling(array data)
    {
        return this->basketAddAddress(data);
    }

    public function basketAddShipping(array data)
    {
        return this->basketAddAddress(data, "shipping");
    }

    private function basketAddAddress(array data, string type = "billing")
    {
        if (!isset(_SESSION["dd_basket"])) {
            throw new Exception("Basket not found", 404);
        }

        var database, model, status, security;
        let database = new Database(this->cfg);
        let security = new Security(this->cfg);

        let model = database->get(
            "SELECT * FROM orders WHERE id=:id AND deleted_at IS NULL",
            ["id": _SESSION["dd_basket"]]
        );

        if (empty(model)) {
            unset(_SESSION["dd_basket"]);
            throw new Exception("Basket not found", 404);
        }

        var key, required = ["name", "address_line_1"];
        for key in required {
            if (!isset(data[key])) {
                throw new Exception("Missing required data");
            } elseif (empty(data[key])) {
                throw new Exception("Missing required data");
            }
        }

        let status = database->execute(
            "INSERT INTO order_addresses
            (
                id,
                order_id,
                type,
                name,
                address_line_1,
                address_line_2,
                city,
                county,
                postcode,
                country,
                created_at,
                created_by,
                updated_at,
                updated_by
            ) 
            VALUES
            (
                UUID(),
                :order_id,
                :type,
                :name,
                :address_line_1,
                :address_line_2,
                :city,
                :county,
                :postcode,
                :country,
                NOW(),
                :created_by,
                NOW(),
                :updated_by
            )
            ON DUPLICATE KEY UPDATE
                name=:name,
                address_line_1=:address_line_1,
                address_line_2=:address_line_2,
                city=:city,
                county=:county,
                postcode=:postcode,
                country=:country,
                updated_at=NOW(),
                updated_by=:updated_by",
            [
                "order_id": model->id,
                "type": type,
                "name": security->encrypt(data["name"]),
                "address_line_1": security->encrypt(data["address_line_1"]),
                "address_line_2": security->encrypt(isset(data["address_line_2"]) ? data["address_line_2"] : ""),
                "city": security->encrypt(data["city"]),
                "county": security->encrypt(data["county"]),
                "postcode": security->encrypt(data["postcode"]),
                "country": security->encrypt(data["country"]),
                "created_by": this->system_uuid,
                "updated_by": this->system_uuid
            ]
        );

        if (!is_bool(status)) {
            throw new Exception(status);
        }

        return true;
    }

    public function basketRemoveFrom(string id)
    {
        var database, product, status;
        let database = new Database(this->cfg);

        let product = database->get(
            "SELECT * FROM order_products WHERE id=:id AND deleted_at IS NULL",
            ["id": id]
        );
        if (empty(product)) {
            throw new Exception("Failed to find the product");
        }

        let status = database->execute(
            "DELETE FROM order_products WHERE id=:id",
            [
                "id": product->id
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to remove the product from the basket");
        }

        this->updateBasket();
    }

    public function bookAppointment(array data)
    {
        var database, model, security;
        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let model = database->get(
            "SELECT * FROM appointments WHERE free_slot=1 AND id=:id",
            ["id": data["id"]]
        );
        if (empty(model)) {
            throw new Exception("Failed to find the appointment");
        }

        let data["updated_by"] = this->system_uuid;
        let data["content"] = security->clean(data["content"]);
        
        return database->execute(
            "UPDATE appointments SET 
                name=:name,
                content=:content, 
                free_slot=0,
                updated_at=NOW(), 
                updated_by=:updated_by
            WHERE id=:id",
            data
        );
    }

    public function comments(array filters = [])
    {
        var database, query, where, data = [];
        let database = new Database(this->cfg);

        let query = "
        SELECT
            comments.id,
            comments.name,
            comments.content
        FROM comments";
        let where = " WHERE comments.reviewed = 1 AND comments.deleted_at IS NULL";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "random":
                        let where .= " ORDER BY RAND() LIMIT " . intval(value);
                        break;
                    case "order":
                        let where .= " " . value;
                        break;
                    case "where":
                        if (isset(value["query"])) {
                            let where .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        continue;
                }
            }
        }

        return database->all(query . where, data);
    }

    public function events(array filters = [])
    {
        return this->pageQuery(filters, "event");
    }

    public function filesByTag(string tag)
    {
        var database, query;
        let database = new Database(this->cfg);

        let query = "
        SELECT
            name,
            mime_type,
            CONCAT('/website/files/', filename) AS filename,
            CONCAT('/website/files/thumb-', filename) AS thumbnail  
        FROM files 
        WHERE tags like :tag AND deleted_at IS NULL";

        return database->all(query, ["tag": "%{\"value\":\"" . tag . "\"}%"]);
    }

    public function pages(array filters = [])
    {
        return this->pageQuery(filters);
    }

    private function pageQuery(array filters, string type = "page")
    {
        var database, query, where, data = [];
        let database = new Database(this->cfg);

        let query = "
        SELECT
            pages.*,
            templates.file AS template
        FROM pages 
        JOIN templates ON templates.id=pages.template_id";

        let where = " WHERE pages.status='live' AND pages.deleted_at IS NULL AND pages.type = '" . type . "'";

        if (count(filters)) {
            var key, value;
            for key, value in filters {
                switch (key) {
                    case "children":
                        let where .= " AND parent_id=:parent_id";
                        let data["parent_id"] = value;
                        break;
                    case "order":
                        let where .= " " . value;
                        break;
                    case "tag":
                        let where .= " AND tags like :tag";
                        let data["tag"] = "%{\"value\":\"" . value . "\"}%";
                        break;
                    case "where":
                        if (isset(value["query"])) {
                            let where .= " AND " . value["query"];
                        }
                        if (isset(value["data"])) {
                            let data = value["data"];
                        }
                        break;
                    default:
                        continue;
                }
            }
        }

        return database->all(query . where, data);
    }

    public function products(array filters = [])
    {
        return this->pageQuery(filters, "product");
    }

    private function updateBasket()
    {
        var database, products, status;
        let database = new Database(this->cfg);

        let products = database->get(
            "SELECT
                SUM(total) AS total,
                SUM(sub_total_tax) AS sub_total_tax,
                SUM(sub_total) AS sub_total,
                SUM(quantity) AS quantity
            FROM
                order_products
            WHERE 
                order_id=:order_id AND deleted_at IS NULL",
            [
                "order_id": _SESSION["dd_basket"]
            ]
        );

        let status = database->execute(
            "UPDATE
                orders 
            SET
                sub_total=:sub_total,
                sub_total_tax=:sub_total_tax,
                total=:total,
                quantity=:quantity,
                updated_by=:updated_by,
                updated_at=NOW()
            WHERE 
                id=:id",
            [
                "id": _SESSION["dd_basket"],
                "total": floatval(products->total),
                "sub_total": floatval(products->sub_total),
                "sub_total_tax": floatval(products->sub_total_tax),
                "quantity": intval(products->quantity),
                "updated_by": this->system_uuid
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to update the basket");
        }
    }
}