/**
 * DumbDog basket controller
 *
 * @package     DumbDog\Controllers\Basket
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Helper\Security;

class Basket extends Controller
{
    public function add(string product_code, int quantity)
    {
        var id, currency_id, product, order_product, status,
            data = [], sub_total = 0.00, sub_total_tax = 0.00, total = 0.00;

        let currency_id = this->session("currency");
        if (empty(currency_id)) {
            let product = this->database->get("SELECT currencies.id FROM currencies WHERE is_default=1 AND status='active'");
            if (!empty(product)) {
                let currency_id = product->id;
                this->session("currency", currency_id);
            } else {
                throw new Exception("Invalid currency");
            }
        }

        let product = this->database->get(
            "SELECT
                products.*,
                IF(products.on_offer,product_prices.offer_price,product_prices.price) AS price,
                product_prices.currency_id, 
                product_prices.tax_id, 
                content.*  
                FROM content 
                JOIN products ON products.content_id=content.id 
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
                WHERE
                    products.code=:code AND
                    content.deleted_at IS NULL",
            [
                "code": product_code,
                "currency_id": currency_id
            ]
        );
        if (empty(product)) {
            throw new Exception("Failed to find the product");
        }

        if (quantity <= 0) {
            let quantity = 1;
        }

        let id = this->session("basket");

        if (id) {
            let order_product = this->database->get(
                "SELECT * FROM orders WHERE id=:id AND deleted_at IS NULL",
                ["id": id]
            );

            if (empty(order_product)) {
                this->session_clear("basket");
                let id = "";
            }
        }

        if (empty(id)) {
            let id = this->create(product->currency_id, product->tax_id);
        }

        let order_product = this->database->get(
            "SELECT * FROM order_products WHERE order_id=:order_id AND product_id=:product_id",
            [
                "order_id": id,
                "product_id": product->id
            ]
        );

        let total = product->price * quantity;
        let sub_total = total;
        let sub_total_tax = 0;

        let data = [
            "order_id": id,
            "product_id": product->id,
            "currency_id": product->currency_id,
            "tax_id": product->tax_id,
            "price": product->price,
            "quantity": quantity,
            "sub_total": sub_total,
            "sub_total_tax": sub_total_tax,
            "total": total,
            "updated_by": this->database->system_uuid
        ];
        
        if (order_product) {
            if (product->stock < order_product->stock) {
                let quantity += quantity;
            }
            let status = this->database->execute(
                "UPDATE
                    order_products
                SET
                    currency_id=:currency_id,
                    tax_id=:tax_id,
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
            let data["created_by"] = this->database->system_uuid;
            let status = this->database->execute(
                "INSERT INTO order_products 
                    (
                        id,
                        order_id,
                        product_id,
                        currency_id,
                        tax_id,
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
                        :currency_id,
                        :tax_id,
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

        this->update();
    }

    private function create(string currency_id, tax_id)
    {
        var id, security, data, status;
        let security = new Security(this->cfg);
        let id = this->database->uuid();

        let data = this->database->get("SELECT count(id) AS order_number FROM orders");

        let status = this->database->execute(
            "INSERT INTO orders 
                (id, order_number, currency_id, tax_id, created_at, created_by, updated_at, updated_by)
            VALUES
                (:id, :order_number, :currency_id, :tax_id, NOW(), :created_by, NOW(), :updated_by)",
            [
                "id": id,
                "currency_id": currency_id,
                "tax_id": tax_id,
                "order_number": sprintf("%08d", (!data->order_number ? 1 : data->order_number)),
                "created_by": this->database->system_uuid,
                "updated_by": this->database->system_uuid
            ]
        );
        if (!is_bool(status)) {
            throw new Exception("Failed to create the basket");
        }

        this->session("basket", id);

        return id;
    }

    public function get()
    {
        var id, security, model;
        let id = this->session("basket");
        if (empty(id)) {
            return null;
        }

        let security = new Security(this->cfg);

        let model = this->database->get(
            "SELECT
                order_addresses.*,
                orders.*,
                payment_gateways.slug AS payment_gateway,
                currencies.symbol 
            FROM orders 
            JOIN currencies ON currencies.id = orders.currency_id 
            LEFT JOIN payment_gateways ON payment_gateways.id = orders.payment_gateway_id 
            LEFT JOIN order_addresses ON order_addresses.order_id = orders.id  
            WHERE orders.id=:id AND orders.deleted_at IS NULL",
            ["id": id]
        );

        if (empty(model)) {
            this->session_clear("basket");
            return null;
        }

        var decrypt = [
            "first_name",
            "last_name",
            "email",
            "address_line_1",
            "address_line_2",
            "city",
            "county",
            "postcode",
            "country"
        ];

        for id in decrypt {
            let model->{id} = security->decrypt(model->{id});
        }

        let model->items = this->database->all(
            "SELECT
                content.name,
                content.title,
                content.slogan,
                content.content,
                content.meta_keywords,
                content.meta_description,
                content.meta_author,
                content.tags,
                products.code,
                products.stock,
                currencies.symbol,
                product_prices.currency_id,
                product_prices.tax_id,
                order_products.* 
            FROM 
                order_products 
            JOIN content ON content.id=order_products.product_id 
            JOIN products ON products.content_id=content.id 
            JOIN currencies ON currencies.id = order_products.currency_id 
            JOIN product_prices ON 
                product_prices.id = 
                (
                    SELECT id
                    FROM product_prices AS pp
                    WHERE
                        pp.product_id = products.id AND
                        pp.deleted_at IS NULL AND
                        pp.currency_id=currencies.id 
                    LIMIT 1
                )
            WHERE
                order_id=:order_id AND 
                order_products.deleted_at IS NULL AND 
                content.deleted_at IS NULL",
            [
                "order_id": model->id
            ]
        );

        return model;
    }

    public function addBilling(array data)
    {
        return this->addAddress(data);
    }

    public function addShipping(array data)
    {
        return this->addAddress(data, "shipping");
    }

    private function addAddress(array data, string type = "billing")
    {
        var id, basket, model, status, security, key, required = [
            "first_name",
            "last_name",
            "email",
            "address_line_1",
            "city",
            "county",
            "postcode",
            "country"
        ];
        
        for key in required {
            if (!isset(data[key])) {
                throw new Exception("Missing required data");
            } elseif (empty(data[key])) {
                throw new Exception("Missing required data");
            }
        }

        let security = new Security(this->cfg);
        let basket = this->get();

        let model = this->database->get(
            "SELECT id FROM order_addresses WHERE order_id=:order_id AND type=:type",
            [
                "order_id": basket->id,
                "type": type
            ]
        );

        if (!empty(model)) {
            let id = model->id;
        } else {
            let id = this->database->uuid();
        }

        let status = this->database->execute(
            "INSERT INTO order_addresses
            (
                id,
                order_id,
                type,
                first_name,
                last_name,
                email,
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
                :id,
                :order_id,
                :type,
                :first_name,
                :last_name,
                :email,
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
            ON DUPLICATE KEY
                UPDATE
                    first_name=:first_name,
                    last_name=:last_name,
                    address_line_1=:address_line_1,
                    address_line_2=:address_line_2,
                    city=:city,
                    county=:county,
                    postcode=:postcode,
                    country=:country,
                    updated_at=NOW(),
                    updated_by=:updated_by",
            [
                "id": id,
                "order_id": basket->id,
                "type": type,
                "first_name": security->encrypt(data["first_name"]),
                "last_name": security->encrypt(data["last_name"]),
                "email": security->encrypt(data["email"]),
                "address_line_1": security->encrypt(data["address_line_1"]),
                "address_line_2": security->encrypt(isset(data["address_line_2"]) ? data["address_line_2"] : ""),
                "city": security->encrypt(data["city"]),
                "county": security->encrypt(data["county"]),
                "postcode": security->encrypt(data["postcode"]),
                "country": security->encrypt(data["country"]),
                "created_by": this->database->system_uuid,
                "updated_by": this->database->system_uuid
            ]
        );

        if (!is_bool(status)) {
            throw new Exception(status);
        }

        this->createCustomer(basket->id, data, security);

        return true;
    }

    private function createCustomer(string order_id, data, security)
    {
        var status = false, id, model;

        let model = this->database->get(
            "SELECT id FROM customers WHERE email=:email",
            [
                "email": security->encrypt(data["email"])
            ]
        );

        if (!empty(model)) {
            let id = model->id;
        } else {
            let id = this->database->uuid();
        }
        
        let status = this->database->execute(
            "INSERT INTO customers
            (
                id,
                first_name,
                last_name,
                email,
                created_at,
                created_by,
                updated_at,
                updated_by
            ) 
            VALUES
            (
                :id,
                :first_name,
                :last_name,
                :email,
                NOW(),
                :created_by,
                NOW(),
                :updated_by
            )
            ON DUPLICATE KEY 
                UPDATE 
                    email=:email,
                    first_name=:first_name,
                    last_name=:last_name,
                    updated_at=NOW(),
                    updated_by=:updated_by",
            [
                "id": id,
                "email": security->encrypt(data["email"]),
                "first_name": security->encrypt(data["first_name"]),
                "last_name": security->encrypt(data["last_name"]),
                "created_by": this->database->system_uuid,
                "updated_by": this->database->system_uuid
            ]
        );

        if (!is_bool(status)) {
            throw new Exception(status);
        }

        let status = this->database->execute(
            "UPDATE orders SET customer_id=:customer_id WHERE id=:id",
            [
                "id": order_id,
                "customer_id": id
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to update the basket");
        }
    }

    public function remove(string id)
    {
        var product, status;

        let product = this->database->get(
            "SELECT * FROM order_products WHERE id=:id AND deleted_at IS NULL",
            ["id": id]
        );
        if (empty(product)) {
            throw new Exception("Failed to find the product");
        }

        let status = this->database->execute(
            "DELETE FROM order_products WHERE id=:id",
            [
                "id": product->id
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to remove the product from the basket");
        }

        this->update();
    }

    private function update()
    {
        var products, status;
        
        let products = this->database->get(
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
                "order_id": this->session("basket")
            ]
        );

        let status = this->database->execute(
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
                "id": this->session("basket"),
                "total": floatval(products->total),
                "sub_total": floatval(products->sub_total),
                "sub_total_tax": floatval(products->sub_total_tax),
                "quantity": intval(products->quantity),
                "updated_by": this->database->system_uuid
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to update the basket");
        }
    }

    public function updateCurrency(string currency_id)
    {
        var basket, result, status = false, item;

        let basket = this->get();
        if (empty(basket)) {
            return;
        }

        let result = this->database->get(
            "SELECT currencies.id FROM currencies WHERE id=:id AND deleted_at IS NULL AND status='active'",
            [
                "id": currency_id
            ]
        );

        if (empty(result)) {
            throw new Exception("Invalid currency");
        }

        let status = this->database->execute(
            "UPDATE orders SET currency_id=:currency_id WHERE id=:id",
            [
                "id": basket->id,
                "currency_id": result->id
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to update the basket");
        }

        for item in basket->items {
            let status = this->database->execute(
                "UPDATE order_products SET currency_id=:currency_id WHERE id=:id",
                [
                    "id": item->id,
                    "currency_id": result->id
                ]
            );
    
            if (!is_bool(status)) {
                throw new Exception("Failed to update the basket product");
            }
        }
    }

    public function updatePaymentGateway(string payment_gateway_id)
    {
        var basket, result, status = false;

        let basket = this->get();
        if (empty(basket)) {
            return;
        }

        let result = this->database->get(
            "SELECT id, slug FROM payment_gateways WHERE id=:id AND deleted_at IS NULL AND status='active'",
            [
                "id": payment_gateway_id
            ]
        );

        if (empty(result)) {
            throw new Exception("Invalid payment gateway");
        }

        let status = this->database->execute(
            "UPDATE orders SET payment_gateway_id=:payment_gateway_id WHERE id=:id",
            [
                "id": basket->id,
                "payment_gateway_id": result->id
            ]
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to update the basket");
        }

        return result;
    }
}