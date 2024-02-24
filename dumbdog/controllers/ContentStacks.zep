/**
 * DumbDog content stacks builder
 *
 * @package     DumbDog\Controllers\ContentStacks
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Controllers\Files;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;

class ContentStacks extends Content
{
    public global_url = "/dumb-dog/content-stacks";
    public type = "content-stacks";
    public title = "Content stacks";
    public required = ["name"];
    public list = [
        "name|with_tags",
        "title"
    ];

    public function add(string path)
    {
        var html, data;

        let html = this->titles->page("Create the content stack", "add");

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
                        "INSERT INTO content_stacks 
                            (id,
                            name,
                            title,
                            description,
                            tags,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :title,
                            :description,
                            :tags,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the content stack");
                        let html .= this->consoleLogError(status);
                    } else {
                        if (isset(_FILES["image"]["name"])) {
                            if (!empty(_FILES["image"]["name"])) {
                                this->files->addResource("image", data["id"], "image");
                            }
                        }
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Content stack has been saved");
        }

        var model;
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->name = "";
        let model->title = "";
        let model->description = "";
        let model->image = "";

        let html .= this->render(model);

        return html;
    }

    private function addStack(string id)
    {
        var data = [
            "content_stack_id": id,
            "name": _POST["add_stack"],
            "created_by": this->database->getUserId(),
            "updated_by": this->database->getUserId()
        ], status;
        
        let status = this->database->execute(
            "INSERT INTO content_stacks 
                (id,
                content_stack_id,
                name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :content_stack_id,
                :name,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to save the content stack");
        }
    }

    public function deleteItem(string id, string item_id)
    {
        var data = [], status = false;

        if (this->cfg->save_mode == true) {
            let data["id"] = item_id;
            let data["updated_by"] = this->getUserId();
            let status = this->database->execute("
                UPDATE 
                    content_stacks 
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
            throw new Exception("Failed to delete the content stack");
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
                content_stacks.*,
                files.id AS image_id,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail  
            FROM content_stacks 
            LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
            WHERE content_stacks.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Content stack not found");
        }

        let html = this->titles->page("Edit the content stack", "edit");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Content stack has been updated");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        let model->stacks = this->database->all("
            SELECT
                content_stacks.*,
                files.id AS image_id,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail  
            FROM content_stacks
            LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
            WHERE content_stack_id='" . model->id . "' AND content_stacks.deleted_at IS NULL
            ORDER BY sort ASC");
        if (!empty(_POST)) {
            var status = false, err;

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = this->global_url . "/edit/" . model->id;

                if (isset(_POST["delete"])) {
                    if (!empty(_POST["delete"])) {
                        this->triggerDelete("content_stacks", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("content_stacks", path);
                    }
                }

                let path = path . "?saved=true";

                if (isset(_POST["add_stack"])) {
                    if (!empty(_POST["add_stack"])) {
                        this->addStack(model->id);
                        let path = path . "&scroll=stack-tab";
                    }
                }

                if (isset(_POST["stack_delete"])) {
                    if (!empty(_POST["stack_delete"])) {
                        this->deleteItem(model->id, _POST["stack_delete"]);
                    }
                }

                let data = this->setData(data);
                
                if (isset(_FILES["image"]["name"])) {
                    if (!empty(_FILES["image"]["name"])) {
                        this->files->addResource("image", data["id"], "image", true);
                    }
                }

                let status = this->database->execute(
                    "UPDATE content_stacks SET 
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        description=:description,
                        tags=:tags,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the content stack");
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
        
        let html .= this->render(model, "edit");
        return html;
    }

    private function render(model, mode = "add")
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
                                    this->inputs->text("Name", "name", "Name the stack", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title for the stack", false, model->title) .
                                    this->inputs->text("Sub title", "sub_title", "The display sub title for the stack", false, model->sub_title) .
                                    this->inputs->wysiwyg("Description", "description", "The display description for the stack", false, model->description) . 
                                    this->inputs->tags("Tags", "tags", "Tag the content stack", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->image("Image", "image", "Upload your image here", false, model) . 
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
                            aria-selected='true'>Content</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#look-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='look-tab' 
                            aria-selected='true'>Look &amp; Feel</button>
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
                            aria-selected='true'>Stacks</button>
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
                content_stacks.* 
            FROM content_stacks 
            WHERE content_stacks.content_stack_id IS NULL ";
        if (isset(_POST["q"])) {
            let query .= " AND content_stacks.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND content_stacks.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY content_stacks.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    private function renderStacks(model)
    {
        var item, html = "";

        let html = "
        <div id='stack-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title dd-flex dd-border-none'>
                        <div class='dd-col'>Stack items</div>
                        <div class='dd-col-auto'>" . 
                            this->inputs->inputPopup("create-stack", "add_stack", "Create a new stack item") .
                        "</div>
                    </div>
                </div>
            </div>
        </div>
        <div class='dd-row'>";

        if (count(model->stacks)) {
            for item in model->stacks {
                let html .= "
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title dd-flex'>
                            <div class='dd-col'>" . item->name . "</div>
                            <div class='dd-col-auto'>" . 
                                this->buttons->delete(item->id, "stack-delete-" . item->id, "stack_delete", "", true) .
                        "   </div>
                        </div>
                        <div class='dd-box-body'>" .
                            this->inputs->text("Name", "stack_name[]", "The name of the stack item", true, item->name) .
                            this->inputs->text("Title", "stack_title[]", "The title of the stack item", false, item->title) .
                            this->inputs->text("Sub title", "stack_sub_title[]", "The display sub title for the stack", false, item->sub_title) .
                            this->inputs->wysiwyg("Description", "stack_description[]", "The stack description item", false, item->description) . 
                            this->inputs->image("Image", "stack_image[]", "Upload an image here", false, item) . 
                            this->inputs->number("Sort", "stack_sort[]", "Sort the stack item", false, item->sort) .
                            this->inputs->hidden("stack_id[]", item->id) . 
                        "</div>
                    </div>
                </div>";
            }
        }

        let html .="
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
        let data["description"] = _POST["description"];
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);
        let data["updated_by"] = this->database->getUserId();

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
                "sub_title": "",
                "description": "",
                "sort": 0
            ];

            if (!isset(_POST["stack_name"][key])) {
                throw new ValidationException("Missing name for stack item");
            } elseif (empty(_POST["stack_name"][key])) {
                throw new ValidationException("Missing name for stack item");
            }

            let data["name"] = _POST["stack_name"][key];
            if (isset(_POST["stack_title"][key])) {
                let data["title"] = _POST["stack_title"][key];
            }
            if (isset(_POST["stack_sub_title"][key])) {
                let data["sub_title"] = _POST["stack_sub_title"][key];
            }
            if (isset(_POST["stack_description"][key])) {
                let data["description"] = _POST["stack_description"][key];
            }
            if (isset(_POST["stack_sort"][key])) {
                let data["sort"] = intval(_POST["stack_sort"][key]);
            }

            let status = this->database->execute(
                "UPDATE content_stacks SET 
                    name=:name,
                    title=:title,
                    sub_title=:sub_title,
                    description=:description,
                    sort=:sort 
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the stack item");
            }

            if (isset(_FILES["stack_image"]["name"][key])) {
                if (!empty(_FILES["stack_image"]["name"][key])) {
                    let _FILES["image"] = [
                        "name": _FILES["stack_image"]["name"][key],
                        "full_path": _FILES["stack_image"]["full_path"][key],
                        "type": _FILES["stack_image"]["type"][key],
                        "tmp_name": _FILES["stack_image"]["tmp_name"][key],
                        "error": _FILES["stack_image"]["error"][key],
                        "size": _FILES["stack_image"]["size"][key]
                    ];
                    
                    this->files->addResource("image", id, "image", true);
                }
            }
        }
    }
}