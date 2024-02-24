/**
 * DumbDog menus builder
 *
 * @package     DumbDog\Controllers\Menus
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
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
    public required = ["name"];
    public list = [
        "name|with_tags",
        "parent",
        "title"
    ];

    public function add(string path)
    {
        var html, data;

        let html = this->titles->page("Create a menu", "menus");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->database->getUserId();
                    let data = this->setData(data);
                    
                    let status = this->database->execute(
                        "INSERT INTO menus 
                            (id,
                            name,
                            title,
                            alt,
                            url,
                            tags,
                            parent_id,
                            content_id,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :title,
                            :alt,
                            :url,
                            :tags,
                            :parent_id,
                            :content_id,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the menu");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Menu has been saved");
        }

        var model;
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->alt = "";
        let model->url = "";
        let model->sort = "";
        let model->content_id = "";

        let html .= this->render(model);

        return html;
    }

    private function addItem(string id)
    {
        var data = [
            "menu_id": id,
            "name": _POST["add_stack"],
            "created_by": this->getUserId(),
            "updated_by": this->getUserId()
        ], status;
        
        let status = this->database->execute(
            "INSERT INTO menus 
                (id,
                menu_id,
                name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :menu_id,
                :name,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to save the menu item");
        }
    }

    private function contentSelect(selected = "", string name = "content_id")
    {
        var select = ["": "no content"], data;
        let data = this->database->all(
            "SELECT 
                *,
                CONCAT(name, ' (', type, ')') AS name 
            FROM 
                content 
            WHERE type IN ('page', 'blog-post', 'event') 
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
                    menus
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
            this->redirect(this->global_url . "/edit/" . id . "?deleted=true");
        }
    }

    public function edit(string path)
    {
        var html, model, data = [];

        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                menus.*,
                files.id AS image_id,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail  
            FROM menus 
            LEFT JOIN files ON files.resource_id = menus.id AND files.deleted_at IS NULL 
            WHERE menus.id=:id", data);

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
            SELECT menus.*
            FROM menus 
            WHERE menu_id='" . model->id . "' AND menus.deleted_at IS NULL
            ORDER BY sort ASC");
        if (!empty(_POST)) {
            var status = false, err;

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = this->global_url . "/edit/" . model->id;

                if (isset(_POST["delete"])) {
                    if (!empty(_POST["delete"])) {
                        this->triggerDelete("menus", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("menus", path);
                    }
                }

                let path = path . "?saved=true";

                if (isset(_POST["add_stack"])) {
                    if (!empty(_POST["add_stack"])) {
                        this->addItem(model->id);
                        let path = path . "&scroll=stack-tab";
                    }
                }

                if (isset(_POST["stack_delete"])) {
                    if (!empty(_POST["stack_delete"])) {
                        this->deleteItem(model->id, _POST["stack_delete"]);
                    }
                }

                let data = this->setData(data);
                
                let status = this->database->execute(
                    "UPDATE menus SET 
                        name=:name,
                        title=:title,
                        alt=:alt,
                        url=:url,
                        content_id=:content_id,
                        parent_id=:parent_id,
                        new_window=:new_window,
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
                        this->updateStacks();
                        this->redirect(path);
                    } catch ValidationException, err {
                        this->missingRequired(err->getMessage());
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

    private function parentSelect(selected = null, exclude = null)
    {
        var select = ["": "no parent"], data;
        let data = this->database->all(
            "SELECT * FROM menus " .
            (exclude ? " WHERE id != '" . exclude . "'" : "") . " 
            ORDER BY name"
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
                                    this->parentSelect(model->parent_id, model->id) . 
                                    this->inputs->text("Title", "title", "The display title of the menu", false, model->title) .
                                    this->inputs->text("Alt text", "alt", "The display alt text for the menu", false, model->alt) . 
                                    this->inputs->text("URL", "url", "URL of the menu", false, model->url) .
                                    this->contentSelect(model->content_id) . 
                                    this->inputs->select("New window", "new_window", "Open the link in a new window", ["0": "no", "1": "yes"], false, model->new_window) .
                                    this->inputs->tags("Tags", "tags", "Tag the menu", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>";

        if (mode == "edit") {
            let html .= this->renderStacks(model);
        }

        let html .= "</div>
                <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#content-tab'
                            aria-controls='content-tab' 
                            aria-selected='true'>Menu</button>
                    </li>";
        if (mode == "edit") {
            let html .= "
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#stack-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='stack-tab' 
                            aria-selected='true'>Items</button>
                    </li>";
        }

        let html .= "<li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>" . 
                        this->buttons->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {    
            if (model->deleted_at) {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->recover(this->global_url ."/recover/" . model->id) . 
                "</li>";
            } else {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    this->buttons->delete(this->global_url ."/delete/" . model->id) . 
                "</li>";
            }
        }

        let html .= "<li class='dd-nav-item' role='presentation'>". 
                        this->buttons->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }

    public function renderList(string path)
    {
        var data = [], query;

        let query = "
            SELECT
                main.*,
                IFNULL(parent_page.name, 'No parent') AS parent 
            FROM menus AS main
            LEFT JOIN menus AS parent_page ON parent_page.id=main.parent_id 
            WHERE main.menu_id IS NULL ";
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

    public function renderStacks(model)
    {
        var item, html = "";

        let html = "
        <div id='stack-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title dd-flex'>
                        <div class='dd-col'>Items</div>
                        <div class='dd-col-auto'>" .
                            this->inputs->inputPopup("create-stack", "add_stack", "Create a new stack") .
                    "   </div>
                    </div>
                    <div class='dd-box-body'>";

        if (count(model->stacks)) {
            let html .= "<div class='dd-row'>";
            for item in model->stacks {
                let html .= "
                    <div class='dd-box'>
                        <div class='dd-box-title dd-flex'>
                            <div class='dd-col'>" . item->name . "</div>
                            <div class='dd-col-auto'>" . 
                                this->buttons->delete(item->id, "stack-delete-" . item->id, "stack_delete") .
                        "   </div>
                        </div>
                        <div class='dd-box-body'>" .
                            this->inputs->text("Name", "stack_name[]", "The name of the menu item", true, item->name) .
                            this->inputs->text("Title", "stack_title[]", "The title of the menu item", false, item->title) .
                            this->inputs->text("Alt text", "stack_alt[]", "The alt text for the menu item", false, item->alt) . 
                            this->inputs->text("URL", "stack_url[]", "The URL for the menu item", false, item->url) . 
                            this->contentSelect(item->content_id, "stack_content_id[]") . 
                            this->inputs->select("New window", "stack_new_window[]", "Open the link in a new window", ["0": "no", "1": "yes"], false, item->new_window) .
                            this->inputs->number("Sort", "stack_sort[]", "Sort the menu item", false, item->sort) .
                            this->inputs->hidden("stack_id[]", item->id) . 
                        "</div>
                    </div>";
            }
            let html .= "</div>";
        }

        let html .="</div>
                </div>
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
        let data["alt"] = _POST["alt"];
        let data["url"] = _POST["url"];
        let data["content_id"] = _POST["content_id"];
        let data["parent_id"] = _POST["parent_id"];
        let data["updated_by"] = this->database->getUserId();
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);

        return data;
    }

    private function updateStacks()
    {
        if (!isset(_POST["stack_name"])) {
            return;
        }

        var key, id, status, data = [];
        for key, id in _POST["stack_id"] {
            let data = [
                "id": id,
                "name": "",
                "title": "",
                "alt": "",
                "content_id": "",
                "new_window": 0,
                "sort": 0
            ];

            if (!isset(_POST["stack_name"][key])) {
                throw new ValidationException("Missing name for menu item");
            }

            if (empty(_POST["stack_name"][key])) {
                throw new ValidationException("Missing name for menu item");
            }

            let data["name"] = _POST["stack_name"][key];
            if (isset(_POST["stack_title"][key])) {
                let data["title"] = _POST["stack_title"][key];
            }
            if (isset(_POST["stack_alt"][key])) {
                let data["alt"] = _POST["stack_alt"][key];
            }
            if (isset(_POST["stack_url"][key])) {
                let data["url"] = _POST["stack_url"][key];
            }
            if (isset(_POST["stack_content_id"][key])) {
                let data["content_id"] = _POST["stack_content_id"][key];
            }
            if (isset(_POST["stack_new_window"][key])) {
                let data["new_window"] = intval(_POST["stack_new_window"][key]);
            }
            if (isset(_POST["stack_sort"][key])) {
                let data["sort"] = intval(_POST["stack_sort"][key]);
            }

            let status = this->database->execute(
                "UPDATE menus SET 
                    name=:name,
                    title=:title,
                    alt=:alt,
                    url=:url,
                    content_id=:content_id,
                    new_window=:new_window,
                    sort=:sort 
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the menu item");
            }
        }
    }
}