/**
 * Dumb Dog menu builder
 *
 * @package     DumbDog\Ui\Menu
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Ui;

use DumbDog\Controllers\Controller;

class Menu
{
    protected cfg;

    public function __construct(object cfg)
    {
        let this->cfg = cfg;

    }

    public function build()
    {
        var total, controller;

        let controller = new Controller(this->cfg);

        echo "
        <nav>
            <div class='container'>
                <a class='navbar-brand'
                    href='" . this->cfg->dumb_dog_url . "'
                    rel='tooltip' 
                    title='Go to the dashboard'
                    data-placement='bottom'>
                    Fremen
                </a>
                <button 
                    type='button'
                    data-toggle='collapse'
                    data-target='#navigation'
                    aria-controls='navigation' 
                    aria-expanded='false'
                    aria-label='Toggle navigation'>
                    <span class='navbar-toggler-icon'>
                        <span class='navbar-toggler-bar bar1'></span>
                        <span class='navbar-toggler-bar bar2'></span>
                        <span class='navbar-toggler-bar bar3'></span>
                    </span>
                </button>
                <div id='menu' class='end'>
                    <div class='input-group'>
                        <span class='input-group-text'>
                            <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                                <path d='M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0'/>
                            </svg>
                        </span>
                        <input 
                            type='text' 
                            class='form-control' 
                            placeholder='Search...'>
                    </div>
                    
                    <a>
                        <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                            <path d='M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2m.995-14.901a1 1 0 1 0-1.99 0A5 5 0 0 0 3 6c0 1.098-.5 6-2 7h14c-1.5-1-2-5.902-2-7 0-2.42-1.72-4.44-4.005-4.901'/>
                        </svg>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/messages'>
                        <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                            <path d='M.05 3.555A2 2 0 0 1 2 2h12a2 2 0 0 1 1.95 1.555L8 8.414zM0 4.697v7.104l5.803-3.558zM6.761 8.83l-6.57 4.027A2 2 0 0 0 2 14h12a2 2 0 0 0 1.808-1.144l-6.57-4.027L8 9.586zm3.436-.586L16 11.801V4.697z'/>
                        </svg>";
        let total = controller->database->get(
            "SELECT 
                count(id) AS total 
            FROM 
                messages 
            WHERE 
                status='unread'");
        if (total->total) {
            echo "<span>" . total->total . "</span>";
        }
        echo "      </a>
                    <a href='" . this->cfg->dumb_dog_url . "/appointments'>
                        <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                            <path d='M4 .5a.5.5 0 0 0-1 0V1H2a2 2 0 0 0-2 2v1h16V3a2 2 0 0 0-2-2h-1V.5a.5.5 0 0 0-1 0V1H4zM16 14V5H0v9a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2M9.5 7h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5m3 0h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5M2 10.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5zm3.5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5'/>
                        </svg>";
        let total = controller->database->get(
            "SELECT 
                count(id) AS total
            FROM 
                appointments 
            WHERE 
                user_id=:user_id AND on_date >= NOW() AND free_slot = 0",
            [
                "user_id": controller->getUserId()
            ]
        );
        if (total->total) {
            echo "<span>" . total->total . "</span>";
        }
        echo "      </a>
                    <a>
                        <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                            <path d='M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0'/>
                            <path fill-rule='evenodd' d='M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1'/>
                        </svg>
                    </a>
                </div>
            </div>
        </nav>";
    }

    public function quickmenu()
    {
        var controller;

        let controller = new Controller(this->cfg);

        echo "<div id='dd-quick-menu' style='display: none;'>
            <div class='dd-container'>
                <div class='dd-row'>
                    <div id='dd-quick-menu-header' class='dd-col-12'>
                        <button type='button' onclick='showQuickMenu()' class='dd-float-end dd-button-blank'>
                            <svg xmlns='http://www.w3.org/2000/svg' width='32' height='32' fill='currentColor' viewBox='0 0 16 16'>
                                <path d='M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16'/>
                                <path d='M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708'/>
                            </svg>
                        </button>
                    </div>
                    <div class='dd-col-12'>
                        <div id='dd-apps'>
                            <a href='" . this->cfg->dumb_dog_url . "' title='Go to the dashboard' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-dashboard'></span>
                                    <label>Dashboard</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/pages' title='Managing the pages' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-pages'></span>
                                    <label>Pages</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/products' title='Managing the products' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-products'></span>
                                    <label>Products</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/menus' title='Managing the menus' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-menus'></span>
                                    <label>Menus</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/content-stacks' title='Managing the content stacks' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-stacks'></span>
                                    <label>Content stacks</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/socials' title='Managing the social media links' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-social-media'></span>
                                    <label>Social media</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/reviews' title='Managing the reviews' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-reviews'></span>
                                    <label>Reviews</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/appointments' title='Go to the appointments' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-appointments'></span>
                                    <label>Appointments</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/currencies' title='Manage the currencies' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-currencies'></span>
                                    <label>Currencies</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/taxes' title='Manage the taxes' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-taxes'></span>
                                    <label>Taxes</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/payment-gateways' title='Manage the payment gateways' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-payment-gateways'></span>
                                    <label>Payment gateways</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/countries' title='Manage the countries' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-countries'></span>
                                    <label>Countries</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/settings' title='Site wide settings' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-settings'></span>
                                    <label>Settings</label>
                                </div>
                            </a>
                            <a href='" . this->cfg->dumb_dog_url . "/give-up' title='Log me out' class='dd-box'>
                                <div class='dd-box-body'>
                                    <span class='dd-icon dd-icon-logout'></span>
                                    <label>Logout</label>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id='dd-quick-menu-button' onclick='showQuickMenu()'>
            <div class='dd-round dd-icon dd-icon-dumbdog'>&nbsp;</div>
        </div>";
    }
}
