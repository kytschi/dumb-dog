/**
 * Dumb Dog notes
 *
 * @package     DumbDog\Controllers\Notes
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Controllers\Database;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\Dates;
use DumbDog\Ui\Gfx\Buttons;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Inputs;
use DumbDog\Ui\Gfx\Tables;
use DumbDog\Ui\Gfx\Titles;

class Notes extends Controller
{
    protected buttons;
    protected inputs;
    protected icons;
    protected tables;
    protected titles;

    public encrypt = [
        "content"
    ];

    public routes = [
        "/notes/add": [
            "Notes",
            "add",
            "notes"
        ],
        "/notes/delete": [
            "Notes",
            "delete",
            "notes"
        ],
        "/notes/edit": [
            "Notes",
            "edit",
            "notes"
        ],
        "/notes/recover": [
            "Notes",
            "recover",
            "notes"
        ],
        "/notes": [
            "Notes",
            "index",
            "notes"
        ]
    ];

    public title = "Notes";
    public global_url = "/notes";
    public list = [
        "content|decrypt",
        "created_at|date"
    ];
    public required = ["note"];
    public type = "note";

    public query = "";
    public query_insert = "";
    public query_list = "";

    public function __globals()
    {
        let this->buttons = new Buttons();
        let this->inputs = new Inputs();
        let this->icons = new Icons();
        let this->tables = new Tables();
        let this->titles = new Titles();

        let this->query = "
            SELECT notes.*
            FROM notes 
            WHERE notes.id=:id AND notes.resource_id IS NULL";

        let this->query_insert = "
            INSERT INTO notes 
            (
                id,
                user_id,
                resource_id,
                content,
                tags,
                created_by,
                created_at,
                updated_by,
                updated_at
            ) 
            VALUES 
            (
                :id,
                :user_id,
                :resource_id,
                :content,
                :tags,
                :created_by,
                NOW(),
                :updated_by,
                NOW()
            )";

        let this->query_list = "
            SELECT notes.*
            FROM notes 
            WHERE notes.id IS NOT NULL AND notes.resource_id IS NULL AND deleted_at IS NULL ";
    }

    public function actions(string id)
    {
        if (isset(_POST["note"])) {
            if (!empty(_POST["note"])) {
                this->save(id);
            }
        }

        if (isset(_POST["delete_note"])) {
            if (!empty(_POST["delete_note"])) {
                this->delete(_POST["delete_note"]);
            }
        }
    }

    public function add(path)
    {
        var html, data, status = false, model;
        
        let html = this->titles->page("Create a note", "notes");

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                let data = [];

                if (!this->validate(_POST, this->required)) {
                    let html .= this->missingRequired();
                } else {
                    let data["id"] = this->database->uuid();
                    let data["resource_id"] = null;
                    let data["created_by"] = this->database->getUserId();

                    let data = this->setData(data);

                    let data["user_id"] = this->database->getUserId();
                    
                    let status = this->database->execute(
                        this->query_insert,
                        this->database->encrypt(this->encrypt, data)
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to save the note");
                        let html .= this->consoleLogError(status);
                    } else {
                        this->redirect(this->global_url . "?saved=true");
                    }
                }
            }
        }

        if (isset(_GET["saved"])) {
            let html .= this->saveSuccess("Note has been saved");
        }

        let model = new \stdClass();
        let model->deleted_at = null;
        let model->content = "";
        let model->user_id = "";
        let model->resource_id = "";
        let model->tags = "";

        let html .= this->render(null, model, "add");

        return html;
    }

    public function delete(string id)
    {
        var status = false;

        let status = this->database->execute(
            "UPDATE notes 
            SET deleted_at=NOW(),deleted_by=:deleted_by 
            WHERE id=:id",
            [
                "id": id,
                "deleted_by": this->database->getUserId()
            ]
        );

        if (!is_bool(status)) {
            throw new SaveException("Failed to delete the note");
        }
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
            this->tags(path, "notes") .
            this->renderList(path);
        return html;
    }

    public function render(string resource_id = null, data = null, mode = "edit")
    {
        var note, html = "", dates;

        let dates = new Dates();

        if (!empty(_POST)) {
            if (isset(_POST["delete_note"])) {
                this->delete(_POST["delete_note"]);
                this->redirect(this->global_url);
            }
        }

        if (resource_id) {
            let data = this->database->all(
                "SELECT 
                    notes.*,
                    users.nickname AS created_by 
                FROM notes 
                JOIN users ON users.id = notes.created_by
                WHERE resource_id=:resource_id AND notes.deleted_at IS NULL",
                [
                    "resource_id": resource_id
                ]
            );
        } else {
            let html = "<form method='post'>";
        }

        if (!empty(resource_id) && mode == "edit") {
            let html .= "<div class='dd-tabs'><div class='dd-tabs-content dd-col'>";
        } elseif (empty(resource_id)) {
            let html .= "<div class='dd-tabs'><div class='dd-tabs-content dd-col'>";
        }

        let html .= "
                <div id='notes-tab' class='dd-row'>
                    <div class='dd-col-12'>
                        <div class='dd-box'>
                            <div class='dd-box-title dd-flex'>
                                <div class='dd-col'>" .
                                (
                                    (resource_id || mode == "add") ?
                                    "Add a note" :
                                    (data ? dates->prettyDate(data->created_at) : "The note")
                                ) . 
                                "</div>";

                if (resource_id) {
                    let html .= "
                                <div class='dd-col-auto'>
                                    <button 
                                        type='submit'
                                        name='add_note'
                                        title='Add the note'
                                        class='dd-button'>" .
                                        this->icons->add() .
                                    "</button>
                                </div>";
                } elseif(data) {
                    let html .= "
                                <div class='dd-col-auto'>" .
                                    this->buttons->delete(
                                        data->id,
                                        "delete-" . data->id,
                                        "delete_note"
                                    ) .
                                "</div>";
                }

                let html .= "</div>
                            <div class='dd-box-body'>" .
                                this->inputs->textarea(
                                    "Note", 
                                    "note", 
                                    "The note", 
                                    true, 
                                    (is_object(data) ? this->database->decrypt(data->content) : ""),
                                    1000,
                                    (is_object(data) && mode == "edit" ? true : false)
                                ) .
                                this->inputs->tags(
                                    "Tags",
                                    "tags",
                                    "Tag the note",
                                    false, 
                                    (is_object(data) ? data->tags : ""),
                                    (is_object(data) && mode == "edit" ? true : false)
                                ) . 
                            "</div>
                        </div>";

                if (is_array(data)) {
                        let html .= "
                            <div class='dd-box'>
                                <div class='dd-box-title'>Notes</div>
                                <div class='dd-box-body'>
                                    <div class='dd-row'>";
                                    if (count(data)) {
                                        for note in data {
                                            let html .= "
                                                <div class='dd-col-12 dd-note'>
                                                    <div class='dd-row'>
                                                        <div class='dd-note-header dd-pb-3'>
                                                            <div class='dd-float-left'>
                                                                <p>" . note->created_by . "</p>
                                                                <p>" . dates->prettyDate(note->created_at, true, false) . "</p>
                                                            </div>
                                                            <div class='dd-float-right'>" .
                                                            this->buttons->delete(
                                                                note->id,
                                                                "delete_note",
                                                                "delete_note",
                                                                "Delete the note"
                                                            ) . 
                                                        "   </div>
                                                        </div>
                                                        <div class='dd-note-body'>" .
                                                            this->database->decrypt(note->content) .
                                                        "</div>
                                                    </div>
                                                </div>";
                                        }
                                    } else {
                                        let html .= "<div class='dd-col-12 dd-note'><strong>No notes</strong></div>";
                                    }
                        let html .= "</div>
                                </div>
                            </div>";
                }

        let html .= "
                    </div>
                </div>";

        if (empty(resource_id) && mode == "add") {
            let html .= "</div>" .
                this->renderSidebar(data, mode) .
            "</div>
        </form>";
        } elseif (!empty(resource_id) && mode == "edit") {
            let html .= "</div></div>";
        }

        return html;
    }

    public function renderList(path)
    {
        var data = [], query, html = "", note;

        let query = this->query_list . " AND deleted_at IS NULL";
        if (isset(_POST["q"])) {
            let query .= " AND notes.content LIKE :query";
            let data["query"] = "%" . _POST["q"] . "%";
        }
        if (isset(_GET["tag"])) {
            let query .= " AND notes.tags LIKE :tag";
            let data["tag"] = "%{\"value\":\"" . urldecode(_GET["tag"]) . "\"}%"; 
        }
        
        let query .= " ORDER BY notes.created_at DESC";

        let data = this->database->all(
            query,
            data
        );

        for note in data {
            let html .= this->render(null, note, "edit");
        }

        return html;
        
        /*return this->tables->build(
            this->list,
            data,
            this->cfg->dumb_dog_url . "/" . ltrim(path, "/")
        );*/
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
                            "Add a new note"
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
                        "Note
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
                this->global_url . "/add",
                "add",
                "add",
                "Add a note"
            ) .
        "</div>";
    }

    public function save(string resource_id)
    {
        var status = false;

        let status = this->database->execute(
            "INSERT INTO notes SET
                id=UUID(),
                resource_id=:resource_id, 
                content=:content,
                created_at=NOW(),
                created_by=:created_by,
                updated_at=NOW(),
                updated_by=:updated_by",
            [
                "resource_id": resource_id,
                "content": this->database->encrypt(_POST["note"]),
                "created_by": this->database->getUserId(),
                "updated_by": this->database->getUserId()
            ]
        );

        if (!is_bool(status)) {
            throw new SaveException("Failed to save the note");
        } 
    }

     public function setData(array data, user_id = null, model = null)
    {
        let data["content"] = _POST["note"];
        let data["tags"] = isset(_POST["tags"]) ? this->inputs->isTagify(_POST["tags"]) : (model ? model->tags : null);
        let data["updated_by"] = user_id ? user_id : this->database->getUserId();
        let data["user_id"] = user_id ? user_id : (isset(_POST["user_id"]) ? _POST["user_id"] : null);

        return data;
    }
}