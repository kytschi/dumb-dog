/**
 * Dumb Dog menu builder
 *
 * @package     DumbDog\Ui\Menu
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Ui;

use DumbDog\Controllers\Controller;
use DumbDog\Ui\Gfx\Icons;

class Menu
{
    protected cfg;
    protected icons;

    public function __construct()
    {
        let this->cfg = constant("CFG");
        let this->icons = new Icons();
    }

    public function build()
    {
        var total, controller;

        let controller = new Controller();

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
                    
                    <a>" . this->icons->dashboard() . "</a>
                    <a href='" . this->cfg->dumb_dog_url . "/messages'>"
                        . this->icons->messages();
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
                    <a href='" . this->cfg->dumb_dog_url . "/notes'>
                    " . this->icons->notes();
        let total = controller->database->get(
            "SELECT count(id) AS total FROM notes 
            WHERE user_id=:user_id AND resource_id IS NULL AND deleted_at IS NULL",
            [
                "user_id": controller->getUserId()
            ]
        );
        if (total->total) {
            echo "<span>" . total->total . "</span>";
        }
        echo "      </a>
                    <a href='" . this->cfg->dumb_dog_url . "/appointments'>
                        " . this->icons->appointments();
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
        var controller, total, indicator = false;

        let controller = new Controller();
    
        echo "<div id='dd-quick-menu' style='display: none;'>
            <div class='dd-container'>
                <div id='dd-quick-menu-header' class='dd-flex'>
                    <div id='dd-search-box' class='dd-col'>
                        <div class='dd-box'>
                            <div class='dd-box-body'>
                                <input 
                                    class='dd-form-control' 
                                    name='search'
                                    placeholder='What yah looking for?'>
                            </div>
                        </div>
                    </div>
                    <div class='dd-col-auto'>
                        <button type='button' onclick='showQuickMenu()' class='dd-button-blank'>" .
                            this->icons->cancel() .
                        "</button>
                    </div>
                </div>
                <div id='dd-apps'>
                    <a href='" . this->cfg->dumb_dog_url . "' title='Go to the dashboard' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->dashboard() .
                            "<label>Dashboard</label>
                        </div>
                    </a>";
                if (this->cfg->apps->crm || this->cfg->apps->cms) {
                    let total = controller->database->get("SELECT count(id) AS total FROM messages WHERE status='unread' AND deleted_at IS NULL");
                    if (total) {
                        let total = total->total;
                        if (total) {
                            let indicator = true;
                        }
                    }
                    echo "
                    <a href='" . this->cfg->dumb_dog_url . "/messages' title='Manage the messages' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->messages() .
                            "<label>Messages</label>" . 
                            (total ? "<span class='dd-icon-indicator'>" . total . "</span>" : "") .
                        "</div>
                    </a>";
                    let total = controller->database->get(
                        "SELECT count(appointments.id) AS total
                        FROM appointments 
                        JOIN content ON content.id=appointments.content_id 
                        WHERE user_id=:user_id AND content.deleted_at IS NULL",
                        [
                            "user_id": controller->database->getUserId()
                        ]
                    );
                    if (total) {
                        let total = total->total;
                        if (total) {
                            let indicator = true;
                        }
                    }
                    echo "
                    <a href='" . this->cfg->dumb_dog_url . "/appointments' title='Go to the appointments' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->appointments() .
                            "<label>Appointments</label>" . 
                            (total ? "<span class='dd-icon-indicator'>" . total . "</span>" : "") .
                        "</div>
                    </a>";
                }
                let total = controller->database->get(
                    "SELECT count(id) AS total FROM notes 
                    WHERE user_id=:user_id AND resource_id IS NULL AND deleted_at IS NULL",
                    [
                        "user_id": controller->getUserId()
                    ]
                );
                if (total) {
                    let total = total->total;
                    if (total) {
                        let indicator = true;
                    }
                }
                echo "
                <a href='" . this->cfg->dumb_dog_url . "/notes' title='Go to my notes' class='dd-box'>
                    <div class='dd-box-body'>" . 
                        this->icons->notes() .
                        "<label>Notes</label>" . 
                        (total ? "<span class='dd-icon-indicator'>" . total . "</span>" : "") .
                    "</div>
                </a>";
                if (this->cfg->apps->cms) {
                    echo "
                    <a href='" . this->cfg->dumb_dog_url . "/pages' title='Managing the pages' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->pages() .
                            "<label>Pages</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/blog-posts' title='Managing the blog' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->blog() .
                            "<label>Blog</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/menus' title='Managing the menus' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->menus() .
                            "<label>Menus</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/content-stacks' title='Managing the content stacks' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->contentStacks() .
                            "<label>Content stacks</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/socials' title='Managing the social media links' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->socialmedia() .
                            "<label>Social media</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/reviews' title='Managing the reviews' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->reviews() .
                            "<label>Reviews</label>
                        </div>
                    </a>";
                }
                if (this->cfg->apps->commerce) {
                    echo "
                    <a href='" . this->cfg->dumb_dog_url . "/products' title='Managing the products' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->products() .
                            "<label>Products</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/currencies' title='Manage the currencies' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->currencies() .
                            "<label>Currencies</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/taxes' title='Manage the taxes' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->taxes() .
                            "<label>Taxes</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/payment-gateways' title='Manage the payment gateways' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->paymentGateways() .
                            "<label>Payment gateways</label>
                        </div>
                    </a>";
                }
                if (this->cfg->apps->crm) {
                    echo "
                    <a href='" . this->cfg->dumb_dog_url . "/leads' title='Manage the leads' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->leads() .
                            "<label>Leads</label>
                        </div>
                    </a>";
                }
                echo "
                    <a href='" . this->cfg->dumb_dog_url . "/api-apps' title='Go to the API apps' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->apiapps() .
                            "<label>API Apps</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/settings' title='Site wide settings' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->settings() .
                            "<label>Settings</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/users' title='System users' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->users() .
                            "<label>Users</label>
                        </div>
                    </a>
                    <a href='" . this->cfg->dumb_dog_url . "/give-up' title='Log me out' class='dd-box'>
                        <div class='dd-box-body'>" . 
                            this->icons->logout() .
                            "<label>Logout</label>
                        </div>
                    </a>
                </div>
            </div>
        </div>
        <div id='dd-quick-menu-button' onclick='showQuickMenu()'>
            <div class='dd-round dd-icon-dumbdog'>" .
                this->icons->dumbdog() .
                (indicator ? "<span class='dd-icon-indicator'></span>" : "") .
            "</div>
        </div>";
    }
}
