/**
 * Dumb Dog groups builder
 *
 * @package     DumbDog\Controllers\Groups
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Models\Group;

class Groups extends Content
{
    public global_url = "/groups";
    public type = "group";
    public list = [
        "name",
        "slug",
        "status"
    ];

    public required = ["name", "slug"];

    public routes = [
        "/groups/add": [
            "Groups",
            "add",
            "create a group"
        ],
        "/groups/edit": [
            "Groups",
            "edit",
            "edit the group"
        ],
        "/groups": [
            "Groups",
            "index",
            "groups"
        ]
    ];

    public system = [];

    public function __globals()
    {
        parent::__globals();

        let this->query = "SELECT 
            groups.*,
            true AS can_edit
            FROM groups 
            WHERE groups.id=:id";

        let this->query_insert = "
            INSERT INTO groups 
                (
                    id,
                    name,
                    slug,
                    status,
                    tags,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by
                ) 
            VALUES 
                (
                    :id,
                    :name,
                    :slug,
                    :status,
                    :tags,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by
                )";

        let this->query_update = "
            UPDATE
                groups
            SET 
                name=:name,
                slug=:slug,
                status=:status,
                tags=:tags,
                updated_at=NOW(),
                updated_by=:updated_by 
            WHERE id=:id";

        let this->system[] = new Group(
            "00000000-0000-0000-0000-000000000001",
            "Super user",
            "su",
            "live",
            false
        );
    }

    public function add(path)
    {
        var html, model;
        let html = this->titles->page("Add a group", "add");
        
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->status = "live";
        let model->name = "";
        let model->slug = "";
        let model->tags = "";
        
        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var data = [], status = false, err;

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    try {
                        let data = this->setData(data, null, model);
                        let data["created_by"] = this->database->getUserId();
                        let data["id"] = this->database->uuid();
                        
                        let status = this->database->execute(
                            this->query_insert,
                            data
                        );

                        if (!is_bool(status)) {
                            let html .= this->saveFailed("Failed to save the group");
                            let html .= this->consoleLogError(status);
                        } else {
                            if (isset(_FILES["file"]["name"])) {
                                if (!empty(_FILES["file"]["name"])) {
                                    this->files->addResource("file", data["id"], "profile");
                                }
                            }
                            let html .= this->saveSuccess("I've saved the group");
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
        var html, model, data = [], status = false;

        let data["id"] = this->getPageId(path);
        let model = this->database->get(
            this->query,
            data
        );

        if (empty(model)) {
            throw new NotFoundException("Group not found");
        }

        let html = this->titles->page("Edit the group", "edit");
        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }
        
        if (!empty(_POST)) {
            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete("groups", path);
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover("groups", path);
                }
            }

            if (isset(_POST["save"])) {
                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data = this->setData(data, null, model);

                    let status = this->database->execute(
                        this->query_update,
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the group");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "/edit/" . model->id . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("I've updated the group");
        }

        let html .= this->render(model);

        return html;
    }

    public function groupSelect(selected = null)
    {
        var select = [], data, item;
        let data = this->database->all("SELECT * FROM groups ORDER BY name");
        
        if (isset(_POST["group_id"])) {
            let selected = _POST["group_id"];
        }

        for item in this->system {
            let select[item->id] = item->name;
        }
        
        for item in data {
            let select[item->id] = item->name;
        }
        
        return this->inputs->select(
            "Group",
            "group_id",
            "What group to they belong to?",
            select,
            true,
            selected
        );
    }

    public function index(path)
    {
        var html;        
        let html = this->titles->page("Groups", "groups");

        if (isset(_GET["deleted"])) {
            let html .= this->saveSuccess("I've deleted the group");
        }

        let html .= this->renderToolbar();

        let html .= 
            this->inputs->searchBox(this->global_url, "Search the groups") .
            this->renderList(path);
        
        return html;
    }

    public function render(model, mode = "add")
    {
        return "
        <form method='post' enctype='multipart/form-data'>
            <div class='dd-tabs dd-mt-4'>
                <div class='dd-tabs-content dd-col'>
                    <div id='content-tab' class='dd-row'>
                        <div class='dd-col-12'>
                            <div class='dd-box'>
                                <div class='dd-box-body'>" .
                                this->inputs->toggle("Live", "status", false, (model->status == "live" ? 1 : 0)) . 
                                this->inputs->text("name", "name", "what is the group called?", true, model->name) .
                                this->inputs->text("slug", "slug", "Slug for the group", true, model->slug) .
                                this->inputs->tags("Tags", "tags", "Tag the group", false, model->tags) . 
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
        var data = [], query, results = [];

        let query = "
            SELECT
                groups.*,
                1 AS can_edit
            FROM groups
            WHERE groups.id IS NOT NULL";
        if (isset(_POST["q"])) {
            let query .= " AND groups.name LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND groups.tags like :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        let query .= " ORDER BY groups.name";

        let results = array_merge(this->system, this->database->all(query, data));

        return this->tables->build(
            this->list,
            results,
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
                        this->buttons->generic(
                            this->global_url . "/add",
                            "",
                            "add",
                            "Add a new group"
                        );
        if (mode == "edit") {
            if (model->deleted_at) {
                let html .= this->buttons->recover(model->id);
            } else {
                let html .= this->buttons->delete(model->id);
            }
        }
        let html .= this->buttons->save() . "</div>
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
                        "Group
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
                this->cfg->dumb_dog_url . "/users",
                "back",
                "back",
                "Back to users"
            ) .
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new group"
            ) .
        "</div>";
    }

    public function setData(array data, user_id = null, model = null)
    {
        let data["name"] = _POST["name"];
        let data["slug"] = this->createSlug(_POST["slug"]);

        if (!model) {
            var found;
            let found = this->database->get(
                "SELECT * FROM groups WHERE name=:name OR slug=:slug",
                [
                    "name": data["name"],
                    "slug": data["slug"]
                ]
            );
            if (found) {
                throw new \Exception("Group name or slug already taken");
            }
        }

        let data["tags"] = 
            (isset(_POST["tags"]) ? 
                this->inputs->isTagify(_POST["tags"]) : 
                (model ? model->tags : null));

        let data["status"] = isset(_POST["status"]) ? 
            "live" :
            (model ? model->status : "offline");

        let data["updated_by"] = user_id ? user_id : this->database->getUserId();

        return data;
    }
}