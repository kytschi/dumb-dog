/**
 * Dumb Dog orders builder
 *
 * @package     DumbDog\Controllers\Orders
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
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Titles;

class Orders extends Controller
{
    public function delete(string path)
    {
        return this->triggerDelete(path, "orders");
    }

    public function edit(string path)
    {
        var titles, html, database, model, data = [], security;
        let titles = new Titles();
        let database = new Database(this->cfg);
        let security = new Security(this->cfg);

        let data["id"] = this->getPageId(path);
        let model = database->get("SELECT * FROM orders WHERE id=:id", data);
        if (empty(model)) {
            throw new NotFoundException("Order not found");
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

        let model->billing = database->get(
            "SELECT * FROM order_addresses WHERE order_id=:order_id AND type='billing' ORDER BY updated_at DESC LIMIT 1",
            [
                "order_id": model->id
            ]
        );

        let model->shipping = database->get(
            "SELECT * FROM order_addresses WHERE order_id=:order_id AND type='shipping' ORDER BY updated_at DESC LIMIT 1",
            [
                "order_id": model->id
            ]
        );

        let html = titles->page("Edit the order", "edit");
        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }
        let html .= "<div class='dd-page-toolbar";
        if (model->deleted_at) {
            let html .= " dd-deleted";
        }
        let html .= "'><a href='/dumb-dog/orders' class='dd-link dd-round dd-icon dd-icon-back' title='Back to list'>&nbsp;</a>";
        if (model->deleted_at) {
            let html .= "<a href='/dumb-dog/orders/recover/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-recover' title='Recover the order'>&nbsp;</a>";
        } else {
            let html .= "<a href='/dumb-dog/orders/delete/" . model->id . "' class='dd-link dd-round dd-icon dd-icon-delete' title='Delete the order'>&nbsp;</a>";
        }
        let html .= "</div>";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the user");
        }

        let html .= "
        <form method='post'>
            <div class='dd-box dd-wfull" . (model->deleted_at ? " dd-deleted" : "") . "'>
                <div class='dd-box-title'>
                    <span>the order</span>
                </div>
                <div class='dd-box-body'>
                    <div class='dd-input-group'>
                        <span>Status</span>
                        <div style='padding:0; margin: 0'>
                            <span 
                                style='float: left;' 
                                class='dd-status dd-status-" . str_replace(" ", "-", model->status) . "'>" . 
                                model->status . 
                            "</span>
                            <div style='margin-left:20px;float: left;'>
                                Change: 
                                <select name='status' class='dd-select'>
                                    <option value='processing' ". (model->status == "processing" ? "selected='selected'" : "") . ">processing</option>
                                    <option value='packing' ". (model->status == "packing" ? "selected='selected'" : "") . ">packing</option>
                                    <option value='dispatched' ". (model->status == "dispatched" ? "selected='selected'" : "") . ">dispatched</option>
                                    <option value='basket' ". (model->status == "basket" ? "selected='selected'" : "") . ">basket</option>
                                    <option value='cancelled' ". (model->status == "cancelled" ? "selected='selected'" : "") . ">cancelled</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <table class='dd-table dd-wfull'>
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th width='100px'>Qty</th>
                                <th width='120px'>Price</th>
                                <th width='120px'>Total</th>
                            </tr>
                        </thead>
                        <tbody>";

            var item;
            for item in model->items {
                let html .= "<tr>
                    <td>" . item->name . "</td>
                    <td>" . item->quantity . "</td>
                    <td>" . item->price . "</td>
                    <td>" . item->total . "</td>
                </tr>";
            }
            
            let html .= "</tbody>
                        <tfoot>
                            <tr>
                                <td class='blank' colspan='2'>&nbsp;</td>
                                <td class='total'>Sub-total</td>
                                <td>" . model->sub_total . "</td>
                            </tr>
                            <tr>
                                <td class='blank' colspan='2'>&nbsp;</td>
                                <td class='total'>Tax</td>
                                <td>" . model->sub_total_tax . "</td>
                            </tr>
                            <tr>
                                <td class='blank' colspan='2'>&nbsp;</td>
                                <td class='total'>Total</td>
                                <td>" . model->total . "</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <div class='dd-box-footer'>
                    <a href='/dumb-dog/orders' class='dd-link dd-button-blank'>cancel</a>
                    <button type='submit' name='save' class='dd-button'>save</button>
                </div>
            </div>
            <div class='dd-row'>
                <div class='dd-box" . (model->deleted_at ? " dd-deleted" : "") . "'>
                    <div class='dd-box-title'>
                        <span>billing</span>
                    </div>
                    <div class='dd-box-body'>
                        " . this->createInputText(
                            "name",
                            "billing_name", 
                            "their name", 
                            true, 
                            security->decrypt(model->billing->name)
                        ) .
                        this->createInputText(
                            "email",
                            "billing_email", 
                            "their email", 
                            true, 
                            security->decrypt(model->billing->email)
                        ) .
                        this->createInputText(
                            "address",
                            "billing_address_line_1", 
                            "first line of their address", 
                            true, 
                            security->decrypt(model->billing->address_line_1)
                        ) .
                        this->createInputText(
                            "",
                            "billing_address_line_2", 
                            "second line of their address", 
                            false, 
                            security->decrypt(model->billing->address_line_2)
                        ) .
                        this->createInputText(
                            "city",
                            "billing_city", 
                            "their city", 
                            true, 
                            security->decrypt(model->billing->city)
                        ) .
                        this->createInputText(
                            "county or state",
                            "billing_county", 
                            "their county/state", 
                            true, 
                            security->decrypt(model->billing->county)
                        ) .
                        this->createInputText(
                            "postcode",
                            "billing_postcode", 
                            "their postcode/zipcode", 
                            true, 
                            security->decrypt(model->billing->postcode)
                        ) .
                        this->createInputText(
                            "country",
                            "billing_country", 
                            "their country", 
                            true, 
                            security->decrypt(model->billing->country)
                        ) .
                    "</div>
                </div>
                <div class='dd-box" . (model->deleted_at ? " dd-deleted" : "") . "'>
                    <div class='dd-box-title'>
                        <span>shipping</span>
                    </div>
                    <div class='dd-box-body'>
                        " . this->createInputText(
                            "name",
                            "shipping_name",
                            "their name",
                            true,
                            security->decrypt(model->shipping->name)
                        ) .
                        this->createInputText(
                            "email",
                            "shipping_email", 
                            "their email", 
                            true, 
                            security->decrypt(model->shipping->email)
                        ) .
                        this->createInputText(
                            "address",
                            "shipping_address_line_1", 
                            "first line of their address", 
                            true, 
                            security->decrypt(model->shipping->address_line_1)
                        ) .
                        this->createInputText(
                            "",
                            "shipping_address_line_2", 
                            "second line of their address", 
                            false, 
                            security->decrypt(model->shipping->address_line_2)
                        ) .
                        this->createInputText(
                            "city",
                            "shipping_city", 
                            "their city", 
                            true, 
                            security->decrypt(model->shipping->city)
                        ) .
                        this->createInputText(
                            "county or state",
                            "shipping_county", 
                            "their county/state", 
                            true, 
                            security->decrypt(model->shipping->county)
                        ) .
                        this->createInputText(
                            "postcode",
                            "shipping_postcode", 
                            "their postcode/zipcode", 
                            true, 
                            security->decrypt(model->shipping->postcode)
                        ) .
                        this->createInputText(
                            "country",
                            "shipping_country", 
                            "their country", 
                            true, 
                            security->decrypt(model->shipping->country)
                        ) .
                    "</div>
                </div>
            </div>
        </form>";

        return html;
    }

    public function index(string path)
    {
        var titles, database, html, data, item, security;
        let titles = new Titles();
        
        
        let html = titles->page("Orders", "orders");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the order");
        }

        let security = new Security(this->cfg);
        let database = new Database(this->cfg);

        let data = database->all("
            SELECT orders.*, order_addresses.name 
            FROM orders 
            LEFT JOIN order_addresses ON order_addresses.order_id=orders.id AND order_addresses.type='billing' 
            ORDER BY created_at DESC");
        if (data) {
            let html .= "
                <table class='dd-table dd-wfull'>
                    <thead>
                        <tr>
                            <th width='120px'>Order no.</th>
                            <th>Details</th>
                            <th width='140px'>Total</th>
                            <th width='120px'>Status</th>
                            <th width='100px'>Date</th>
                            <th width='100px'>Tools</th>
                        </tr>
                    </thead>
                    <tbody>";
            
            for item in data {
                let html .= "<tr" . (item->deleted_at ? " class='dd-deleted'" : "") . ">
                    <td>" . item->order_number . "</td>
                    <td>" . (item->name ? security->decrypt(item->name) : "UNKNOWN") . "</td>
                    <td>" . item->total . "</td>
                    <td><span class='dd-status dd-status-" . str_replace(" ", "-", item->status) . "'>" . item->status . "</span></td>
                    <td>" . date("d/m/Y", strtotime(item->created_at)) . "</td>
                    <td><a href='/dumb-dog/orders/edit/" . item->id . "' class='dd-link dd-mini dd-icon dd-icon-edit' title='edit me'>&nbsp;</a></td>
                </tr>";
            }

            let html .= "</tbody>
            </table>";
        } else {
            let titles = new Titles();
            let html = html . titles->noResults();
        }
        
        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "orders");
    }
}