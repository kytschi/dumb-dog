/**
 * Dumb Dog notes
 *
 * @package     DumbDog\Controllers\Notes
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Database;
use DumbDog\Exceptions\SaveException;
use DumbDog\Helper\Dates;
use DumbDog\Ui\Gfx\Buttons;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Inputs;

class Notes
{
    protected buttons;
    protected database;
    protected inputs;
    protected icons;

    public function __construct()
    {
        let this->buttons = new Buttons();
        let this->database = new Database();
        let this->inputs = new Inputs();
        let this->icons = new Icons();
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

    public function render(string resource_id)
    {
        var note, data, html, dates;

        let dates = new Dates();

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

        let html = "
        <div id='notes-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title dd-flex'>
                        <div class='dd-col'>Add a note</div>
                        <div class='dd-col-auto'>
                            <button 
                                type='submit'
                                name='add_note'
                                title='Add the note'
                                class='dd-button'>" .
                                this->icons->add() .
                            "</button>
                        </div>
                    </div>
                    <div class='dd-box-body'>" .
                        this->inputs->text("Note", "note", "Create a note", true) .
                    "</div>
                </div>
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
                        
        let html .= "   </div>
                    </div>
                </div>
            </div>
        </div>";

        return html;
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
}