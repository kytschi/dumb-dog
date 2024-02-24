/**
 * Dumb Dog page builder
 *
 * @package     DumbDog\Controllers\Content
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\OldUrls;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Input;
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class Content extends Controller
{
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

    public required = ["name", "title", "template_id"];

    public function __globals()
    {
        let this->titles = new Titles();
        let this->inputs = new Input();
        let this->files = new Files();
        let this->buttons = new Button();
        let this->icons = new Icons();
    }

    public function add(string path)
    {
        var html, data, model, path = "";
        
        let html = this->titles->page("Create the " . str_replace("-", " ", this->type));

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var status = false;
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["created_by"] = this->getUserId();
                    let data["type"] = this->type;

                    let path = this->global_url;

                    let data = this->setData(data);

                    let status = this->database->execute(
                        "INSERT INTO content 
                            (id,
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
                            event_on,
                            event_length,
                            author,
                            company_name,
                            tags,
                            featured,
                            parent_id,
                            sort,
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
                            :slogan,
                            :url,
                            :content,                            
                            :template_id,
                            :meta_keywords,
                            :meta_author,
                            :meta_description,
                            :type,
                            :event_on,
                            :event_length,
                            :author,
                            :company_name,
                            :tags,
                            :featured,
                            :parent_id,
                            :sort,
                            NOW(),
                            :created_by,
                            NOW(),
                            :updated_by)",
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
                        this->redirect(path);
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

        let html .= this->render(model);

        return html;
    }

    private function addStack(string id)
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

    private function createStack(string id)
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

    public function edit(string path)
    {
        var html = "", model, data = [];
                
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
            content.*,
                banner.id AS banner_image_id,
                IF(banner.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-',  banner.filename), '') AS banner_image
            FROM content 
            LEFT JOIN files AS banner ON 
                banner.resource_id = content.id AND
                resource='banner-image' AND
                banner.deleted_at IS NULL
            WHERE content.type='" . this->type . "' AND content.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException(ucwords(str_replace("-", " ", this->type)) . " not found");
        }

        let html = this->titles->page("Edit the " . this->type, "edit");

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the " . str_replace("-", " ", this->type));
        }

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
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
            WHERE content_id='" . model->id . "' AND content_stacks.deleted_at IS NULL AND content_stack_id IS NULL
            ORDER BY sort ASC");

        let model->old_urls = this->database->all("SELECT * FROM old_urls WHERE content_id='" . model->id . "' AND deleted_at IS NULL");

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

                if (isset(_POST["delete_old_url"])) {
                    if (!empty(_POST["delete_old_url"])) {
                        this->triggerDelete("old_urls", path, _POST["delete_old_url"]);
                    }
                }

                if (isset(_POST["delete_stack"])) {
                    if (!empty(_POST["delete_stack"])) {
                        this->triggerDelete("content_stacks", path, reset(_POST["delete_stack"]));
                    }
                }

                if (isset(_POST["recover"])) {
                    if (!empty(_POST["recover"])) {
                        this->triggerRecover("content", path);
                    }
                }

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

                if (isset(_FILES["banner_image"]["name"])) {
                    if (!empty(_FILES["banner_image"]["name"])) {
                        this->files->addResource("banner_image", data["id"], "banner-image");
                    }
                }

                let status = this->database->execute(
                    "UPDATE content SET 
                        status=:status,
                        name=:name,
                        title=:title,
                        sub_title=:sub_title,
                        slogan=:slogan,
                        url=:url,
                        template_id=:template_id,
                        content=:content,
                        meta_keywords=:meta_keywords,
                        meta_author=:meta_author,
                        meta_description=:meta_description,
                        updated_at=NOW(),
                        updated_by=:updated_by,
                        event_on=:event_on,
                        event_length=:event_length,
                        author=:author,
                        company_name=:company_name,
                        tags=:tags,
                        featured=:featured,
                        parent_id=:parent_id,
                        sort=:sort  
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the " . this->type);
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        this->updateStacks();
                        (new OldUrls())->add(this->database, model->id);
                        let path = this->updateExtra(model, path);
                        this->redirect(path);
                    } catch ValidationException, err {
                        this->missingRequired(err->getMessage());
                    }
                }
            }
        }
        
        let html .=
            this->render(model, "edit") .
            this->stats(model);
        return html;
    }

    public function index(string path)
    {
        var html;       
        
        let html = this->titles->page(this->title, strtolower(str_replace(" ", "", this->title)));

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        if (this->back_url) {
            let html .= this->renderBack();
        } else {
            let html .= this->renderToolbar();
        }

        let html .= 
            this->searchBox() . 
            this->tags(path, "content") .
            this->renderList(path);
        return html;
    }

    private function parentSelect(model = null, exclude = null)
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
                                    this->inputs->toggle("Set live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                    this->inputs->text("Name", "name", "Name the page", true, model->name) .
                                    this->inputs->text("Title", "title", "The page title", true, model->title) .
                                    this->inputs->text("Sub title", "sub_title", "The page sub title", false, model->sub_title) .
                                    this->inputs->textarea("Slogan", "slogan", "The page slogan", false, model->slogan, 500) .
                                    this->inputs->wysiwyg("Content", "content", "The page content", false, model->content) . 
                                    this->inputs->toggle("Feature", "featured", false, model->featured) . 
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
                                            this->inputs->text("Path", "url", "The path for the page", true, model->url) .
                                        "</div>
                                    </div>
                                </div>
                                <div class='dd-col-12'>
                                    <div class='dd-box'>
                                        <div class='dd-box-title'>Relationship</div>
                                        <div class='dd-box-body'>" .
                                            this->parentSelect(model->parent_id, model->id) .
                                            this->inputs->number("Sort", "sort", "Sort the page with in the parent", false, model->sort) .
                                        "</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class='dd-col-lg-6 dd-col-md-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>SEO</div>
                                <div class='dd-box-body'>" .
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
                                <div class='dd-box-title'>Look and Feel</div>
                                <div class='dd-box-body'>" .
                                    this->templatesSelect(model->template_id) . 
                                    this->inputs->image("Banner image", "banner_image", "Upload your banner image here", false, model->banner_image) . 
                                "</div>
                            </div>
                        </div>
                    </div>" .
                    this->renderExtra(model);

        if (mode == "edit") {
            let html .= this->renderStacks(model);
            let html .= this->renderOldUrls(model);
        }

        let html .= "
                </div>
                <ul class='dd-col dd-nav-tabs' role='tablist'>
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
                            data-tab='#nav-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='nav-tab' 
                            aria-selected='true'>Navigation and SEO</button>
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#look-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='look-tab' 
                            aria-selected='true'>Look and Feel</button>
                    </li> " .
                    this->renderExtraMenu();
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
                    </li>
                    <li class='dd-nav-item' role='presentation'>
                        <button
                            data-tab='#old-urls-tab'
                            class='dd-nav-link'
                            type='button'
                            role='tab'
                            aria-controls='old-urls-tab' 
                            aria-selected='true'>Old URLs</button>
                    </li>";
        }

        let html .= "<li class='dd-nav-item' role='presentation'><hr/></li>
                    <li class='dd-nav-item' role='presentation'>" . 
                        this->buttons->generic(
                            this->global_url,
                            "back",
                            "back",
                            "Go back to the list"
                        ) .
                    "</li>";
        if (mode == "edit") {
            let html .= "
                <li class='dd-nav-item' role='presentation'>" . 
                    this->buttons->generic(
                        this->global_url . "/add",
                        "add",
                        "add",
                        "Create a new " . str_replace("-", " ", this->type)
                    ) .
                "</li>
                <li class='dd-nav-item' role='presentation'>" .
                    this->buttons->view(model->url) .
                "</li>";
    
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

    public function renderBack()
    {
        return "
        <div class='dd-box'>
            <div class='dd-box-body'>
                <a href='" . this->back_url . "' title='Go back' class='dd-button'>
                    <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                        <path fill-rule='evenodd' d='M1.146 4.854a.5.5 0 0 1 0-.708l4-4a.5.5 0 1 1 .708.708L2.707 4H12.5A2.5 2.5 0 0 1 15 6.5v8a.5.5 0 0 1-1 0v-8A1.5 1.5 0 0 0 12.5 5H2.707l3.147 3.146a.5.5 0 1 1-.708.708z'/>
                    </svg>
                    <span>Back</span>
                </a>
            </div>
        </div>";
    }

    public function renderExtra(model)
    {
        return "";
    }

    public function renderExtraMenu()
    {
        return "";
    }

    public function renderList(string path)
    {
        var data = [], query, table;

        let table = new Table();

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
            let query .= " AND main_page.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY main_page.name";

        return table->build(
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
                    <div class='dd-box-title'>
                        <span>Old URLs</span>" .
                        this->inputs->inputPopup("create-old-url", "add_old_url", "Create a new old URL link") .
                        "
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
                    }

        let html .= "</div>
                </div>
            </div>
        </div>";

        return html;
    }

    private function renderStacks(model)
    {
        var key, key_stack, item, item_stack, html = "";

        let html = "
        <div id='stack-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title'>
                        <span>Stacks</span>" .
                        this->inputs->inputPopup("create-stack", "create_stack", "Create a new stack") .
                        "
                    </div>
                </div>";

        if (count(model->stacks)) {
            for key, item in model->stacks {
                let html .= "
                <div class='dd-box'>
                    <div class='dd-box-title'>
                        <span>" . item->name . "</span>
                        <div>" .
                        this->inputs->inputPopup(
                            "create-stack-item-" . (key + 1),
                            "add_to_stack[" . item->id . "]",
                            "Add to the " . item->name . " stack",
                            "add") .
                        this->buttons->delete(item->id, "delete-stack-" . item->id, "delete_stack[]") .
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
                    let html .= this->inputs->text("Name", "stack_name[" . item->id . "]", "The name of the stack", true, item->name) .
                                this->inputs->text("Title", "stack_title[" . item->id . "]", "The title of the stack", false, item->title) .
                                this->inputs->text("Sub title", "stack_sub_title[" . item->id . "]", "The sub title for the stack", false, item->sub_title) .
                                this->inputs->wysiwyg("Content", "stack_content[" . item->id . "]", "The stack content", false, item->content) . 
                                this->inputs->tags("Tags", "stack_tags[" . item->id . "]", "Tag the content stack", false, item->tags) . 
                                this->inputs->image("Image", "stack_image[" . item->id . "]", "Upload an image here", false, item) . 
                                this->inputs->number("Sort", "stack_sort[" . item->id . "]", "Sort the stack item", false, item->sort) .
                                this->stackTemplatesSelect(
                                    item->template_id,
                                    "stack_template[" . item->id . "]"
                                ) . 
                                "<h3 class='dd-mt-5 dd-mb-0'>Stack items</h3>";
                                for key_stack, item_stack in item->stacks {
                                    let html .= "
                                    <div class='dd-stack'>" .
                                        "<div class='dd-stack-title'>
                                            <span>" . item_stack->name . "</span>" .
                                            this->buttons->delete(item_stack->id, "delete-stack-" . item_stack->id, "delete_stack[]") .
                                        "</div>
                                        <div class='dd-stack-body'>" .
                                            this->inputs->text("Name", "sub_stack_name[" . item_stack->id . "]", "The name of the stack", true, item_stack->name) .
                                            this->inputs->text("Title", "sub_stack_title[" . item_stack->id . "]", "The title of the stack", false, item_stack->title) .
                                            this->inputs->text("Sub title", "sub_stack_sub_title[" . item_stack->id . "]", "The sub title for the stack", false, item_stack->sub_title) .
                                            this->inputs->wysiwyg("Content", "sub_stack_content[" . item_stack->id . "]", "The stack content", false, item_stack->content) . 
                                            this->inputs->image("Image", "sub_stack_image[" . item_stack->id . "]", "Upload an image here", false, item_stack) . 
                                            this->inputs->number("Sort", "sub_stack_sort[" . item_stack->id . "]", "Sort the stack item", false, item_stack->sort) .
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

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->round(
                this->cfg->dumb_dog_url . "/" . this->type . "-categories",
                "categories",
                "categories",
                "Click to access the " . str_replace("-", " ", this->type) . " categories"
            ) .
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new " . str_replace("-", " ", this->type)
            ) .
        "</div>";
    }

    public function searchBox()
    {
        var html;

        let html = "
        <form 
            action='" . this->global_url . "'
            method='post'
            class='dd-box'>
            <div class='dd-box-body'>
                <div class='dd-row'>
                    <div class='dd-col-8'>
                        <div class='dd-input-group'>
                            <input 
                                class='dd-form-control'
                                name='q'
                                type='text' 
                                placeholder='Search the " . (strtolower(this->type). "s") . "'
                                value='" . (isset(_POST["q"]) ? _POST["q"]  : ""). "'>
                        </div>
                    </div>
                    <div class='dd-col-2'>
                        <button 
                            type='submit'
                            name='search' 
                            class='dd-float-right dd-button' 
                            value='search'>
                            search
                        </button>";

                    if (isset(_POST["q"])) {
                        let html .= "
                        <a 
                            href='" . this->global_url . "' 
                            class='dd-button dd-float-right'>
                            clear
                        </a>";
                    }
            
        let html .= "   
                    </div>
                </div>
                
            </div>
        </form>" ;

        return html;
    }

    private function setData(data)
    {
        let data["status"] = isset(_POST["status"]) ? "live" : "offline";
        let data["name"] = _POST["name"];
        let data["title"] = _POST["title"];
        let data["sub_title"] = _POST["sub_title"];
        let data["slogan"] = _POST["slogan"];

        if (empty(_POST["url"])) {
            let data["url"] = "/" . this->createSlug(_POST["title"]);
        } else {
            let data["url"] = this->cleanUrl(_POST["url"]);
        }

        let data["content"] = this->cleanContent(_POST["content"]);
        let data["template_id"] = _POST["template_id"];
        let data["meta_keywords"] = _POST["meta_keywords"];
        let data["meta_author"] = _POST["meta_author"];
        let data["meta_description"] = this->cleanContent(_POST["meta_description"]);
        let data["updated_by"] = this->getUserId();
        let data["event_on"] = null;                    
        let data["event_length"] = isset(_POST["event_length"]) ? _POST["event_length"] : null;
        let data["author"] = isset(_POST["author"]) ? _POST["author"] : null;
        let data["company_name"] = isset(_POST["company_name"]) ? _POST["company_name"] : null;
        let data["tags"] = this->inputs->isTagify(_POST["tags"]);
        let data["parent_id"] = _POST["parent_id"];
        let data["featured"] = isset(_POST["featured"]) ? 1 : 0;
        let data["sort"] = intval(_POST["sort"]);

        if (isset(_POST["event_on"])) {
            if (!isset(_POST["event_time"])) {
                let _POST["event_time"] = "00:00";
            } elseif (empty(_POST["event_time"])) {
                let _POST["event_time"] = "00:00";
            }
            let data["event_on"] = this->dateToSql(_POST["event_on"] . " " . _POST["event_time"] . ":00");
        }

        return data;
    }

    private function stats(model)
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

        //I'm reusing vars here, keep an eye.
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

    private function stackTemplatesSelect(selected = null, string id = "template_id")
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
            selected
        );
    }

    private function templatesSelect(selected = null, string id = "template_id")
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

    private function updateStacks()
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
                throw new ValidationException("Missing name for stack");
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
}