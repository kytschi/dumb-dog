/**
 * Dumb Dog Stripe payment gateway
 *
 * @package     DumbDog\Controllers\Gateways\Stripe
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
*/
namespace DumbDog\Controllers\Gateways;

use DumbDog\Controllers\Basket;
use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\Exception;

class Stripe extends Controller
{
    private api_key = "";

    public function create()
    {
        var stripe, basket, item, items = [], checkout_session, settings, err;

        header("Content-Type: application/json");

        try {
            let basket = (new Basket())->get();
            if (empty(basket)) {
                throw new Exception("Empty basket");
            }
            
            let settings = this->database->get("SELECT * FROM settings LIMIT 1");
            let stripe = this->setClient(basket);
            
            for item in basket->items {
                let items[] = [
                    "price_data": [
                        "currency": "gbp",
                        "product_data": [
                            "name": item->name
                        ],
                        "unit_amount": intval(floatval(item->total) * 100)
                    ],
                    "quantity": intval(item->quantity)
                ];
            }

            let checkout_session = stripe->checkout->sessions->create(
                [
                    "ui_mode": "embedded",
                    "line_items": items,
                    "client_reference_id": basket->id,
                    "customer_email": basket->email,
                    "mode": "payment",
                    "return_url": settings->domain . "/basket/complete?session_id={CHECKOUT_SESSION_ID}"
                ],
                ["api_key": this->api_key]
            );

            http_response_code(200);
            echo json_encode(["clientSecret": checkout_session->client_secret]);
            die();
        } catch \Exception, err {
            http_response_code(500);
            echo json_encode(["error": err->getMessage()]);
            die();
        }
    }

    private function setClient(basket)
    {
        var client, result;
        let client = this->getLib("stripe");

        if (empty(client)) {
            throw new Exception("Stripe library not found");
        }

        let result = this->database->get(
            "SELECT payment_gateways.* 
            FROM orders 
            LEFT JOIN payment_gateways ON payment_gateways.id = orders.payment_gateway_id 
            WHERE orders.id=:id AND orders.deleted_at IS NULL",
            ["id": basket->id]
        );
        if (empty(result)) {
            throw new Exception("Invalid gateway");
        }
        if (empty(result->private_api_key)) {
            throw new Exception("Invalid gateway");
        }

        let this->api_key = this->database->decrypt(result->private_api_key);

        return client;
    }

    public function status()
    {
        var stripe, json, session, err, basket, status = false;

        header("Content-Type: application/json");

        try {
            let basket = (new Basket())->get();
            if (empty(basket)) {
                throw new Exception("Empty basket");
            }
            let stripe = this->setClient(basket);
            
            let json = json_decode(file_get_contents("php://input"));

            if (empty(json)) {
                throw new Exception("Invalid json");
            }

            let session = stripe->checkout->sessions->retrieve(
                json->session_id,
                null,
                ["api_key": this->api_key]
            );

            if (empty(session)) {
                throw new Exception("Invalid session");
            }

            http_response_code(200);
            echo json_encode([
                "status": session->status,
                "client_reference_id": session->client_reference_id
            ]);

            if (basket->id == session->client_reference_id) {
                let status = this->database->execute(
                    "UPDATE orders SET payment_id=:payment_id,status='dispatch' WHERE id=:id",
                    [
                        "id": basket->id,
                        "payment_id": session->payment_intent
                    ]
                );
        
                if (!is_bool(status)) {
                    throw new Exception("Failed to update the basket");
                }

                this->session_clear("basket");
            } else {
                throw new Exception("Invalid basket");
            }
            die();
        } catch \Exception, err {
            http_response_code(500);
            echo json_encode(["error": err->getMessage()]);
            die();
        }
    }
}