/**
 * Dumb Dog dashboard
 *
 * @package     DumbDog\Controllers\Dashboard
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
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Dashboard extends Controller
{
    private cfg;

    public function __construct(array cfg)
    {
        let this->cfg = cfg;    
    }

    public function index(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let html = titles->page("Dashboard", "/assets/dashboard.png");

        let database = new Database(this->cfg);
        let data["id"] = _SESSION["dd"];
        let model = database->get("SELECT * FROM users WHERE id=:id", data);

        if (model) {
            let html .= "<h2 class='page-sub-title'><span>Whaddup " . (model->nickname ? model->nickname : model->name) . "!</span></h2>";
        }

        return html;
    }

    public function login(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let html = titles->page("let me in", "/assets/login.png");

        if (!empty(_POST)) {
            if (isset(_POST["login"])) {
                let data["name"] = _POST["name"];
                
                let database = new Database(this->cfg);
                let model = database->get("SELECT * FROM users WHERE name=:name", data);
                if (empty(model)) {
                    throw new AccessException("hahaha, nice try! bad doggie!");
                }

                if (!password_verify(_POST["password"], model->password)) {
                    throw new AccessException("hahaha, nice try! bad doggie!");
                }

                if (model->deleted_at || model->status == "inactive") {
                    throw new AccessException("bad doggie! user account is not active!");
                }
                let _SESSION["dd"] = model->id;
                session_write_close();
                this->redirect("/dumb-dog/");
            }
        }

        let html .= "<form method='post'><div class='box wfull'>
            <div class='box-body'>
                <div class='input-group'>
                    <span>username<span class='required'>*</span></span>
                    <input type='text' name='name' placeholder='what is your username?'>
                </div>
                <div class='input-group'>
                    <span>password<span class='required'>*</span></span>
                    <input type='password' name='password' placeholder='your secret password please'>
                </div>
            </div>
            <div class='box-footer'>
                <button type='submit' name='login'>login</button>
            </div>
        </div></form>";

        return html;
    }

    public function logout(string path)
    {   
        let _SESSION["dd"] = null;
        session_unset();
        session_destroy();
        this->redirect("/dumb-dog/the-pound");
    }
}