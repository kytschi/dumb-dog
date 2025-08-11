/**
 * DumbDog socials builder
 *
 * @package     DumbDog\Controllers\Socials
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

    public routes = [
        "/socials/add": [
            "Socials",
            "add",
            "create a social media link"
        ],
        "/socials/edit": [
            "Socials",
            "edit",
            "edit the social"
        ],
        "/socials": [
            "Socials",
            "index",
            "socials"
        ]
    ];

    public function add(path)
    {
        var html, data;

        let html = this->titles->page("Create the social media link", "socialmedia");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->database->getUserId();
                    let data["type"] = this->type;

                    let data = this->setData(data);
                    
                    let status = this->database->execute(
                        "INSERT INTO content 
                            (id,
                            status,
                            name,
                            title,
                            sub_title,
                            content,
                            type,
                            tags,
                            url,
                            sort,
                            sitemap_include,
                            created_at,
                            created_by,
                            updated_at,
                            updated_by) 
                        VALUES 
                            (
                            :id,
                            :status,
                            :name,
                            :title,
                            :sub_title,
                            :content,
                            :type,
                            :tags,
                            :url,
                            :sort,
                            0,
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
                                this->files->addResource("image", data["id"], "image");
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
        let model->status = "live";
        let model->name = "";
        let model->title = "";
        let model->sub_title = "";
        let model->feature = false;
        let model->content = "";
        let model->sitemap_include = false;
        let model->tags = "";
        let model->url = "";
        let model->sort = 0;

        let html .= this->render(model);

        return html;
    }

    public function edit(path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                content.*,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail 
            FROM content 
            LEFT JOIN files ON files.resource_id = content.id AND resource='image' AND files.deleted_at IS NULL 
            WHERE content.type='" . this->type . "' AND content.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Social media link not found");
        }

        let html = this->titles->page("Edit the social media link", "socialmedia");

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
                        this->triggerDelete("content", path);
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("content", path);
                    }
                }

                let path = path . "?saved=true";

                let data = this->setData(data);
                
                if (isset(_FILES["image"]["name"])) {
                    if (!empty(_FILES["image"]["name"])) {
                        this->files->addResource("image", data["id"], "image", true);
                    }
                }
                if (isset(_POST["delete_image"])) {
                    this->files->deleteResource(_POST["delete_image"], path . "?deleted=true");
                }

                let status = this->database->execute(
                    "UPDATE content SET 
                        status=:status,
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        content=:content,
                        tags=:tags,
                        url=:url,
                        sort=:sort,
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
                        let html .= this->missingRequired(err->getMessage());
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
                                    this->inputs->text("Name", "name", "Name the social media link", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title for the social media link", false, model->title) .
                                    this->inputs->text("URL", "url", "The URL for the social media link", false, model->url) .
                                    this->inputs->text("Sub title", "sub_title", "The display sub title for the social media link", false, model->sub_title) .
                                    this->inputs->wysiwyg("Description", "content", "The display description for the social media link", false, model->description) . 
                                    this->inputs->tags("Tags", "tags", "Tag the social media link", false, model->tags) . 
                                    this->inputs->number("Sort", "sort", "Sort entry against the other entries", false, model->sort) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>Look &amp; Feel</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->image("Image", "image", "Upload your image here", false, model) . 
                                "</div>
                            </div>
                        </div>
                    </div>
                </div>" .
                this->renderSidebar(model, mode) .
            "</div>
        </form>";

        return html;
    }

    public function renderList(path)
    {
        var data = [], query;

        let query = "
            SELECT
                content.* 
            FROM content 
            WHERE content.type='" . this->type . "'";
        if (isset(_POST["q"])) {
            let query .= " AND content.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND content.tags LIKE :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY content.name";
        
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
                            "Add a new social media link"
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
                        "Link
                    </span>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#look-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='look-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("look-tab") .
                        "Look &amp; Feel
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
            this->buttons->add(this->global_url . "/add") .
        "</div>";
    }

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "live" : "offline";
        let data["name"] = _POST["name"];
        let data["url"] = _POST["url"];
        let data["title"] = _POST["title"];
        let data["sort"] = intval(_POST["sort"]);
        let data["sub_title"] = _POST["sub_title"];
        let data["content"] = this->cleanContent(_POST["content"]);
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);
        let data["updated_by"] = this->database->getUserId();

        this->validUrl(data);

        return data;
    }
}