/**
 * Dumb Dog dashboard
 *
 * @package     DumbDog\Controllers\Dashboard
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\AccessException;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Ui\Captcha;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Inputs;
use DumbDog\Ui\Gfx\Tiles;
use DumbDog\Ui\Gfx\Titles;

class Dashboard extends Controller
{
    public function index(string path)
    {
        var titles, html, model, data = [], icons;
        let titles = new Titles();
        let icons = new Icons();

        let html = titles->page("Dashboard", "dashboard");

        let data["id"] = _SESSION["dd"];
        let model = this->database->get("SELECT * FROM users WHERE id=:id", data);
        if (model) {
            let html .= "
            <div class='dd-h2 dd-page-sub-title'>
                <div>Whaddup " . (model->nickname ? model->nickname : model->name) . "!</div>
            </div>";
        }

        let model = count(this->database->all("SELECT count(id) FROM messages WHERE status='unread' AND deleted_at IS NULL"));

        let html .= "
        <div class='dd-page-toolbar'>
            <a 
                href='" . this->cfg->dumb_dog_url  . "/messages' 
                class='dd-link dd-round'
                title='Messages'>" .
                icons->messages() .
                (model ? "<span class='dd-icon-indicator'>" . model . "</span>" : "") .
            "</a>
        </div>";

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
        let data = this->database->all(rtrim(model, ','));

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
        let html .= "
        <div class='dd-box'>
            <div class='dd-box-title'>
                <span>annual stats</span>
            </div>
            <div class='dd-box-body'>
                <canvas id='visitors' width='600' height='200'></canvas>
            </div>
        </div>
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

        let model = "SELECT count(id) AS total, bot FROM stats WHERE bot IS NOT NULL ";
        let model .= "GROUP BY bot ORDER BY total DESC";
        let data = this->database->all(model);

        //Height
        let model = count(data) * 30;
        let value = (model < 200) ? 200 : model;

        let html .= "
        <div class='dd-box'>
            <div class='dd-box-title'>
                <span>bots</span>
            </div>
            <div class='dd-box-body'>
                <canvas id='bots' width='505' height='" . value . "'></canvas>
            </div>
        </div>
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
        let data = this->database->all(model);

        
        let html .= "
        <div class='dd-box'>
            <div class='dd-box-title'>
                <span>referrers</span>
            </div>
            <div class='dd-box-body'>
                <canvas id='referrers' width='505' height='400'></canvas>
            </div>
        </div>
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
        var titles, html, model, data = [], captcha, input;

        let input = new Inputs();
        let titles = new Titles();
        let captcha = new Captcha();

        let html = titles->page("let me in", "login");

        if (!empty(_POST)) {
            if (isset(_POST["login"])) {
                if (!this->validate(_POST, ["name", "password", "dd_captcha"])) {
                    let html .= this->missingRequired();
                } else {
                    if (!captcha->validate()) {
                        let html .= this->missingRequired("invalid captcha");
                    } else {
                        let data["name"] = _POST["name"];
                        
                        let model = this->database->get("SELECT * FROM users WHERE name=:name", data);
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
                        this->redirect(this->cfg->dumb_dog_url);
                    }
                }
            }
        }

        let html .= "
        <form method='post' action='" . this->cfg->dumb_dog_url . "/" . path . "?back=" . urlencode(trim(path, "/")) . "'>
            <div id='dd-login' class='dd-box'>
                <div class='dd-box-body'>" .
                    input->text("Username", "name", "Please enter your username", true) .
                    input->password("Password", "password", "Please enter your password", true) .   
                    "<div class='dd-input-group'>
                        <label>captcha<span class='dd-required'>*</span></label>" .
                        captcha->draw() .
                    "</div>
                </div>
                <div class='dd-box-footer'>
                    <button type='submit' name='login' class='dd-button'>login</button>
                </div>
            </div>
        </form>";

        return html;
    }

    public function logout(string path)
    {   
        let _SESSION["dd"] = null;
        session_unset();
        session_destroy();
        this->redirect(this->cfg->dumb_dog_url . "/the-pound");
    }
}