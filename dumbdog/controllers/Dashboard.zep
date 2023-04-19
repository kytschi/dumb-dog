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

    public function __construct(object cfg)
    {
        let this->cfg = cfg;    
    }

    private static function captcha() {
		var colour, red, green, blue, width, height, image, keyspace, pieces, max, trans_colour;

		let colour = "000000";
        let red = hexdec(substr(colour, 0, 2));
        let green = hexdec(substr(colour, 2, 2));
        let blue = hexdec(substr(colour, 4, 2));

        let width = 340;
        let height = 100;

        let image = imagecreatetruecolor(width, height);
        imagesavealpha(image, true);

        let trans_colour = imagecolorallocatealpha(image, 0, 0, 0, 127);
        imagefill(image, 0, 0, trans_colour);

        let keyspace = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

        let pieces = [];
        let max = count(keyspace) - 1;

		var i, captcha, font_colour, image_data, line_color, letter = "", encrypted;

		let i = 7;
		while i {
            if (random_int(0, 1)) {
                let letter = keyspace[random_int(0, max)];
            } else {
                let letter = strtolower(keyspace[random_int(0, max)]);
            }
            let pieces[] = letter;
			let i -= 1;
        }

        let captcha = implode("", pieces);

        let font_colour = imagecolorallocate(image, red, green, blue);
        imagefttext(
           	image,
            38,
            0,
            15,
            65,
            font_colour,
            getcwd() . "/assets/captcha.ttf",
            captcha
        );
        
		let i = 20;
		while i {
            let line_color = imagecolorallocatealpha(image, red, green, blue, rand(10, 100));
            imageline(image, rand(0, width), rand(0, height), rand(0, width), rand(0, height), line_color);
			let i -= 1;
        }

        ob_start();
        imagepng(image);
        let image_data = ob_get_contents();
        ob_end_clean();

        mt_srand(mt_rand(100000, 999999));
		
		var iv;
		let iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length("AES-128-CBC"));

        let encrypted = openssl_encrypt(
            "_DDCAPTCHA=" . captcha . "=" . (time() + 1 * 60),
            "aes128",
            captcha,
			0,
			iv
        ) . base64_encode(iv);
		
        imagedestroy(image);

		return "<div class=\"dd-captcha-img\"><img src=\"data:image/png;base64," . base64_encode(image_data) . "\" alt=\"captcha\"/></div>" .
			"<input name=\"dd_captcha\" class=\"dd-captcha-input\" required/>" .
			"<input name=\"_DDCAPTCHA\" type=\"hidden\" value=\"" . encrypted . "\"/>";
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

        var colours = [
            "visitors": "#00c129",
            "unique": "#1D8CF8",
            "bot": "#E14ECA"
        ], values, value;

        //I'm reusing vars here so take note!
        let model = "SELECT ";

        //The Year.
        let values = date("Y");
        let value = 1;
        while (value <= 12) {
            //The Month.
            let data = value;
            if (data < 10) {
                let data = "0" . data;
            }

            let model .= "(SELECT count(id) FROM stats WHERE created_at BETWEEN '" . values . "-" .
                    data . "-01' AND '" . values . "-" .
                    data . "-31') AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . data . "-01"))) . "_visitors,";

            let model .= "(SELECT count(*) FROM (SELECT count(id) FROM stats WHERE bot IS NULL AND 
                    created_at BETWEEN '" . values . "-" .
                    data . "-01' AND '" . values . "-" .
                    data . "-31' GROUP BY visitor) AS total) AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . data . "-01"))) . "_unique,";

            let model .= "(SELECT count(id) FROM stats WHERE bot IS NOT NULL AND 
                    created_at BETWEEN '" . values . "-" . data . "-01' AND '" . values . "-" .
                    data . "-31') AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . data . "-01"))) . "_bot,";
            let value = value + 1;
        }
        let data = database->all(rtrim(model, ','));

        let values = [];
        for titles in data {
            for model, value in get_object_vars(titles) {
                let value = explode("_", model);
                let value = array_pop(value);
                if (!isset(values[value])) {
                    let values[value] = [];
                }
                let values[value][] = titles->{model};
            }
        }
        let html .= "<div class='box'><div class='box-title'><span>annual stats</span></div><div class='box-body'>
        <canvas id='visitors' width='600' height='200'></canvas></div></div>
        <script type='text/javascript'>
        var ctx = document.getElementById('visitors').getContext('2d');
        var orders = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
                datasets: [";                    
        
        for titles, data in values {
            let html .= "
            {
                label: '" . ucwords(titles) . "',
                data: [". rtrim(implode(",", data), ",") . "],
                fill: false,
                backgroundColor: '" . colours[titles] . "',
                borderColor: '" . colours[titles] . "',
                tension: 0.1
            },";
        }

        let html .= "]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
        </script>";

        let html .= "<div style='display:flex;column-gap: 20px;'>";

        let model = "SELECT count(id) AS total, bot FROM stats WHERE bot IS NOT NULL ";
        let model .= "GROUP BY bot ORDER BY total DESC";
        let data = database->all(model);

        //Height
        let model = count(data) * 30;
        let value = (model < 200) ? 200 : model;

        let html .= "<div class='box'><div class='box-title'><span>bots</span></div><div class='box-body'>
        <canvas id='bots' width='505' height='" . value . "'></canvas></div></div>
        <script type='text/javascript'>
        var ctx_bots = document.getElementById('bots').getContext('2d');
        var bots = new Chart(ctx_bots, {
            type: 'horizontalBar',
            data: {";
        
        let colours = [];
        let values = [];
        let titles = [];

        for value in data {
            let titles[] = "'" . value->bot . "'";
            let values[] = value->total;
            let colours[] = "'#" . substr(md5(value->bot), 3, 6) . "'";
        }
        let html .= "labels: [" . implode(",", titles) . "],
                datasets: [
                    {
                        label: 'bots',
                        data: [" . implode(",", values) . "],
                        backgroundColor: [" . implode(",", colours) . "],
                        borderColor: '#5E5E60',
                        borderWidth: 0.4
                    },
                ]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                legend: {
                    display: false
                },
                plugins: {
                    legend: {
                        position: 'right'
                    },
                    title: {
                        display: false
                    }
                }
            }
        });
        </script>";

        let model = "SELECT count(id) AS total, referer FROM stats WHERE referer IS NOT NULL ";
        let model .= "GROUP BY referer ORDER BY total DESC";
        let data = database->all(model);

        
        let html .= "<div class='box'><div class='box-title'><span>referrers</span></div><div class='box-body'>
        <canvas id='referrers' width='505' height='400'></canvas></div></div></div>
        <script type='text/javascript'>
        var ctx_referrers = document.getElementById('referrers').getContext('2d');
        var referrers = new Chart(ctx_referrers, {
            type: 'doughnut',
            data: {";
        
        let colours = [];
        let values = [];
        let titles = [];

        for value in data {
            let titles[] = "'" . value->referer . "'";
            let values[] = value->total;
            let colours[] = "'#" . substr(md5(value->referer), 3, 6) . "'";
        }
        let html .= "labels: [" . implode(",", titles) . "],
                datasets: [
                    {
                        label: 'referrers',
                        data: [" . implode(",", values) . "],
                        backgroundColor: [" . implode(",", colours) . "],
                        borderColor: '#5E5E60',
                        borderWidth: 0.4
                    },
                ]
            },
            options: {
            }
        });
        </script>";

        return html;
    }

    public function login(string path)
    {
        var titles, html, database, model, data = [];
        let titles = new Titles();

        let html = titles->page("let me in", "/assets/login.png");

        if (!empty(_POST)) {
            if (isset(_POST["login"])) {
                if (!this->validate(_POST, ["name", "password", "dd_captcha"])) {
                    let html .= this->missingRequired();
                } else {
                    if (!this->validateCaptcha()) {
                        let html .= this->missingRequired("invalid captcha");
                    } else {
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
                <div class='input-group'><span>captcha<span class='required'>*</span></span>" . this->captcha() . "</div>
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

    private function validateCaptcha()
	{
		if (!isset(_REQUEST["dd_captcha"])) {
			return false;
		}

		var splits, iv, encrypted, token;
		let splits = explode("=", _REQUEST["_DDCAPTCHA"]);
		
		let encrypted = splits[0];
		unset(splits[0]);

		let iv = base64_decode(implode("=", splits));

		let token = openssl_decrypt(
            encrypted,
            "aes128",
            _REQUEST["dd_captcha"],
            0,
			iv
        );

        if (!token) {
            return false;
        }

        let splits = explode("=", token);

        if (splits[0] != "_DDCAPTCHA") {
            return false;
        }

        if (splits[1] != _REQUEST["dd_captcha"]) {
            return false;
        }

		if (time() > splits[2]) {
            return false;
        }

        return true;
	}
}