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
            "SELECT * FROM order_addresses WHERE order_id=:order_id AND type='billing'",
            [
                "order_id": model->id
            ]
        );

        let model->shipping = database->get(
            "SELECT * FROM order_addresses WHERE order_id=:order_id AND type='shipping'",
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
            <div class='dd-box dd-wfull" . (model->deleted_at ? " deleted" : "") . "'>
                <div class='dd-box-title'>
                    <span>the order</span>
                </div>
                <div class='dd-box-body'>
                    <div class='dd-input-group'>
                        <span>Status</span>
                        <p style='padding:0; margin: 0'><span style='float: left;' class='dd-status dd-status-" . str_replace(" ", "-", model->status) . "'>" . model->status . "</span></p>
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
                <div class='dd-box" . (model->deleted_at ? " deleted" : "") . "'>
                    <div class='dd-box-title'>
                        <span>billing</span>
                    </div>
                    <div class='dd-box-body'>
                        " . this->createInputText("name", "billing_name", "their name", true, security->decrypt(model->billing->name)) .
                    "</div>
                </div>
                <div class='dd-box" . (model->deleted_at ? " deleted" : "") . "'>
                    <div class='dd-box-title'>
                        <span>shipping</span>
                    </div>
                    <div class='dd-box-body'>
                        " . this->createInputText("name", "shipping_name", "their name", true, security->decrypt(model->shipping->name)) .
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
        
        let data = database->all("
            SELECT orders.*, order_addresses.name 
            FROM orders 
            LEFT JOIN order_addresses ON order_addresses.order_id=orders.id AND order_addresses.type='billing' 
            ORDER BY created_at DESC");

        for item in data {
            let html .= "<tr" . (item->deleted_at ? " class='dd-deleted'" : "") . ">
                <td>" . item->order_number . "</td>
                <td>" . (item->name ? security->decrypt(item->name) : "UNKNOWN") . "</td>
                <td>" . item->total . "</td>
                <td><span class='dd-status dd-status-" . str_replace(" ", "-", item->status) . "'>" . item->status . "</span></td>
                <td>" . date("d/m/Y", strtotime(item->created_at)) . "</td>
                <td><a href='/dumb-dog/orders/edit/" . item->id . "' class='dd-link mini dd-icon dd-icon-edit' title='edit me'>&nbsp;</a></td>
            </tr>";
        }

        let html .= "</tbody>
        </table>";
        
        return html;
    }

    public function recover(string path)
    {
        return this->triggerRecover(path, "orders");
    }
}