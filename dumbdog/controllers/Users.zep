/**
 * Dumb Dog users builder
 *
 * @package     DumbDog\Controllers\Users
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Controllers\Groups;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;

class Users extends Content
{
    public global_url = "/users";
    public type = "user";
    public list = [
        "name|with_tags",
        "group",
        "status"
    ];

    public required = ["name", "nickname", "group_id"];

    public routes = [
        "/users/add": [
            "Users",
            "add",
            "add a user"
        ],
        "/users/edit": [
            "Users",
            "edit",
            "edit the user"
        ],
        "/users": [
            "Users",
            "index",
            "users"
        ]
    ];

    public function add(path)
    {
        var html, model;
        let html = this->titles->page("Add a user", "add");
        
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->name = "";
        let model->nickname = "";
        let model->group_id = "";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var data = [], status = false, err;

                let this->required = array_merge(this->required, ["password", "password_check"]);

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    try {
                        if (_POST["password"] != _POST["password_check"]) {
                            throw new \Exception("passwords do not match!");
                        }

                        let data = this->setData(data, null, model);
                        let data["password"] = password_hash(_POST["password"], PASSWORD_DEFAULT);
                        let data["created_by"] = this->database->getUserId();
                        let data["id"] = this->database->uuid();
                        
                        let status = this->database->execute(
                            "INSERT INTO users 
                                (
                                    id,
                                    name,
                                    nickname,
                                    group_id,
                                    `password`,
                                    created_at,
                                    created_by,
                                    updated_at,
                                    updated_by,
                                    status
                                ) 
                            VALUES 
                                (
                                    :id,
                                    :name,
                                    :nickname,
                                    :group_id,
                                    :password,
                                    NOW(),
                                    :created_by,
                                    NOW(),
                                    :updated_by,
                                    'active'
                                )",
                            data
                        );

                        if (!is_bool(status)) {
                            let html .= this->saveFailed("Failed to save the user");
                            let html .= this->consoleLogError(status);
                        } else {
                            if (isset(_FILES["file"]["name"])) {
                                if (!empty(_FILES["file"]["name"])) {
                                    this->files->addResource("file", data["id"], "profile");
                                }
                            }
                            let html .= this->saveSuccess("I've saved the user");
                        }
                    } catch \Exception, err {
                        let html .= this->saveFailed(err->getMessage());
                    }
                }
            }
        }

        let html .= this->render(model);

        return html;
    }

    public function edit(path)
    {
        var html, model, data = [];

        let data["id"] = this->getPageId(path);
        let model = this->database->get(
            "SELECT
                users.*,
                CONCAT('" . this->files->folder . "/thumb-', filename) AS profile 
            FROM users 
            LEFT JOIN files ON files.resource_id=users.id AND resource='profile' 
            WHERE users.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("User not found");
        }

        let html = this->titles->page("Edit the user", "edit");
        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }
        
        if (!empty(_POST)) {
            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("users", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("users", path);
                }
            }

            if (isset(_POST["save"])) {
                var status = false, query;

                if (!this->validate(_POST, ["name", "nickname"])) {
                    let html .= this->missingRequired();
                } else {
                    let query = "
                        UPDATE
                            users
                        SET 
                            name=:name,
                            nickname=:nickname,
                            group_id=:group_id,
                            updated_at=NOW(),
                            updated_by=:updated_by";

                    if (isset(_POST["password"]) && isset(_POST["password_check"])) {
                        if (!empty(_POST["password"]) && !empty(_POST["password_check"])) {
                            if (_POST["password"] != _POST["password_check"]) {
                                throw new \Exception("passwords do not match!");
                            }
                            let data["password"] = password_hash(_POST["password"], PASSWORD_DEFAULT);
                            let query .= ", password=:password";
                        }
                    }

                    let query .= " WHERE id=:id";

                    let data = this->setData(data, null, model);

                    let status = this->database->execute(
                        query,
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the user");
                        let html .= this->consoleLogError(status);
                    } else {
                        if (isset(_FILES["file"]["name"])) {
                            if (!empty(_FILES["file"]["name"])) {
                                this->files->addResource("file", data["id"], "profile");
                            }
                        }
                        this->redirect(this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the user");
        }

        let html .= this->render(model);

        return html;
    }

    public function index(path)
    {
        var html;        
        let html = this->titles->page("Users", "users");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the user");
        }

        let html .= this->renderToolbar();

        let html .= 
            this->inputs->searchBox(this->global_url, "Search the users") .
            this->tags(path, "users") .
            this->renderList(path);
        
        return html;
    }

    public function render(model, mode = "add")
    {
        return "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs dd-mt-4'>
                <div class='dd-tabs-content dd-col'>
                    <div id='user-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                this->inputs->text("username", "name", "what is their username?", true, model->name) .
                                this->inputs->text("nickname", "nickname", "what shall I call them?", true, model->nickname) .
                                (new Groups())->groupSelect(model->group_id) . 
                                this->inputs->image("picture", "file", "upload a picture?", false, model->profile) .
                                this->inputs->password("password", "password", "sssh, it is our secret!") .
                                this->inputs->password("password check", "password_check", "same again please!") .
                                "</div>
                            </div>
                        </div>
                    </div>
                </div>" .
                this->renderSidebar(model, mode) .
            "</div>
        </form>";
    }

    public function renderList(path)
    {
        var data = [], query;

        let query = "
            SELECT
                users.*,
                groups.name AS `group` 
            FROM users
            LEFT JOIN groups ON groups.id=users.group_id 
            WHERE users.id IS NOT NULL";
        if (isset(_POST["q"])) {
            let query .= " AND users.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND users.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY users.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderSidebar(model, mode = "add")
    {
        var html = "";
        let html = "
        <ul class='dd-col dd-nav-tabs' role='tablist'>
            <li class='dd-nav-item' role='presentation'>
                <div id='dd-tabs-toolbar'>
                    <div id='dd-tabs-toolbar-buttons' class='dd-flex'>". 
                        this->buttons->generic(
                            this->global_url,
                            "",
                            "back",
                            "Go back to the list"
                        ) .
                        this->buttons->save() . 
                        this->buttons->generic(
                            this->global_url . "/add",
                            "",
                            "add",
                            "Add a new user"
                        );
        if (mode == "edit") {
            if (model->deleted_at) {
                let html .= this->buttons->recover(model->id);
            } else {
                let html .= this->buttons->delete(model->id);
            }
        }
        let html .= "</div>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#content-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='content-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("content-tab") .
                        "User
                    </span>
                </div>
            </li>
        </ul>";
        return html;
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->round(
                this->cfg->dumb_dog_url . "/groups",
                "groups",
                "groups",
                "Click to access the groups"
            ) .
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new user"
            ) .
        "</div>";
    }

    public function setData(array data, user_id = null, model = null)
    {
        let data["name"] = _POST["name"];

        if (model->name != data["name"]) {
            var user;                        
            let user = this->database->get(
                "SELECT * FROM users WHERE name=:name",
                [
                    "name": data["name"]
                ]
            );
            if (user) {
                throw new \Exception("username already taken");
            }
        }

        let data["nickname"] = _POST["nickname"];
        let data["group_id"] = _POST["group_id"];
        let data["updated_by"] = this->database->getUserId();

        return data;
    }
}