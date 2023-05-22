/**
 * Dumb Dog products builder
 *
 * @package     DumbDog\Controllers\Products
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

use DumbDog\Controllers\Pages;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Products extends Pages
{
    public global_url = "/dumb-dog/products";
    public required = ["name", "url", "template_id", "code", "price", "stock"];
    
    public function add(string path, string type = "product")
    {
        return parent::add(path, type);
    }

    public function addHtml()
    {
        return 
            this->createInputText("code", "code", "the product code", true) .
            this->createInputText("price", "price", "the price", true) .
            this->createInputText("stock", "stock", "the stock", true);
    }

    public function edit(string path, string type = "product")
    {
        return parent::edit(path, type);
    }

    public function editHtml(model)
    {
        return 
            this->createInputText("code", "code", "the product code", true, model->code) .
            this->createInputText("price", "price", "the price", true, model->price) .
            this->createInputText("stock", "stock", "the stock", true, model->stock);
    }

    public function index(string path)
    {
        var titles, tiles, database, html;
        let titles = new Titles();
        
        let html = titles->page("Products", "products");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the product");
        }

        let html .= "<div class='page-toolbar'>
            <a href='/dumb-dog/pages' class='round icon icon-up' title='Back to pages'>&nbsp;</a>
            <a href='/dumb-dog/products/add' class='round icon' title='Add a product'>&nbsp;</a>
            <a href='/dumb-dog/files?from=products' class='round icon icon-files' title='Managing the files and media'>&nbsp;</a>
            <a href='/dumb-dog/templates?from=products' class='round icon icon-templates' title='Managing the templates'>&nbsp;</a>
        </div>";

        let database = new Database(this->cfg);

        let tiles = new Tiles();
        let html = html . tiles->build(
            database->all("SELECT * FROM pages WHERE type='product' ORDER BY name"),
            "/dumb-dog/products/edit/"
        );

        return html;
    }
}