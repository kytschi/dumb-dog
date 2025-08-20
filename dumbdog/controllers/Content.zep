/**
 * Dumb Dog page builder
 *
 * @package     DumbDog\Controllers\Content
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\OldUrls;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Dates;
use DumbDog\Ui\Gfx\Buttons;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Inputs;
use DumbDog\Ui\Gfx\Tables;
use DumbDog\Ui\Gfx\Titles;

class Content extends Controller
{
    protected tables;
    protected titles;
    protected buttons;
    protected inputs;
    protected icons;
    protected files;

    public global_url = "/pages";
    public type = "page";
    public title = "Pages";
    public back_url = "";
    public category = "page-category";
    public list = [
        "name|with_tags",
        "parent",
        "template"
    ];

    public required = ["name", "title"];

    public routes = [
        "/pages/add": [
            "Pages",
            "add",
            "create a page"
        ],
        "/pages/edit": [
            "Pages",
            "edit",
            "edit the page"
        ],
        "/pages": [
            "Pages",
            "index",
            "pages"
        ]
    ];

    public query = "";
    public query_insert = "";
    public query_update = "";
    public query_children = "";
    public query_images = "";
    public query_old_urls = "";
    public query_parent = "";
    public query_stacks = "";
    public query_list = "";

    public function __globals()
    {
        let this->tables = new Tables();
        let this->titles = new Titles();
        let this->inputs = new Inputs();
        let this->files = new Files();
        let this->buttons = new Buttons();
        let this->icons = new Icons();

        let this->query = "
            SELECT main_page.*,
                IFNULL(templates.name, 'No template') AS template, 
                IFNULL(parent_page.name, 'No parent') AS parent 
            FROM content AS main_page 
            LEFT JOIN templates ON templates.id=main_page.template_id 
            LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id";
            
        let this->query_insert = "
            INSERT INTO content 
            (
                id,
                status,
                name,
                title,
                sub_title,
                slogan,
                url,
                content,
                template_id,
                meta_keywords,
                meta_author,
                meta_description,
                type,
                tags,
                featured,
                parent_id,
                sort,
                sitemap_include,
                public_facing,
                created_at,
                created_by,
                updated_at,
                updated_by
            ) 
            VALUES 
            (
                :id,
                :status,
                :name,
                :title,
                :sub_title,
                :slogan,
                :url,
                :content,                            
                :template_id,
                :meta_keywords,
                :meta_author,
                :meta_description,
                :type,
                :tags,
                :featured,
                :parent_id,
                :sort,
                :sitemap_include,
                :public_facing,
                NOW(),
                :created_by,
                NOW(),
                :updated_by
            )";
            
        let this->query_update = "
            UPDATE content SET 
                type=:type,
                status=:status,
                name=:name,
                template_id=:template_id,
                url=:url,
                title=:title,
                sub_title=:sub_title,
                slogan=:slogan,
                content=:content,
                meta_keywords=:meta_keywords,
                meta_author=:meta_author,
                meta_description=:meta_description,
                featured=:featured,
                sitemap_include=:sitemap_include,
                public_facing=:public_facing,
                tags=:tags,
                parent_id=:parent_id,
                sort=:sort,
                updated_by=:updated_by,
                updated_at=NOW() 
            WHERE id=:id";

        let this->query_children = "
            SELECT
                content.*,
                templates.file AS template 
            FROM content 
            JOIN templates ON templates.id=content.template_id 
            WHERE content.parent_id=:parent_id AND content.status='live' AND content.deleted_at IS NULL
            ORDER BY content.created_at DESC, content.name";

        let this->query_images = "
            SELECT 
                IF(filename IS NOT NULL, CONCAT('" . this->files->folder . "', filename), '') AS image,
                IF(filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', filename), '') AS thumbnail 
            FROM files 
            WHERE resource_id=:resource_id AND resource='content-image' AND deleted_at IS NULL AND visible=1
            ORDER BY sort ASC";
        
        let this->query_old_urls = "SELECT * FROM old_urls WHERE content_id=:id AND deleted_at IS NULL";

        let this->query_parent = "
            SELECT
                content.*,
                templates.file AS template 
            FROM content 
            JOIN templates ON templates.id=content.template_id 
            WHERE 
                content.id=:id AND 
                content.status='live' AND 
                content.public_facing=1 AND 
                content.deleted_at IS NULL";

        let this->query_stacks = "
            SELECT
                content_stacks.*,
                templates.file AS template,
                IF(
                    files.filename IS NOT NULL, 
                    CONCAT('" . this->files->folder . "', files.filename),
                    ''
                ) AS image,
                IF(
                    files.filename IS NOT NULL,
                    CONCAT('" . this->files->folder . "thumb-', files.filename),
                    ''
                ) AS thumbnail 
            FROM content_stacks 
            LEFT JOIN templates ON
                templates.id = content_stacks.template_id AND templates.deleted_at IS NULL 
            LEFT JOIN files ON
                files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
            WHERE 
                content_id=:id AND 
                content_stack_id IS NULL
            ORDER BY sort ASC";
    }

    public function add(path)
    {
        var html, data, model;
        
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
                    let data["created_by"] = this->getUserId();
                    let data["type"] = this->type;

                    let data = this->setData(data);

                    let status = this->database->execute(
                        this->query_insert,
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the " . this->type);
                        let html .= this->consoleLogError(status);
                    } else {
                        let path = path . "?saved=true";
                        let model = this->database->get(
                            "SELECT * FROM content WHERE id=:id",
                            [
                                "id": data["id"]
                            ]);
                        let path = this->updateExtra(model, path);

                        this->redirect(this->global_url . "/edit/" . data["id"]);
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Entry has been saved");
        }

        let model = new \stdClass();
        let model->deleted_at = null;
        let model->status = "live";
        let model->name = "";
        let model->title = "";
        let model->sub_title = "";
        let model->slogan = "";
        let model->content = "";
        let model->url = "";
        let model->parent_id = "";
        let model->id = "";
        let model->tags = "";
        let model->meta_keywords = "";
        let model->meta_author = "";
        let model->meta_description = "";
        let model->template_id = "";
        let model->banner_image = "";
        let model->sitemap_include = 1;
        
        let html .= this->render(model);

        return html;
    }

    public function addStack(string id)
    {
        var data = [
            "content_id": id,
            "created_by": this->getUserId(),
            "updated_by": this->getUserId(),
            "content_stack_id": null,
            "name": ""
        ], status, key, item;

        for key, item in _POST["add_to_stack"] {
            if (empty(item)) {
                continue;
            }
            let data["name"] = item;
            let data["content_stack_id"] = key;
        }

        if (empty(data["name"])) {
            return;
        }
        
        let status = this->database->execute(
            "INSERT INTO content_stacks 
                (id,
                content_id,
                content_stack_id,
                name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :content_id,
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

    public function createStack(string id)
    {
        var data = [
            "content_id": id,
            "created_by": this->getUserId(),
            "updated_by": this->getUserId(),
            "content_stack_id": null
        ], status;

        let data["name"] = _POST["create_stack"];
        
        let status = this->database->execute(
            "INSERT INTO content_stacks 
                (id,
                content_id,
                content_stack_id,
                name,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :content_id,
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

    public function deleteStack(path, string id)
    {
        this->triggerDelete("content_stacks", path, id);
    }

    public function edit(path)
    {
        var html = "", model, data = [];
                
        let data["id"] = this->getPageId(path);
        let data["type"] = this->type;
        let model = this->database->get("
            SELECT content.*
            FROM content 
            WHERE content.type=:type AND content.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException(ucwords(str_replace("-", " ", this->type)) . " not found");
        }

        let html = this->titles->page("Edit the " . str_replace("-", " ", this->type), "edit");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the " . str_replace("-", " ", this->type));
        }

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }

        if (!empty(_POST)) {
            var status = false, err;
            let path = this->global_url . "/edit/" . model->id;

            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("content", path);
                }
            }

            if (isset(_POST["delete_old_url"])) {
                if (!empty(_POST["delete_old_url"])) {
                    let path = path . "?scroll=old-urls-tab";
                    this->triggerDelete("old_urls", path, _POST["delete_old_url"]);
                }
            }

            if (isset(_POST["stack_delete"])) {
                if (!empty(_POST["stack_delete"])) {
                    let path = path . "?scroll=stack-tab";
                    this->deleteStack(path, reset(_POST["stack_delete"]));
                }
            }

            if (isset(_POST["stack_recover"])) {
                if (!empty(_POST["stack_recover"])) {
                    let path = path . "?scroll=stack-tab";
                    this->recoverStack(path, reset(_POST["stack_recover"]));
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("content", path);
                }
            }

            if (isset(_POST["delete_image"])) {
                this->files->deleteResource(_POST["delete_image"], path . "?deleted=true");
            }

            if (!this->validate(_POST, this->required)) {
                let html .= this->missingRequired();
            } else {
                let path = path . "?saved=true";

                if (isset(_POST["add_to_stack"])) {
                    if (!empty(_POST["add_to_stack"])) {
                        this->addStack(model->id);
                        let path = path . "&scroll=stack-tab";
                    }
                }

                if (isset(_POST["create_stack"])) {
                    if (!empty(_POST["create_stack"])) {
                        this->createStack(model->id);
                        let path = path . "&scroll=stack-tab";
                    }
                }

                let data = this->setData(data);
 
                if (isset(_FILES["add_image"]["name"])) {
                    if (!empty(_FILES["add_image"]["name"])) {
                        this->files->addResource("add_image", data["id"], "content-image");
                    }
                }

                let status = this->database->execute(
                    this->query_update,
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the " . this->type);
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        let path = this->updateExtra(model, path);
                        this->updateStacks();
                        this->updateImages();
                        (new OldUrls())->add(this->database, model->id);
                        this->redirect(path);
                    } catch ValidationException, err {
                        let html .= this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        let model->images = this->database->all(
            this->query_images,
            [
                "resource_id": model->id
            ]
        );

        let model->stacks = this->database->all(
            this->query_stacks,
            [
                "id": model->id
            ]
        );

        let model->old_urls = this->database->all(
            this->query_old_urls,
            [
                "id": model->id
            ]
        );

        let html .=
            this->render(model, "edit") .
            this->stats(model);
        return html;
    }

    public function index(path)
    {
        var html;       
        
        let html = this->titles->page(this->title, strtolower(str_replace(" ", "", this->title)));

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        let html .= 
            this->renderToolbar() .
            this->inputs->searchBox(this->global_url, "Search the " . strtolower(this->title)) . 
            this->tags(path, "content", this->type) .
            this->renderList(path);
        return html;
    }

    public function parentSelect(model = null, exclude = null)
    {
        var select = ["": "no parent"], selected = null, data;
        let data = this->database->all(
            "SELECT 
                *,
                CONCAT(name, ' (', REPLACE(type, '-', ' '), ')') AS name 
            FROM 
                content 
            WHERE type IN ('" . this->type . "', '" . this->category . "')" .
            (exclude ? " AND id != '" . exclude . "'" : "") . " 
            ORDER BY name"
        );
        var iLoop = 0;

        if (model) {
            let selected = model;
        } elseif (isset(_POST["parent_id"])) {
            let selected = _POST["parent_id"];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "Parent",
            "parent_id",
            "Is this page a child of another?",
            select,
            false,
            selected
        );
    }

    public function recoverStack(path, string id)
    {
        this->triggerRecover("content_stacks", path, id);
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
                                    this->inputs->toggle("Set live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                    this->inputs->text("Name", "name", "Name the page", true, model->name) .
                                    this->inputs->text("Title", "title", "The page title", true, model->title) .
                                    this->inputs->toggle("Feature", "featured", false, model->featured) . 
                                    this->inputs->text("Sub title", "sub_title", "The page sub title", false, model->sub_title) .
                                    this->inputs->textarea("Slogan", "slogan", "The page slogan", false, model->slogan, 500) .
                                    this->inputs->wysiwyg("Content", "content", "The page content", false, model->content) . 
                                "
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id='nav-tab' class='dd-row'>
                        <div class='dd-col-lg-6 dd-col-md-12'>
                            <div class='dd-row'>
                                <div class='dd-col-12'>
                                    <div class='dd-box'>
                                        <div class='dd-box-title'>Navigation</div>
                                        <div class='dd-box-body'>" .
                                            this->inputs->text(
                                                "Path",
                                                "url",
                                                "The path for the page",
                                                true,
                                                model->url,
                                                false,
                                                "If you leave it blank I'll auto-generate a URL for you") .                                            
                                        "</div>
                                    </div>
                                </div>
                                <div class='dd-col-12'>
                                    <div class='dd-box'>
                                        <div class='dd-box-title'>Relationship</div>
                                        <div class='dd-box-body'>" .
                                            this->parentSelect(model->parent_id, model->id);

        if (!in_array(this->type, ["blog", "blog-category"])) {
            let html .= this->inputs->number("Sort", "sort", "Sort the page with in the parent", false, model->sort);
        }
        
                            let html .= "</div>
                                    </div>
                                </div>";

        if (in_array(this->type, ["blog", "blog-category"])) {
                    let html .= "<div class='dd-col-12'>
                                    <div class='dd-box'>
                                        <div class='dd-box-title'>Date written</div>
                                        <div class='dd-box-body'>" .
                                        this->inputs->date("Written on", "created_at", "When was the content written", false, model->created_at) .
                                        "</div>
                                    </div>
                                </div>";
        }
                let html .= "</div>
                        </div>
                        <div class='dd-col-lg-6 dd-col-md-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>SEO</div>
                                <div class='dd-box-body'>" .
                                    this->inputs->toggle("Sitemap include", "sitemap_include", false, model->sitemap_include) . 
                                    this->inputs->tags("Tags", "tags", "Tag the page", false, model->tags) . 
                                    this->inputs->text("Meta keywords", "meta_keywords", "Help search engines find the page", false, model->meta_keywords) .
                                    this->inputs->text("Meta author", "meta_author", "The author of the page", false, model->meta_author) .
                                    this->inputs->textarea("Meta description", "meta_description", "A short description of the page", false, model->meta_description) .
                                "</div>
                            </div>
                        </div>
                    </div>
                    <div id='look-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>Look &amp; Feel</div>
                                <div class='dd-box-body'>" .
                                    this->templatesSelect(model->template_id);

        if (mode == "edit") {
            let html .= this->inputs->image(
                "Add image",
                "add_image",
                "Add an image here",
                false
            ) .
            this->renderImages(model);
        }

        let html .= "</div>
                            </div>
                        </div>
                    </div>" .
                    this->renderExtra(model, mode);

        if (mode == "edit") {
            let html .= this->renderStacks(model);
            let html .= this->renderOldUrls(model);
        }

        let html .= "
                </div> " .
                this->renderSidebar(model, mode) .
            "</div>
        </form>";

        return html;
    }

    public function renderExtra(model, mode = "add")
    {
        return "";
    }

    public function renderExtraMenu(mode = "add")
    {
        return "";
    }

    public function renderImages(model)
    {
        if (!isset(model->images)) {
            return "";
        }

        var item, html = "";

        for item in model->images {
            let html .= "
            <div class='dd-row dd-mt-3'>
                <div class='dd-col-12 dd-image-preview dd-flex'>
                    <div class='dd-col'>
                        <img src='" . item->image . "'/>" .
                        this->inputs->text("Label", "image_label[" . item->id . "]", "Label the image", false, item->label) .
                        this->inputs->number("Sort", "image_sort[" . item->id . "]", "Sort the image", false, item->sort) .
                        this->inputs->toggle("Visible", "image_visible[" . item->id . "]", false, item->visible) . 
                    "</div>
                    <div class='dd-col-auto'>" .
                        this->buttons->copy(item->image) .
                        this->buttons->delete(item->id, "deleted-image-" . item->id, "delete_image", "") .
                    "</div>
                </div>
            </div>";
        }

        return html;
    }

    public function renderList(path)
    {
        var data = [], query;

        let query = "
            SELECT main_page.*,
            IFNULL(templates.name, 'No template') AS template, 
            IFNULL(parent_page.name, 'No parent') AS parent 
            FROM content AS main_page 
            LEFT JOIN templates ON templates.id=main_page.template_id 
            LEFT JOIN content AS parent_page ON parent_page.id=main_page.parent_id 
            WHERE main_page.type='" . this->type . "'";
        if (isset(_POST["q"])) {
            let query .= " AND main_page.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND main_page.tags LIKE :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY main_page.name";

        return this->tables->build(
            this->list,
            this->database->all(query, data),
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );
    }

    public function renderOldUrls(model)
    {
        var html = "", item;

        let html = "
        <div id='old-urls-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title dd-flex'>
                        <div class='dd-col'>Old URLs</div>
                        <div class='dd-col-auto'>" .
                            this->inputs->inputPopup("create-old-url", "add_old_url", "Create a new old URL link") .
                        "</div>
                    </div>
                    <div class='dd-box-body'>";
                    if (count(model->old_urls)) {
                        for item in model->old_urls {
                            let html .= "
                            <div class='dd-row mb-3'>
                                <div class='dd-col-10'>" .
                                    this->inputs->text("", "old_url[]", "Set the old URL", true, item->url, true) .
                                "</div>
                                <div class='dd-col-2'>" . 
                                    this->buttons->delete(item->id, "delete-url", "delete_old_url") .
                                "</div>
                            </div>";
                        }
                    } else {
                        let html .= "<span>No urls</span>";
                    }

        let html .= "</div>
                </div>
            </div>
        </div>";

        return html;
    }

    public function renderStacks(model)
    {
        var key, key_stack, item, item_stack, html = "";

        let html = "
        <div id='stack-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title dd-flex dd-border-none'>
                        <div class='dd-col'>Stacks</div>
                        <div class='dd-col-auto'>" .
                            this->inputs->inputPopup("create-stack", "create_stack", "Create a new stack") .
                        "</div>
                    </div>
                </div>";

        if (count(model->stacks)) {
            for key, item in model->stacks {
                let html .= "
                <div id='" . this->createSlug(item->name) . "-stack' class='dd-box" . (item->deleted_at ? " dd-deleted" : "") . "'>
                    <div class='dd-box-title dd-flex'>
                        <div class='dd-col'>" . item->name . "</div>
                        <div class='dd-col-auto'>" .
                            this->inputs->inputPopup(
                                "create-stack-item-" . (key + 1),
                                "add_to_stack[" . item->id . "]",
                                "Add to the " . item->name . " stack",
                                "add"
                            ) .
                            (
                                item->deleted_at ?
                                this->buttons->recover(item->id, "stack-recover-" . item->id, "stack_recover[]", "Recover the stack item") :
                                this->buttons->delete(item->id, "stack-delete-" . item->id, "stack_delete[]", "Delete the stack item")
                            ) .
                        "</div>
                    </div>
                    <div class='dd-box-body'>";
                    let item->stacks = this->database->all("
                        SELECT
                            content_stacks.*,
                            files.id AS image_id,
                            IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "', files.filename), '') AS image,
                            IF(files.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', files.filename), '') AS thumbnail  
                        FROM content_stacks 
                        LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
                        WHERE content_stack_id='" . item->id . "' AND content_stacks.deleted_at IS NULL
                        ORDER BY sort ASC");
                    let html .= this->inputs->text("Name", "stack_name[" . item->id . "]", "The name of the stack", true, item->name, (item->deleted_at ? true : false)) .
                                this->inputs->text("Title", "stack_title[" . item->id . "]", "The title of the stack", false, item->title, (item->deleted_at ? true : false)) .
                                this->inputs->text("Sub title", "stack_sub_title[" . item->id . "]", "The sub title for the stack", false, item->sub_title, (item->deleted_at ? true : false)) .
                                this->inputs->wysiwyg("Content", "stack_content[" . item->id . "]", "The stack content", false, item->content, (item->deleted_at ? true : false)) . 
                                this->inputs->tags("Tags", "stack_tags[" . item->id . "]", "Tag the content stack", false, item->tags, (item->deleted_at ? true : false)) . 
                                this->inputs->image("Image", "stack_image[" . item->id . "]", "Upload an image here", false, item, (item->deleted_at ? true : false)) . 
                                this->inputs->number("Sort", "stack_sort[" . item->id . "]", "Sort the stack item", false, item->sort, (item->deleted_at ? true : false)) .
                                this->stackTemplatesSelect(item->template_id, "stack_template[" . item->id . "]", (item->deleted_at ? true : false)) . 
                                "<h3 class='dd-mt-5 dd-mb-0'>Stack items</h3>";
                                for key_stack, item_stack in item->stacks {
                                    let html .= "
                                    <div id='" . this->createSlug(item_stack->name) . "-sub-stack' class='dd-stack'>" .
                                        "<div class='dd-stack-title dd-flex'>
                                            <span class='dd-col'>" . item_stack->name . "</span>
                                            <div class='dd-col-auto'>" .
                                                this->buttons->delete(
                                                    item_stack->id, 
                                                    "delete-stack-" . item_stack->id,
                                                    "stack_delete[]",
                                                    "Delete the stack item"
                                                ) .
                                            "</div>
                                        </div>
                                        <div class='dd-stack-body'>" .
                                            this->inputs->text("Name", "sub_stack_name[" . item_stack->id . "]", "The name of the stack", true, item_stack->name, (item_stack->deleted_at ? true : false)) .
                                            this->inputs->text("Title", "sub_stack_title[" . item_stack->id . "]", "The title of the stack", false, item_stack->title, (item_stack->deleted_at ? true : false)) .
                                            this->inputs->text("Sub title", "sub_stack_sub_title[" . item_stack->id . "]", "The sub title for the stack", false, item_stack->sub_title, (item_stack->deleted_at ? true : false)) .
                                            this->inputs->wysiwyg("Content", "sub_stack_content[" . item_stack->id . "]", "The stack content", false, item_stack->content, (item_stack->deleted_at ? true : false)) . 
                                            this->inputs->image("Image", "sub_stack_image[" . item_stack->id . "]", "Upload an image here", false, item_stack, (item_stack->deleted_at ? true : false)) . 
                                            this->inputs->number("Sort", "sub_stack_sort[" . item_stack->id . "]", "Sort the stack item", false, item_stack->sort, (item_stack->deleted_at ? true : false)) .
                                        "</div>
                                    </div>";
                                }
                let html .= "
                    </div>
                </div>";
            }
        }

        let html .="
            </div>
        </div>";

        return html;
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
            let html .= this->buttons->view(model->url);
        }
        let html .=     this->buttons->save() . 
                    "</div>
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
                        "Content
                    </span>
                </div>
            </li>
            <li class='dd-nav-item' role='presentation'>
                <div class='dd-nav-link dd-flex'>
                    <span 
                        data-tab='#nav-tab'
                        class='dd-tab-link dd-col'
                        role='tab'
                        aria-controls='nav-tab' 
                        aria-selected='true'>" .
                        this->buttons->tab("nav-tab") .
                        "Navigation &amp; SEO
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
            </li> " .
            this->renderExtraMenu(mode);
        if (mode == "edit") {
            let html .= "
                    <li class='dd-nav-item' role='presentation'>
                        <div class='dd-nav-link dd-flex'>
                            <span 
                                data-tab='#old-urls-tab'
                                class='dd-tab-link dd-col'
                                role='tab'
                                aria-controls='old-urls-tab' 
                                aria-selected='true'>" .
                                this->buttons->tab("old-urls-tab") .
                                "Old URLs
                            </span>
                        </div>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <div class='dd-nav-link dd-flex'>
                            <span
                                data-tab='#stack-tab'
                                role='tab'
                                aria-controls='stack-tab' 
                                aria-selected='true'
                                class='dd-tab-link dd-col'>" .
                                this->buttons->tab("stack-tab") .
                                "Stacks
                            </span>
                            <span class='dd-col-auto'>
                            " .
                                this->inputs->inputPopup(
                                    "create-stack-btn",
                                    "create_stack",
                                    "Create a new stack",
                                    "dd-border-none dd-p0"
                                ) .
                        "   </span>
                        </div>
                    </li>";
        }
        let html .= "</ul>";
        return html;
    }

    public function renderToolbar()
    {
        var html;

        let html = "<div class='dd-page-toolbar'>";

        if (this->back_url) {
            let html .= this->buttons->round(
                this->cfg->dumb_dog_url . this->back_url,
                "Back",
                "back",
                "Go back to the pages"
            );
        }

        let html .=
            this->buttons->round(
                this->cfg->dumb_dog_url . "/" . this->type . "-categories",
                "categories",
                "categories",
                "Click to access the " . str_replace("-", " ", this->type) . " categories"
            );

        if (this->global_url == this->cfg->dumb_dog_url . "/pages") {
            let html .= 
                this->buttons->round(
                    this->cfg->dumb_dog_url . "/templates",
                    "templates",
                    "templates",
                    "Click to access the templates"
                ) .
                this->buttons->round(
                    this->cfg->dumb_dog_url . "/themes",
                    "themes",
                    "themes",
                    "Click to access the themes"
                );
        }

        let html .= this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new " . str_replace("-", " ", this->type)
            ) .
        "</div>";

        return html;
    }

    public function setContentData(array data, user_id = null, model = null)
    {
        var result;

        let data["status"] = isset(_POST["status"]) ? "live" : (model ? model->status : "offline");

        let data["public_facing"] = 0;
        if (isset(_POST["public_facing"]) || data["status"] == "live") {
            let data["public_facing"] = 1;
        }

        let data["name"] = _POST["name"];

        if (!isset(_POST["template_id"])) {
            if (!empty(model)) {
                let data["template_id"] = model->template_id;
            } else {
                let result = this->database->get("SELECT id FROM templates WHERE is_default=1");
                if (empty(result)) {
                    throw new Exception(
                        "No default template found, either set a template_id or set a default template"
                    );
                }
                let data["template_id"] = result->id;
            }
        } else {
            let data["template_id"] = _POST["template_id"];
        }

        if (!isset(_POST["url"]) || empty(_POST["url"])) {
            if (!empty(model) && !empty(model->url)) {
                let data["url"] = model->url;
                
            } else {
                let data["url"] = 
                    "/" . this->createSlug(isset(_POST["title"]) ? _POST["title"] : _POST["name"]);
            }
        } else {
            let data["url"] = this->cleanUrl(_POST["url"]);
        }

        this->validUrl(data);

        let data["title"] = isset(_POST["title"]) ? _POST["title"] : (model ? model->title : null);
        let data["sub_title"] = isset(_POST["sub_title"]) ? _POST["sub_title"] : (model ? model->sub_title : null);
        let data["slogan"] = isset(_POST["slogan"]) ? _POST["slogan"] : (model ? model->slogan : null);
        let data["content"] = (isset(_POST["content"]) ? this->cleanContent(_POST["content"]) : (model ? model->content : null)); 
        let data["meta_keywords"] = (isset(_POST["meta_keywords"]) ?_POST["meta_keywords"] : (model ? model->meta_keywords : null));
        let data["meta_author"] = (isset(_POST["meta_author"]) ? _POST["meta_author"] : (model ? model->meta_author : null));
        let data["meta_description"] = (isset(_POST["meta_description"]) ? this->cleanContent(_POST["meta_description"]) : (model ? model->meta_description : null));
        
        let data["featured"] = isset(_POST["featured"]) ? 1 : (model ? model->featured : 0);
        let data["sitemap_include"] = isset(_POST["sitemap_include"]) ? 1 : (model ? model->sitemap_include : 0);
        let data["tags"] = (isset(_POST["tags"]) ? this->inputs->isTagify(_POST["tags"]) : (model ? model->tags : null));
        let data["parent_id"] = isset(_POST["parent_id"]) ? _POST["parent_id"] : (model ? model->parent_id : null);
        let data["sort"] = isset(_POST["sort"]) ? intval(_POST["sort"]) : (model ? model->sort : 0);
        let data["updated_by"] = (user_id ? user_id : this->database->getUserId());
        
        return data;
    }

    public function setData(array data, user_id = null, model = null)
    {   
        let data = this->setContentData(data, user_id, model);
        return data;
    }

    public function stats(model)
    {
        var query, html = "", iLoop, data, year, month, colours = [
            "visitors": "#00c129",
            "unique": "#1D8CF8",
            "bot": "#E14ECA"
        ];

        let query = "SELECT ";
        let year = date("Y");
        let iLoop = 1;
        while (iLoop <= 12) {
            let month = iLoop;
            if (month < 10) {
                let month = "0" . month;
            }

            let query .= "(SELECT count(id) FROM stats WHERE page_id=:page_id AND created_at BETWEEN '" . year . "-" .
                    month . "-01' AND '" . year . "-" .
                    month . "-31') AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . month . "-01"))) . "_visitors,";

            let query .= "(SELECT count(*) FROM (SELECT count(id) FROM stats WHERE page_id=:page_id AND bot IS NULL AND 
                    created_at BETWEEN '" . year . "-" .
                    month . "-01' AND '" . year . "-" .
                    month . "-31' GROUP BY visitor) AS total) AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . month . "-01"))) . "_unique,";

            let query .= "(SELECT count(id) FROM stats WHERE page_id=:page_id AND bot IS NOT NULL AND 
                    created_at BETWEEN '" . year . "-" . month . "-01' AND '" . year . "-" .
                    month . "-31') AS " .
                    strtolower(date("F", strtotime(date('Y') . "-" . month . "-01"))) . "_bot,";
            let iLoop = iLoop + 1;
        }
        let data = this->database->all(rtrim(query, ','), ["page_id": model->id]);

        //I'm reusing vars here, keep an eye open.
        let query = [];
        for month in data {
            for year, iLoop in get_object_vars(month) {
                let iLoop = explode("_", year);
                let iLoop = array_pop(iLoop);
                if (!isset(query[iLoop])) {
                    let query[iLoop] = [];
                }
                let query[iLoop][] = month->{year};
            }
        }
        let html .= "<div class='dd-box'><div class='dd-box-title'><span>annual stats</span></div><div class='dd-box-body'>
        <canvas id='visitors' width='600' height='200'></canvas></div></div>
        <script type='text/javascript'>
        var ctx = document.getElementById('visitors').getContext('2d');
        var orders = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
                datasets: [";                    
        
        for month, year in query {
            let html .= "
            {
                label: '" . ucwords(month) . "',
                data: [". rtrim(implode(",", year), ",") . "],
                fill: false,
                backgroundColor: '" . colours[month] . "',
                borderColor: '" . colours[month] . "',
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

        return html;
    }

    public function stackTemplatesSelect(selected = null, string id = "template_id", bool disabled = false)
    {
        var select = [], data;
        let data = this->database->all("
            SELECT * FROM templates 
            WHERE deleted_at IS NULL AND type='content-stack'
            ORDER BY is_default DESC, name");
        var iLoop = 0;

        if (isset(_POST[id])) {
            let selected = _POST[id];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            if (data[iLoop]->is_default && empty(selected)) {
                let selected = data[iLoop]->id;
            }
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "template",
            id,
            "The stack's template",
            select,
            true,
            selected,
            disabled
        );
    }

    public function templatesSelect(selected = null, string id = "template_id")
    {
        var select = [], data;
        let data = this->database->all("
            SELECT * FROM templates 
            WHERE deleted_at IS NULL AND type='page'
            ORDER BY is_default DESC, name");
        var iLoop = 0;

        if (isset(_POST[id])) {
            let selected = _POST[id];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            if (data[iLoop]->is_default && empty(selected)) {
                let selected = data[iLoop]->id;
            }
            let iLoop = iLoop + 1;
        }

        return this->inputs->select(
            "template",
            id,
            "The page's template",
            select,
            true,
            selected
        );
    }

    public function updateExtra(model, path)
    {
        return path;
    }

    public function updateImages()
    {
        if (!isset(_POST["image_sort"])) {
            return;
        }

        var val, id, status = false;
        for id, val in _POST["image_sort"] {
            let status = this->database->execute(
                "UPDATE files 
                SET 
                    sort=:sort,
                    label=:label,
                    visible=:visible 
                WHERE id=:id",
                [
                    "id": id,
                    "sort": intval(val),
                    "label": _POST["image_label"][id],
                    "visible": _POST["image_visible"][id]
                ]
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the image sort");
            }
        }
    }

    public function updateStacks(model = null, user_id = null)
    {
        if (!isset(_POST["stack_name"])) {
            return;
        }

        var val, val_sub, id, id_sub, status, data = [];
        for id, val in _POST["stack_name"] {
            let data = [
                "id": id,
                "name": "",
                "title": "",
                "sub_title": "",
                "content": "",
                "sort": 0,
                "tags": "",
                "template_id": ""
            ];

            if (empty(val)) {
                throw new ValidationException(
                    "Missing name for stack"
                );
            }

            let data["name"] = val;
            if (isset(_POST["stack_title"][id])) {
                let data["title"] = _POST["stack_title"][id];
            }
            if (isset(_POST["stack_sub_title"][id])) {
                let data["sub_title"] = _POST["stack_sub_title"][id];
            }
            if (isset(_POST["stack_content"][id])) {
                let data["content"] = _POST["stack_content"][id];
            }
            if (isset(_POST["stack_sort"][id])) {
                let data["sort"] = intval(_POST["stack_sort"][id]);
            }
            if (isset(_POST["stack_tags"][id])) {
                let data["tags"] = this->inputs->isTagify(_POST["stack_tags"][id]);
            }
            if (isset(_POST["stack_template"][id])) {
                let data["template_id"] = _POST["stack_template"][id];
            } else {
                throw new ValidationException("Missing template for stack");
            }

            let status = this->database->execute(
                "UPDATE content_stacks SET 
                    name=:name,
                    title=:title,
                    sub_title=:sub_title,
                    content=:content,
                    sort=:sort,
                    tags=:tags,
                    template_id=:template_id 
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the stack");
            }

            if (isset(_FILES["stack_image"]["name"][id])) {
                if (!empty(_FILES["stack_image"]["name"][id])) {
                    let _FILES["image"] = [
                        "name": _FILES["stack_image"]["name"][id],
                        "full_path": _FILES["stack_image"]["full_path"][id],
                        "type": _FILES["stack_image"]["type"][id],
                        "tmp_name": _FILES["stack_image"]["tmp_name"][id],
                        "error": _FILES["stack_image"]["error"][id],
                        "size": _FILES["stack_image"]["size"][id]
                    ];
                    
                    this->files->addResource("image", id, "image", true);
                    unset(_FILES["image"]);
                }
            }

            if (isset(_POST["sub_stack_name"])) {
                for id_sub, val_sub in _POST["sub_stack_name"] {
                    let data = [
                        "id": id_sub,
                        "name": "",
                        "title": "",
                        "sub_title": "",
                        "content": "",
                        "sort": 0
                    ];
        
                    if (empty(val_sub)) {
                        throw new ValidationException("Missing name for the stack item");
                    }
        
                    let data["name"] = val_sub;
                    if (isset(_POST["sub_stack_title"][id_sub])) {
                        let data["title"] = _POST["sub_stack_title"][id_sub];
                    }
                    if (isset(_POST["sub_stack_title"][id_sub])) {
                        let data["sub_title"] = _POST["sub_stack_sub_title"][id_sub];
                    }
                    if (isset(_POST["sub_stack_content"][id_sub])) {
                        let data["content"] = _POST["sub_stack_content"][id_sub];
                    }
                    if (isset(_POST["sub_stack_sort"][id_sub])) {
                        let data["sort"] = intval(_POST["sub_stack_sort"][id_sub]);
                    }
        
                    let status = this->database->execute(
                        "UPDATE content_stacks SET 
                            name=:name,
                            title=:title,
                            sub_title=:sub_title,
                            content=:content,
                            sort=:sort 
                        WHERE id=:id",
                        data
                    );
                
                    if (!is_bool(status)) {
                        throw new Exception("Failed to update the stack");
                    }

                    if (isset(_FILES["sub_stack_image"]["name"][id_sub])) {
                        if (!empty(_FILES["sub_stack_image"]["name"][id_sub])) {
                            let _FILES["image"] = [
                                "name": _FILES["sub_stack_image"]["name"][id_sub],
                                "full_path": _FILES["sub_stack_image"]["full_path"][id_sub],
                                "type": _FILES["sub_stack_image"]["type"][id_sub],
                                "tmp_name": _FILES["sub_stack_image"]["tmp_name"][id_sub],
                                "error": _FILES["sub_stack_image"]["error"][id_sub],
                                "size": _FILES["sub_stack_image"]["size"][id_sub]
                            ];
                            
                            this->files->addResource("image", id_sub, "image", true);
                            unset(_FILES["image"]);
                        }
                    }
                }
            }
        }
    }

    public function validUrl(array data)
    {
        if (this->database->get(
            "SELECT id FROM content WHERE url=:url AND deleted_at IS NULL AND id !=:id",
            [
                "url": data["url"],
                "id": data["id"]
            ]
        )) {
            throw new Exception("URL, " . data["url"] . ",  already taken by another piece of content");
        }
    }
}