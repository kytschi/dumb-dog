/**
 * Dumb Dog reviews
 *
 * @package     DumbDog\Controllers\Reviews
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

class Reviews extends Content
{
    public global_url = "/reviews";
    public type = "review";
    public title = "Reviews";
    public required = ["name"];
    public list = [
        "icon|score",
        "name|with_tags",
        "title"        
    ];

    public function add(string path)
    {
        var html, data, model, path = "";
        
        let html = this->titles->page(
            "Create the " . str_replace("-", " ", this->type),
            "add"
        );

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let path = this->global_url;

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
                            featured,
                            tags,
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
                            :featured,
                            :tags,
                            0,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the review");
                        let html .= this->consoleLogError(status);
                    } else {
                        let path = path . "?saved=true";
                        let model = this->database->get(
                            "SELECT * FROM content WHERE id=:id",
                            [
                                "id": data["id"]
                            ]);
                        let path = this->updateExtra(model, path);

                        if (isset(_FILES["image"]["name"])) {
                            if (!empty(_FILES["image"]["name"])) {
                                this->files->addResource("image", data["id"], "image", true);
                            }
                        }

                        this->redirect(path);
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Review has been saved");
        }

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
        let model->score = 5;
        
        let html .= this->render(model);

        return html;
    }

    public function edit(string path)
    {
        var html, model, data = [];
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
                content.*,
                reviews.score,
                reviews.author,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail 
            FROM content 
            LEFT JOIN files ON files.resource_id = content.id AND resource='image' AND files.deleted_at IS NULL 
            JOIN reviews ON reviews.content_id = content.id 
            WHERE content.type='" . this->type . "' AND content.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException("Review not found");
        }

        let html = this->titles->page("Edit the review", "reviews");

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

                let status = this->database->execute(
                    "UPDATE content SET 
                        status=:status,
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        content=:content,
                        tags=:tags,
                        featured=:featured,
                        updated_at=NOW(),
                        updated_by=:updated_by 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the review");
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        let path = this->updateExtra(model, path);
                        this->redirect(path);
                    } catch ValidationException, err {
                        this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the review");
        }

        let html .= this->render(model, "edit");
        return html;
    }

    public function render(model, mode = "add")
    {
        var html;

        let html = "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-row'>
                <div class='dd-col-12'>
                    <div class='dd-box'>
                        <div class='dd-box-title'>
                            <span>Score</span>
                        </div>
                        <div class='dd-box-body dd-flex'>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='score' 
                                        value='1' " . 
                                        (model->score == 1 ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingTerrible() .
                                    "   <small class='dd-radio-on'>Terrible</small>
                                        <small class='dd-radio-off'>Terrible</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='score' 
                                        value='2' " . 
                                        (model->score == 2 ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingPoor() .
                                    "   <small class='dd-radio-on'>Poor</small>
                                        <small class='dd-radio-off'>Poor</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='score' 
                                        value='3' " . 
                                        (model->score == 3 ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingOK() .
                                    "   <small class='dd-radio-on'>OK</small>
                                        <small class='dd-radio-off'>OK</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='score' 
                                        value='4' " . 
                                        (model->score == 4 ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingGood() .
                                    "   <small class='dd-radio-on'>Good</small>
                                        <small class='dd-radio-off'>Good</small>
                                    </span>
                                </label>
                            </div>
                            <div class='dd-radio'>
                                <label>
                                    <input 
                                        type='radio'
                                        name='score' 
                                        value='5' " . 
                                        (model->score == 5 ? " checked='checked'" : "") . ">
                                    <span>" .
                                        this->icons->rankingExcellent() .
                                    "   <small class='dd-radio-on'>Excellent</small>
                                        <small class='dd-radio-off'>Excellent</small>
                                    </span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class='dd-tabs'>
                <div class='dd-tabs-content dd-col'>
                    <div id='content-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Set live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                    this->inputs->text("Name", "name", "Name the review entry", true, model->name) .
                                    this->inputs->text("Title", "title", "The display title", false, model->title) .
                                    this->inputs->text("Sub title", "sub_title", "Set a sub title", false, model->sub_title) .
                                    this->inputs->text("Author", "auhtor", "The author of the review", false, model->author) .
                                    this->inputs->wysiwyg("Content", "content", "What did the review say?", false, model->content) . 
                                    this->inputs->tags("Tags", "tags", "Tag the review", false, model->tags) . 
                                    this->inputs->toggle("Feature", "featured", false, model->featured) . 
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
                    </div>
                </div>
                <ul class='dd-col dd-nav dd-nav-tabs' role='tablist'>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            data-tab='#content-tab'
                            aria-controls='content-tab' 
                            aria-selected='true'>Review</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#look-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='look-tab' 
                            aria-selected='true'>Look and Feel</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'><hr/></li>
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
                content.*,
                reviews.score,
                reviews.author 
            FROM content 
            JOIN reviews ON reviews.content_id = content.id 
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

        let data = this->database->all(query, data);
        for query in data {
            switch (query->score) {
                case 5:
                    let query->icon = this->icons->rankingExcellent();
                    break;
                case 4:
                    let query->icon = this->icons->rankingGood();
                    break;
                case 3:
                    let query->icon = this->icons->rankingOK();
                    break;
                case 2:
                    let query->icon = this->icons->rankingPoor();
                    break;
                case 1:
                    let query->icon = this->icons->rankingTerrible();
                    break;
                default:
                    let query->icon = query->score;
                    break;
            }
        }

        return this->tables->build(
            this->list,
            data,
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

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "live" : "offline";
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["sub_title"] = _POST["sub_title"];
        let data["content"] = this->cleanContent(_POST["content"]);
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);
        let data["featured"] = isset(_POST["featured"]) ? 1 : 0;
        let data["updated_by"] = this->database->getUserId();

        return data;
    }

    public function updateExtra(model, path)
    {
        var data, status = false;

        let data = this->database->get("
            SELECT *
            FROM reviews 
            WHERE content_id='" . model->id . "'");

        if (!empty(data)) {
            if (!isset(_POST["score"])) {
                throw new ValidationException("Missing score");
            } elseif (empty(_POST["score"])) {
                throw new ValidationException("Missing score");
            }

            let status = this->database->get("
                UPDATE reviews SET
                    score=:score, author=:author
                WHERE id=:id",
                [
                    "id": data->id,
                    "score": intval(_POST["score"]),
                    "author": _POST["author"]
                ]
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to update the review");
            }
        } else {
            let status = this->database->get("
                INSERT INTO reviews 
                (
                    id,
                    content_id,
                    score,
                    author
                ) VALUES
                (
                    UUID(),
                    :content_id,
                    :score,
                    :author
                )",
                [
                    "content_id": model->id,
                    "score": intval(_POST["score"]),
                    "author": _POST["author"]
                ]
            );

            if (!is_bool(status)) {
                throw new Exception("Failed to create the review");
            }
        }

        return path;
    }
}