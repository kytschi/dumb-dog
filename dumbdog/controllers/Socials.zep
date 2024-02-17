/**
 * DumbDog socials builder
 *
 * @package     DumbDog\Controllers\Socials
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
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Input;
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class Socials extends Content
{
    public global_url = "/socials";
    public type = "social";
    public title = "Social Media";
    public required = ["name"];
    public list = [
        "name|with_tags",
        "title"        
    ];

    public function add(string path)
    {
        var titles, html, data, files, input;
        let files = new Files(this->cfg);
        let titles = new Titles();
        let input = new Input(this->cfg);

        let html = titles->page("Create the social media link", "socials");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["name"] = _POST["name"];
                    let data["title"] = _POST["title"];
                    let data["description"] = _POST["description"];
                    let data["url"] = _POST["url"];
                    let data["created_by"] = this->getUserId();
                    let data["updated_by"] = this->getUserId();
                    
                    let status = this->database->execute(
                        "INSERT INTO socials 
                            (id,
                            name,
                            title,
                            description,
                            url,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (:id,
                            :name,
                            :title,
                            :description,
                            :url,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the social media link");
                        let html .= this->consoleLogError(status);
                    } else {
                        if (isset(_FILES["image"]["name"])) {
                            if (!empty(_FILES["image"]["name"])) {
                                files->addResource("image", data["id"], "image");
                            }
                        }
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Social media link has been saved");
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

    public function edit(string path)
    {
        var titles, html, model, data = [], input, files;
        let titles = new Titles();
        let input = new Input(this->cfg);
        let files = new Files(this->cfg);

        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                socials.*,
                files.id AS image_id,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
            FROM socials 
            LEFT JOIN files ON files.resource_id = socials.id AND files.deleted_at IS NULL 
            WHERE socials.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Social media link not found");
        }

        let html = titles->page("Edit the social media link", "socials");

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = this->global_url . "/edit/" . model->id;

                if (isset(_POST["delete"])) {
                    if (!empty(_POST["delete"])) {
                        this->triggerDelete("socials", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("socials", path);
                    }
                }

                let path = path . "?saved=true";

                let data["name"] = _POST["name"];
                let data["title"] = _POST["title"];
                let data["sub_title"] = _POST["sub_title"];
                let data["description"] = _POST["description"];
                let data["url"] = _POST["url"];
                let data["tags"] = input->isTagify(_POST["tags"]);
                let data["updated_by"] = this->getUserId();
                
                if (isset(_FILES["image"]["name"])) {
                    if (!empty(_FILES["image"]["name"])) {
                        files->addResource("image", data["id"], "image", true);
                    }
                }

                let status = this->database->execute(
                    "UPDATE socials SET 
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        description=:description,
                        url=:url,
                        tags=:tags,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the social media link");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        this->redirect(path);
                    } catch ValidationException, err {
                        this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the social media link");
        }

        let html .= this->render(model, "edit");
        return html;
    }

    private function render(model, mode = "add")
    {
        var html, button, input;

        let input = new Input(this->cfg);
        let button = new Button();

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='content-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    input->text("Name", "name", "Name the social media link", true, model->name) .
                                    input->text("Title", "title", "The display title for the social media link", false, model->title) .
                                    input->text("URL", "url", "The URL for the social media link", false, model->url) .
                                    input->text("Sub title", "sub_title", "The display sub title for the social media link", false, model->sub_title) .
                                    input->wysiwyg("Description", "description", "The display description for the social media link", false, model->description) . 
                                    input->tags("Tags", "tags", "Tag the social media link", false, model->tags) . 
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    input->image("Image", "image", "Upload your image here", false, model) . 
                                "</div>
                            </div>
                        </div>
                    </div>
                </div>
                <ul class='dd-col dd-nav ndd-av-tabs' role='tablist'>
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
                    </li>
                    <li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>" . 
                        button->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {    
            if (model->deleted_at) {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    button->recover(this->global_url ."/recover/" . model->id) . 
                "</li>";
            } else {
                let html .= "<li class='dd-nav-item' role='presentation'>" .
                    button->delete(this->global_url ."/delete/" . model->id) . 
                "</li>";
            }
        }

        let html .= "<li class='dd-nav-item' role='presentation'>". 
                        button->save() .   
                    "</li>
                </ul>
            </div>
        </form>";

        return html;
    }

    public function renderList(string path)
    {
        var data = [], query, table;

        let table = new Table(this->cfg);

        let query = "
            SELECT * 
            FROM socials
            WHERE id IS NOT NULL ";
        if (isset(_POST["q"])) {
            let query .= " AND name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY name";

        return table->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->add(this->global_url . "/add") .
        "</div>";
    }
}