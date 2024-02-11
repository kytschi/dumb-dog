/**
 * Dumb Dog page builder
 *
 * @package     DumbDog\Controllers\Content
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Files;
use DumbDog\Controllers\OldUrls;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Input;
use DumbDog\Ui\Gfx\Table;
use DumbDog\Ui\Gfx\Titles;

class Content extends Controller
{
    public global_url = "/dumb-dog/pages";
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

    public function add(string path)
    {
        var titles, html, data, files, input, model, path = "";
        let files = new Files(this->cfg);
        let titles = new Titles();
        let input = new Input(this->cfg);

        let html = titles->page("Create the " . str_replace("-", " ", this->type));

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

                    let data = this->setData(data, input);

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

        let html .= this->render(model, files);

        return html;
    }

    private function addStack(string id)
    {
        var data = [
            "content_id": id,
            "created_by": this->getUserId(),
            "updated_by": this->getUserId(),
            "content_stack_id": null
        ], status;

        let data["name"] = reset(_POST["add_to_stack"]);
        if (empty(data["name"])) {
            return;
        }
        let data["content_stack_id"] = key(_POST["add_to_stack"]);
        
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
        var titles, html = "", model, data = [], input, files;
        let titles = new Titles();
        let input = new Input(this->cfg);
        let files = new Files(this->cfg);
        
        let data["id"] = this->getPageId(path);
        let model = this->database->get("
            SELECT 
            content.*,
                banner.id AS banner_image_id,
                IF(banner.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-',  banner.filename), '') AS banner_image
            FROM content 
            LEFT JOIN files AS banner ON 
                banner.resource_id = content.id AND
                resource='banner-image' AND
                banner.deleted_at IS NULL
            WHERE content.type='" . this->type . "' AND content.id=:id", data);

        if (empty(model)) {
            throw new NotFoundException(ucwords(str_replace("-", " ", this->type)) . " not found");
        }

        let html = titles->page("Edit the " . this->type, "edit");

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
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
                IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail 
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

                let data = this->setData(data, input);

                if (isset(_FILES["banner_image"]["name"])) {
                    if (!empty(_FILES["banner_image"]["name"])) {
                        files->addResource("banner_image", data["id"], "banner-image");
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
                        parent_id=:parent_id 
                    WHERE id=:id",
                    data
                );
            
                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the " . this->type);
                    let html .= this->consoleLogError(status);
                } else {
                    try {
                        this->updateStacks(files, input);
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
            this->render(model, files, "edit") .
            this->stats(model);
        return html;
    }

    public function index(string path)
    {
        var titles, html, button;
        let titles = new Titles();
        let button = new Button();
        
        
        let html = titles->page(this->title, "pages");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the entry");
        }

        if (this->back_url) {
            let html .= "<div class='dd-box'>
                <div class='dd-box-body'>
                    <a href='" . this->back_url . "' title='Go back' class='dd-button'>
                        <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                            <path fill-rule='evenodd' d='M1.146 4.854a.5.5 0 0 1 0-.708l4-4a.5.5 0 1 1 .708.708L2.707 4H12.5A2.5 2.5 0 0 1 15 6.5v8a.5.5 0 0 1-1 0v-8A1.5 1.5 0 0 0 12.5 5H2.707l3.147 3.146a.5.5 0 1 1-.708.708z'/>
                        </svg>
                        <span>Back</span>
                    </a>
                </div>
            </div>";
        } else {
            let html .= "
            <div class='dd-page-toolbar'>" . 
                button->generic(
                    "/dumb-dog/" . this->type . "-categories",
                    "categories",
                    "categories",
                    "Click to access the " . str_replace("-", " ", this->type) . " categories"
                ) .
                button->add(this->global_url . "/add") .
            "</div>";
        }

        let html .= "
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
                                placeholder='Search the " . (ucwords(this->type). "s") . "'
                                value='" . (isset(_POST["q"]) ? _POST["q"]  : ""). "'>
                        </div>
                    </div>
                    <div class='dd-col-2'>
                        <button 
                            type='submit'
                            name='search' 
                            class='dd-float-end dd-button' 
                            value='search'>
                            search
                        </button>";

                    if (isset(_POST["q"])) {
                        let html .= "
                        <a 
                            href='" . this->global_url . "' 
                            class='dd-button dd-float-end'>
                            clear
                        </a>";
                    }
            
        let html .= "   
                    </div>
                </div>
                
            </div>
        </form>" .
            this->tags(path, "content") .
            this->renderList(path);
        return html;
    }

    private function parentSelect(model = null, exclude = null)
    {
        var select = ["": "no parent"], selected = null, data, input;
        let input = new Input(this->cfg);
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

        return input->select(
            "Parent",
            "parent_id",
            "Is this page a child of another?",
            select,
            false,
            selected
        );
    }

    private function render(model, files, mode = "add")
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
                                    input->toggle("Set live", "status", false, (model->status=="live" ? 1 : 0)) . 
                                    input->text("Name", "name", "Name the page", true, model->name) .
                                    input->text("Title", "title", "The page title", true, model->title) .
                                    input->text("Sub title", "sub_title", "The page sub title", false, model->sub_title) .
                                    input->textarea("Slogan", "slogan", "The page slogan", false, model->slogan, 500) .
                                    input->wysiwyg("Content", "content", "The page content", false, model->content) . 
                                    input->toggle("Feature", "featured", false, model->featured) . 
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
                                            input->text("Path", "url", "The path for the page", true, model->url) .
                                        "</div>
                                    </div>
                                </div>
                                <div class='dd-col-12'>
                                    <div class='dd-box'>
                                        <div class='dd-box-title'>Relationship</div>
                                        <div class='dd-box-body'>" .
                                            this->parentSelect(model->parent_id, model->id) .
                                        "</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class='dd-col-lg-6 dd-col-md-12'>
                            <div class='dd-box'>
                                <div class='dd-box-title'>SEO</div>
                                <div class='dd-box-body'>" .
                                    input->tags("Tags", "tags", "Tag the page", false, model->tags) . 
                                    input->text("Meta keywords", "meta_keywords", "Help search engines find the page", false, model->meta_keywords) .
                                    input->text("Meta author", "meta_author", "The author of the page", false, model->meta_author) .
                                    input->textarea("Meta description", "meta_description", "A short description of the page", false, model->meta_description) .
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
                                    input->image("Banner image", "banner_image", "Upload your banner image here", false, model->banner_image) . 
                                "</div>
                            </div>
                        </div>
                    </div>" .
                    this->renderExtra(model);

        if (mode == "edit") {
            let html .= this->renderStacks(model, input, files, button);
            let html .= this->renderOldUrls(model, input, button);
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
                            aria-selected='true'>Navigation &amp; SEO</button>
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
                        button->back(this->global_url) .   
                    "</li>";
        if (mode == "edit") {
            let html .= "
                <li class='dd-nav-item' role='presentation'>" . 
                    button->add(this->global_url . "/add") .   
                "</li>
                <li class='dd-nav-item' role='presentation'>" .
                    button->view(model->url) .
                "</li>";
    
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
        var data, query, table;

        let table = new Table(this->cfg);

        let data = [];
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
            "/dumb-dog/" . ltrim(path, "/")
        );
    }

    public function renderOldUrls(model, input, button)
    {
        var html = "", item;

        let html = "
        <div id='old-urls-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title'>
                        <span>Old URLs</span>" .
                        input->inputPopup("create-old-url", "add_old_url", "Create a new old URL link") .
                        "
                    </div>
                    <div class='dd-box-body'>";
                    if (count(model->old_urls)) {
                        for item in model->old_urls {
                            let html .= "
                            <div class='dd-row mb-3'>
                                <div class='dd-col-10'>" .
                                    input->text("", "old_url[]", "Set the old URL", true, item->url, true) .
                                "</div>
                                <div class='dd-col-2'>" . 
                                    button->delete(item->id, "delete-url", "delete_old_url") .
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

    private function renderStacks(model, input, files, button)
    {
        var key, key_stack, item, item_stack, html = "";

        let html = "
        <div id='stack-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title'>
                        <span>Stacks</span>" .
                        input->inputPopup("create-stack", "create_stack", "Create a new stack") .
                        "
                    </div>
                    <div class='dd-box-body'>";

        if (count(model->stacks)) {
            let html .= "<div class='stacks'>";
            for key, item in model->stacks {
                let item->stacks = this->database->all("
                    SELECT
                        content_stacks.*,
                        files.id AS image_id,
                        IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "', files.filename), '') AS image,
                        IF(files.filename IS NOT NULL, CONCAT('" . files->folder . "thumb-', files.filename), '') AS thumbnail  
                    FROM content_stacks 
                    LEFT JOIN files ON files.resource_id = content_stacks.id AND files.deleted_at IS NULL 
                    WHERE content_stack_id='" . item->id . "' AND content_stacks.deleted_at IS NULL
                    ORDER BY sort ASC");
                let html .= "
                    <div class='stack'>
                        <div class='stack-header'>
                            <h3>" . item->name . "</h3>" .
                            input->inputPopup(
                                "create-stack-item-" . (key + 1),
                                "add_to_stack[" . item->id . "]",
                                "Add to the " . item->name . " stack",
                                "add") .
                            button->delete(item->id, "delete-stack-" . item->id, "delete_stack[]") .
                            "
                        </div>
                        <div class='stack-body'>" .
                        input->text("Name", "stack_name[]", "The name of the stack", true, item->name) .
                        input->text("Title", "stack_title[]", "The title of the stack", false, item->title) .
                        input->text("Sub title", "stack_sub_title[]", "The sub title for the stack", false, item->sub_title) .
                        input->wysiwyg("Description", "stack_description[]", "The stack description", false, item->description) . 
                        input->tags("Tags", "stack_tags[]", "Tag the content stack", false, item->tags) . 
                        input->image("Image", "stack_image[]", "Upload an image here", false, item) . 
                        input->number("Sort", "stack_sort[]", "Sort the stack item", false, item->sort) .
                        input->hidden("stack_id[]", item->id) . 
                        "<hr />" ;
                for key_stack, item_stack in item->stacks {
                    let html .= "
                    <div class='sub-stack'>" .
                        "<div class='stack-header'>
                            <h3>" . item_stack->name . "</h3>" .
                            button->delete(item_stack->id, "delete-stack-" . item_stack->id, "delete_stack[]") .
                        "</div>
                        <div class='stack-body'>" .
                            input->text("Name", "sub_stack_name[]", "The name of the stack", true, item_stack->name) .
                            input->text("Title", "sub_stack_title[]", "The title of the stack", false, item_stack->title) .
                            input->text("Sub title", "sub_stack_sub_title[]", "The sub title for the stack", false, item_stack->sub_title) .
                            input->wysiwyg("Description", "sub_stack_description[]", "The stack description", false, item_stack->description) . 
                            input->image("Image", "sub_stack_image[]", "Upload an image here", false, item_stack) . 
                            input->number("Sort", "sub_stack_sort[]", "Sort the stack item", false, item_stack->sort) .
                            input->hidden("sub_stack_id[]", item_stack->id) . 
                        "</div>
                    </div>";
                }
            let html .= "</div>
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

    private function setData(data, input)
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
        let data["tags"] = input->isTagify(_POST["tags"]);
        let data["parent_id"] = _POST["parent_id"];
        let data["featured"] = isset(_POST["featured"]) ? 1 : 0;

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

    private function templatesSelect(model = null)
    {
        var select = [], selected = null, data, input;
        let input = new Input(this->cfg);
        let data = this->database->all("
            SELECT * FROM templates 
            WHERE deleted_at IS NULL 
            ORDER BY is_default DESC, name");
        var iLoop = 0;

        if (model) {
            let selected = model;
        } elseif (isset(_POST["template_id"])) {
            let selected = _POST["template_id"];
        }

        while (iLoop < count(data)) {
            let select[data[iLoop]->id] = data[iLoop]->name;
            if (data[iLoop]->is_default && empty(selected)) {
                let selected = data[iLoop]->id;
            }
            let iLoop = iLoop + 1;
        }

        return input->select(
            "template",
            "template_id",
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

    private function updateStacks(files, input)
    {
        if (!isset(_POST["stack_name"])) {
            return;
        }

        var key, key_sub, id, id_sub, status, data = [];
        for key, id in _POST["stack_id"] {
            let data = [
                "id": id,
                "name": "",
                "title": "",
                "sub_title": "",
                "description": "",
                "sort": 0,
                "tags": ""
            ];

            if (!isset(_POST["stack_name"][key])) {
                throw new ValidationException("Missing name for stack");
            } elseif (empty(_POST["stack_name"][key])) {
                throw new ValidationException("Missing name for stack");
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
            if (isset(_POST["stack_tags"][key])) {
                let data["tags"] = input->isTagify(_POST["stack_tags"][key]);
            }

            let status = this->database->execute(
                "UPDATE content_stacks SET 
                    name=:name,
                    title=:title,
                    sub_title=:sub_title,
                    description=:description,
                    sort=:sort,
                    tags=:tags 
                WHERE id=:id",
                data
            );
        
            if (!is_bool(status)) {
                throw new Exception("Failed to update the stack");
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
                    
                    files->addResource("image", id, "image", true);
                    unset(_FILES["image"]);
                }
            }

            if (isset(_POST["sub_stack_id"])) {
                for key_sub, id_sub in _POST["sub_stack_id"] {
                    let data = [
                        "id": id_sub,
                        "name": "",
                        "title": "",
                        "sub_title": "",
                        "description": "",
                        "sort": 0
                    ];
        
                    if (!isset(_POST["sub_stack_name"][key_sub])) {
                        throw new ValidationException("Missing name for the stack item");
                    } elseif (empty(_POST["sub_stack_name"][key_sub])) {
                        throw new ValidationException("Missing name for the stack item");
                    }
        
                    let data["name"] = _POST["sub_stack_name"][key_sub];
                    if (isset(_POST["sub_stack_title"][key_sub])) {
                        let data["title"] = _POST["sub_stack_title"][key_sub];
                    }
                    if (isset(_POST["sub_stack_title"][key_sub])) {
                        let data["sub_title"] = _POST["sub_stack_sub_title"][key_sub];
                    }
                    if (isset(_POST["sub_stack_description"][key_sub])) {
                        let data["description"] = _POST["sub_stack_description"][key_sub];
                    }
                    if (isset(_POST["sub_stack_sort"][key_sub])) {
                        let data["sort"] = intval(_POST["sub_stack_sort"][key_sub]);
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
                        throw new Exception("Failed to update the stack");
                    }

                    if (isset(_FILES["sub_stack_image"]["name"][key_sub])) {
                        if (!empty(_FILES["sub_stack_image"]["name"][key_sub])) {
                            let _FILES["image"] = [
                                "name": _FILES["sub_stack_image"]["name"][key_sub],
                                "full_path": _FILES["sub_stack_image"]["full_path"][key_sub],
                                "type": _FILES["sub_stack_image"]["type"][key],
                                "tmp_name": _FILES["sub_stack_image"]["tmp_name"][key_sub],
                                "error": _FILES["sub_stack_image"]["error"][key_sub],
                                "size": _FILES["sub_stack_image"]["size"][key_sub]
                            ];
                            
                            files->addResource("image", id_sub, "image", true);
                            unset(_FILES["image"]);
                        }
                    }
                }
            }
        }
    }
}