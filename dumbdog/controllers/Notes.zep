/**
 * Dumb Dog notes
 *
 * @package     DumbDog\Controllers\Notes
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Database;
use DumbDog\Exceptions\SaveException;
use DumbDog\Ui\Gfx\Button;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Input;

class Notes
{
    protected buttons;
    protected database;
    protected inputs;
    protected icons;

    public function __construct(object cfg)
    {
        let this->buttons = new Button();
        let this->database = new Database(cfg);
        let this->inputs = new Input(cfg);
        let this->icons = new Icons();
    }

    public function render(string resource_id)
    {
        var note, data, html;

        let data = this->database->all(
            "SELECT * FROM notes WHERE resource_id=:resource_id",
            [
                "resource_id": resource_id
            ]
        );

        let html = "
        <div id='notes-tab' class='dd-row'>
            <div class='dd-col-12'>
                <div class='dd-box'>
                    <div class='dd-box-title'>
                        <span>Add a note</span>
                        <div>
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

        for note in data {
            let html .= "<div class='dd-col-12 dd-note'>" .
                        this->database->decrypt(note->content) .
                        "</div>";
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