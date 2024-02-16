/**
 * Dumb Dog Button builder
 *
 * @package     DumbDog\Ui\Gfx\Button
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Ui\Gfx;

use DumbDog\Ui\Gfx\Icons;

class Button
{
    private icons;

    public function __construct()
    {
        let this->icons = new Icons();
    }

    public function add(string url)
    {
        return "
        <a
            href='" . url ."'
            title='Add an entry'
            class='dd-round'>" . 
            this->icons->add() .
            "<span>Add</span>
        </a>";
    }

    public function back(string url)
    {
        return "
        <a
            href='" . url ."'
            title='Back to list'
            class='dd-round'>" . 
            this->icons->back() .
            "<span>Back</span>
        </a>";
    }

    public function build(string label, string type = "button")
    {
        return "<button type='" . type . "'>" . label . "</button>";
    }

    public function delete(
        string entry,
        string id = "delete",
        string name = "delete",
        string title = "Delete the entry"
    ) {
        return "<button
            type='button'
            class='dd-button'
            data-inline-popup='#" . id . "'
            titile='" . title . "'>" . 
            this->icons->delete() .
            "<span>Delete</span>
        </button>
        <div id='" . id . "' class='dd-inline-popup dd-delete-warning'>
            <div class='dd-inline-popup-body'>
                <span>Are you sure?</span>
                <div class='dd-inline-popup-buttons'>
                    <button 
                        type='button'
                        data-inline-popup-close='#" . id . "'>" .
                        this->icons->cancel() .
                    "</button>
                    <button type='submit' name='" . name . "' value='" . entry . "'>" .
                        this->icons->accept() .
                    "</button>
                </div>
            </div>
        </div>";
    }

    public function edit(string url)
    {
        return "<a href='" . url ."' title='Edit the entry' class='dd-button-blank'>
            <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                <path d='M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z'/>
                <path fill-rule='evenodd' d='M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5z'/>
            </svg>
            <span>Edit</span>
        </a>";
    }

    public function generic(
        string url,
        string label = "button",
        string icon = "",
        string title = "Click to view the page"
    ) {
        return "<a
            href='" . url ."'
            title='" . title . "'
            class='dd-button'>" .
            (icon ? this->icons->{icon}() : "") .
            "<span>" . label . "</span>
        </a>";
    }

    public function recover(string entry, string id = "recover", string name = "recover", string title = "Recover the entry")
    {
        return "<button
            type='button'
            data-inline-popup='#" . id . "'
            titile='" . title . "'>" . 
            this->icons->recover() .
            "<span>Recover</span>
        </button>
        <div id='" . id . "' class='dd-inline-popup dd-delete-warning'>
            <div class='dd-inline-popup-body'>
                <span>Are you sure?</span>
                <div class='dd-inline-popup-buttons'>
                    <button 
                        type='button'
                        data-inline-popup-close='#" . id . "'>" .
                        this->icons->cancel() .
                    "</button>
                    <button type='submit' name='" . name . "' value='" . entry . "'>" .
                        this->icons->accept() .
                    "</button>
                </div>
            </div>
        </div>";
    }

    public function round(
        string url,
        string label = "button",
        string icon = "",
        string title = "Click to view the page"
    ) {
        return "<a
            href='" . url ."'
            title='" . title . "'
            class='dd-round'>" .
            (icon ? this->icons->{icon}() : "") .
            "<span>" . label . "</span>
        </a>";
    }

    public function save()
    {
        return "
        <button 
            type='submit'
            name='save'
            title='Save the entry'
            class='dd-button'>" .
            this->icons->save() .
            "<span>Save</span>
        </button>";
    }

    public function view(string url)
    {
        return "
        <a 
            href='" . url ."'
            title='View live'
            class='dd-button'
            target='_blank'>" .
            this->icons->view() .
            "<span>View</span>
        </a>";
    }
}