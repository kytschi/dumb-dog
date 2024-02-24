/**
 * Dumb Dog Stripe payment gateway
 *
 * @package     DumbDog\Controllers\Gateways
 * @author 		Mike Welsh
 * @copyright   2024 Digital Dunes
 * @version     0.0.1
 *
 * Copyright 2024 Digital Dunes
*/
namespace DumbDog\Controllers\Gateways;

use DumbDog\Controllers\Basket;
use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\Exception;
use DumbDog\Helper\Security;

class Stripe extends Controller
{
    public function create()
    {
        var stripe, basket, item, items = [], checkout_session, settings, err;

        header("Content-Type: application/json");

        try {
            let basket = (new Basket())->get();
            
            let settings = this->database->get("SELECT * FROM settings LIMIT 1");
            let stripe = this->getLib("stripe");
            
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

            let checkout_session = stripe->checkout->sessions->create([
                "ui_mode": "embedded",
                "line_items": items,
                "client_reference_id": basket->id,
                "customer_email": basket->email,
                "mode": "payment",
                "return_url": settings->domain . "/basket/complete?session_id={CHECKOUT_SESSION_ID}"
            ]);

            http_response_code(200);
            echo json_encode(["clientSecret": checkout_session->client_secret]);
            die();
        } catch \Exception, err {
            http_response_code(500);
            echo json_encode(["error": err->getMessage()]);
            die();
        }
    }

    public function status()
    {
        var stripe, json, session, err, basket, status = false;

        let basket = (new Basket())->get();
        let stripe = this->getLib("stripe");
        header("Content-Type: application/json");

        try {
            let json = json_decode(file_get_contents("php://input"));

            if (empty(json)) {
                throw new Exception("Invalid json");
            }

            let session = stripe->checkout->sessions->retrieve(json->session_id);

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