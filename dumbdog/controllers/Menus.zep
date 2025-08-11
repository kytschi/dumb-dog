/**
 * DumbDog menus builder
 *
 * @package     DumbDog\Controllers\Menus
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;

class Menus extends Content
{
    public global_url = "/menus";
    public title = "Menus";
    public type = "menu";
    public required = ["name", "title"];
    public list = [
        "name|with_tags",
        "parent",
        "title"
    ];

    public routes = [
        "/menus/add": [
            "Menus",
            "add",
            "create a menu"
        ],
        "/menus/edit": [
            "Menus",
            "edit",
            "edit the menu"
        ],
        "/menus": [
            "Menus",
            "index",
            "menus"
        ]
    ];

    public function add(path)
    {
        var html, data, model;

        let html = this->titles->page("Create a menu", "menus");

        let model = new \stdClass();

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["type"] = this->type;
                    let data["created_by"] = this->database->getUserId();
                    let data = this->setData(data);
                    
                    let status = this->database->execute(
                        "INSERT INTO content 
                            (
                                id,
                                name,
                                title,
                                sub_title,
                                url,
                                tags,
                                type,
                                parent_id,
                                sitemap_include,
                                created_at,
                                created_by,
                                updated_at,
                                updated_by
                            ) 
                        VALUES 
                            (
                                :id,
                                :name,
                                :title,
                                :sub_title,
                                :url,
                                :tags,
                                :type,
                                :parent_id,
                                0,
                                NOW(),
                                :created_by,
                                NOW(),
                                :updated_by
                            )",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the menu");
                        let html .= this->consoleLogError(status);
                    } else {
                        let model->id = data["id"];
                        this->updateExtra(model, path);
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Menu has been saved");
        }

        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->sub_title = "";
        let model->url = "";
        let model->sort = "";
        let model->content_id = "";

        let html .= this->render(model);

        return html;
    }

    private function addItem(string id)
    {
        var data = [
            "id": this->database->uuid(),
            "parent_id": id,
            "name": _POST["add_stack"],
            "title": _POST["add_stack"],
            "type": this->type . "-item",
            "created_by": this->getUserId(),
            "updated_by": this->getUserId()
        ], status;
        
        let status = this->database->execute(
            "INSERT INTO content 
                (
                    id,
                    parent_id,
                    name,
                    title,
                    type,
                    sitemap_include,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by
                ) 
            VALUES 
                (
                    :id,
                    :parent_id,
                    :name,
                    :title,
                    :type,
                    0,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by
                )",
            data
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to save the menu item");
        }

        var model;
        let model = new \stdClass();
        let model->id = data["id"];
        this->updateExtra(model);
    }

    private function contentSelect(selected = "", string name = "link_to")
    {
        var select = ["": "no content"], data;
        let data = this->database->all(
            "SELECT 
                *,
                CONCAT(name, ' (', type, ')') AS name 
            FROM content 
            WHERE type IN ('page', 'page-category', 'blog', 'blog-category', 'event') 
            ORDER BY name"
        );
        var iLoop = 0;

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Content",
            name,
            "Link to a piece of content",
            select,
            false,
            selected
        );
    }

    public function deleteItem(string id, string item_id)
    {
        var data = [], status = false;

        if (this->cfg->save_mode == true) {
            let data["id"] = item_id;
            let data["updated_by"] = this->getUserId();
            let status = this->database->execute("
                UPDATE 
                    content
                SET
                    deleted_at=NOW(),
                    deleted_by=:updated_by,
                    updated_at=NOW(),
                    updated_by=:updated_by
                WHERE 
                    id=:id",
                data
            );
        } else {
            let status = true;
        }

        if (!is_bool(status)) {
            throw new Exception("Failed to delete the menu item");
        } else {
            this->redirect(this->global_url . "/edit/" . id . "?deleted=true&scroll=stack-tab");
        }
    }

    public function edit(path)
    {
        var html, model, data = [];

        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                menus.*,
                content.*,
                files.id AS image_id,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail  
            FROM content 
            JOIN menus ON menus.content_id = content.id 
            LEFT JOIN files ON files.resource_id = content.id AND files.deleted_at IS NULL 
            WHERE content.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Menu not found");
        }

        let html = this->titles->page("Edit the menu", "edit");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("Menu item has been deleted");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let model->stacks = this->database->all("
            SELECT 
                menus.*, 
                content.* 
            FROM content 
            JOIN menus ON menus.content_id = content.id 
            WHERE parent_id='" . model->id . "' AND deleted_at IS NULL AND type=:type
            ORDER BY sort ASC",
            [
                "type": this->type . "-item"
            ]
        );

        if (!empty(_POST)) {
            var status = false, err;

            let path = this->global_url . "/edit/" . model->id;
            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("content", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("content", path);
                }
            }

            if (isset(_POST["stack_delete"])) {
                if (!empty(_POST["stack_delete"])) {
                    this->deleteItem(model->id, _POST["stack_delete"]);
                }
            }

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = path . "?saved=true";

                if (isset(_POST["add_stack"])) {
                    if (!empty(_POST["add_stack"])) {
                        this->addItem(model->id);
                        let path = path . "&scroll=stack-tab";
                    }
                }

                let data = this->setData(data);
                
                let status = this->database->execute(
                    "UPDATE content SET 
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        url=:url,
                        parent_id=:parent_id,
                        tags=:tags,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the menu");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        this->updateExtra(model);
                        this->updateStacks();
                        this->redirect(path);
                    } catch ValidationException, err {
                        let html .= this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the menu");
        }

        let html .= this->render(model, "edit");
        return html;
    }

    public function parentSelect(selected = null, exclude = null)
    {
        var select = ["": "no parent"], data;
        let data = this->database->all(
            "SELECT * FROM content WHERE type=:type" .
            (exclude ? " AND id != '" . exclude . "'" : "") . " 
            ORDER BY name",
            [
                "type": this->type
            ]
        );
        var iLoop = 0;

        if (isset(_POST["parent_id"])) {
            let selected = _POST["parent_id"];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Parent",
            "parent_id",
            "Is this menu a child of another?",
            select,
            false,
            selected
        );
    }

    public function render(model, mode = "add")
    {
        var html;

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='content-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->text("Name", "name", "Name the menu", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title of the menu", true, model->title) .
                                    this->parentSelect(model->parent_id, model->id) . 
                                    this->inputs->text("Alt text", "sub_title", "The display alt text for the menu", false, model->sub_title) . 
                                    this->inputs->text("URL", "url", "URL of the menu", false, model->url) .
                                    this->contentSelect(model->link_to) . 
                                    this->inputs->toggle("New window", "new_window", false, model->new_window) . 
                                    this->inputs->tags("Tags", "tags", "Tag the menu", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>";

        if (mode == "edit") {
            let html .= this->renderStacks(model);
        }

        let html .= "</div>" .
                this->renderSidebar(model, mode) .
            "</div>
        </form>";

        return html;
    }

    public function renderList(path)
    {
        var data = [], query;

        let data["type"] = this->type;

        let query = "
            SELECT
                main.*,
                IFNULL(parent_page.name, 'No parent') AS parent 
            FROM content AS main
            LEFT JOIN content AS parent_page ON parent_page.id=main.parent_id 
            WHERE main.type=:type";
        if (isset(_POST["q"])) {
            let query .= " AND main.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND main.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY main.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderSidebar(model, mode = "add")
    {
        var html;

        let html = "
            <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
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
                                    "Create a new " . str_replace("-", " ", this->type)
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
                                "Menu
                            </span>
                        </div>
                    </li>";
        if (mode == "edit") {
            let html .= "
                    <li class='dd-nav-item' role='presentation'>
                        <div class='dd-nav-link dd-flex'>
                            <span 
                                data-tab='#stack-tab'
                                class='dd-tab-link dd-col'
                                role='tab'
                                aria-controls='stack-tab' 
                                aria-selected='true'>" .
                                this->buttons->tab("stack-tab") .
                                "Items
                            </span>
                        </div>
                    </li>";
        }

        let html .= "
            </ul>";

        return html;
    }

    public function renderStacks(model)
    {
        var item, html = "";

        let html = "
        <div id='stack-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title dd-flex dd-border-none'>
                        <div class='dd-col'>Items</div>
                        <div class='dd-col-auto'>" .
                            this->inputs->inputPopup("create-stack", "add_stack", "Create a new item") .
                    "   </div>
                    </div>
                </div>";

        if (count(model->stacks)) {
            for item in model->stacks {
                let html .= "
                    <div class='dd-box'>
                        <div class='dd-box-title dd-flex'>
                            <div class='dd-col'>" . item->name . "</div>
                            <div class='dd-col-auto'>" . 
                                this->buttons->delete(item->id, "stack-delete-" . item->id, "stack_delete", "Delete the item") .
                        "   </div>
                        </div>
                        <div class='dd-box-body'>" .
                            this->inputs->text("Name", "stack_name[" . item->id . "]", "The name of the menu item", true, item->name) .
                            this->inputs->text("Title", "stack_title[" . item->id . "]", "The title of the menu item", false, item->title) .
                            this->inputs->text("Alt text", "stack_sub_title[" . item->id . "]", "The alt text for the menu item", false, item->sub_title) . 
                            this->inputs->text("URL", "stack_url[" . item->id . "]", "The URL for the menu item", false, item->url) . 
                            this->contentSelect(item->link_to, "stack_link_to[" . item->id . "]") . 
                            this->inputs->toggle("New window", "stack_new_window[" . item->id . "]", false, item->new_window) . 
                            this->inputs->number("Sort", "stack_sort[" . item->id . "]", "Sort the menu item", false, item->sort) .
                        "</div>
                    </div>";
            }
        }

        let html .="
            </div>
        </div>";

        return html;
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->add(this->global_url . "/add") .
        "</div>";
    }

    private function setData(array data)
    {
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["sub_title"] = _POST["sub_title"];
        let data["url"] = _POST["url"];
        let data["parent_id"] = _POST["parent_id"];
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);
        let data["updated_by"] = this->database->getUserId();       

        return data;
    }

    private function setMenuData(array data = [])
    {
        let data["new_window"] = isset(_POST["new_window"]) ? 1 : 0;
        let data["link_to"] = _POST["link_to"];
        
        return data;
    }

    public function updateExtra(model = null, path = "")
    {
        var data, status = false, required = [];

        let data = this->database->get("
            SELECT *
            FROM menus 
            WHERE content_id='" . model->id . "'");

        if (!empty(data)) {
            if (!this->validate(_POST, required)) {
                throw new ValidationException("Missing required data");
            }

            let data = this->setMenuData(["id": data->id]);
                        
            let status = this->database->get("
                UPDATE menus SET
                    link_to=:link_to,
                    new_window=:new_window 
                WHERE id=:id",
                data
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to update the menu");
            }
        } else {
            let data = this->setMenuData(["content_id": model->id]);

            let status = this->database->get("
                INSERT INTO menus 
                (
                    id,
                    content_id,
                    link_to,
                    new_window
                ) VALUES
                (
                    UUID(),
                    :content_id,
                    :link_to,
                    :new_window
                )",
                data
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to create the menu");
            }
        }
    }

    public function updateStacks()
    {
        if (!isset(_POST["stack_name"])) {
            return;
        }

        var id, name, status, data = [], model;
        let model = new \stdClass();

        for id, name in _POST["stack_name"] {
            let data = [
                "id": id,
                "name": "",
                "title": "",
                "sub_title": "",
                "sort": 0
            ];

            if (empty(name)) {
                throw new ValidationException("Missing name for menu item");
            }
            let data["name"] = name;

            if (isset(_POST["stack_title"][id])) {
                let data["title"] = _POST["stack_title"][id];
            }
            if (isset(_POST["stack_sub_title"][id])) {
                let data["sub_title"] = _POST["stack_sub_title"][id];
            }
            if (isset(_POST["stack_url"][id])) {
                let data["url"] = _POST["stack_url"][id];
            }
            if (isset(_POST["stack_sort"][id])) {
                let data["sort"] = intval(_POST["stack_sort"][id]);
            }

            let status = this->database->execute(
                "UPDATE content SET 
                    name=:name,
                    title=:title,
                    sub_title=:sub_title,
                    url=:url,
                    sort=:sort 
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the menu item");
            }

            let model->id = data["id"];

            if (isset(_POST["stack_new_window"][id])) {
                let _POST["new_window"] = 1;
            } else {
                unset(_POST["new_window"]);
            }
            let _POST["link_to"] = isset(_POST["stack_link_to"][id]) ? _POST["stack_link_to"][id] : null;

            this->updateExtra(model);
        }
    }
}