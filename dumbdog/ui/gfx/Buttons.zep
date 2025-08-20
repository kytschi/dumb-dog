/**
 * Dumb Dog Buttons
 *
 * @package     DumbDog\Ui\Gfx\Buttons
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 *
*/
namespace DumbDog\Ui\Gfx;

use DumbDog\Ui\Gfx\Icons;

class Buttons
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
            class='dd-button'>" . 
            this->icons->back() .
            "<span>Back</span>
        </a>";
    }

    public function build(string label, string type = "button")
    {
        return "<button type='" . type . "'>" . label . "</button>";
    }

    public function copy(string url)
    {
        return "<span
            class='dd-button dd-mr-2 clipboard-copy'
            onclick=\"copyTextToClipboard('" . url . "');\" 
            title='Copy to clipboard'>" .
            this->icons->copy() .
        "</span>";
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
            title='" . title . "'>" . 
            this->icons->delete() .
        "</button>
        <div id='" . id . "' class='dd-inline-popup dd-delete-warning'>
            <div class='dd-inline-popup-body dd-flex'>
                <div class='dd-col'><p>Are you sure?</p></div>
                <div class='dd-col-auto'>
                    <button 
                        type='button'
                        class='dd-button' 
                        data-inline-popup-close='#" . id . "'>" .
                        this->icons->cancel() .
                    "</button>
                    <button 
                        type='submit' 
                        class='dd-button' 
                        name='" . name . "'
                        value='" . entry . "'>" .
                        this->icons->accept() .
                    "</button>
                </div>
            </div>
        </div>";
    }

    public function edit(string url)
    {
        return "<a href='" . url ."' title='Edit the entry' class='dd-button-blank'>" . 
            this->icons->edit() .
            "<span>Edit</span>
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
            (label ? "<span>" . label . "</span>" : "") .
        "</a>";
    }

    public function next(string url, string label = "Next page")
    {
        return "
        <a
            href='" . url ."'
            title='" . label . "'
            class='dd-button-blank'>" . 
            this->icons->next() .
        "</a>";
    }

    public function previous(string url, string label = "Previous page")
    {
        return "
        <a
            href='" . url ."'
            title='" . label . "'
            class='dd-button-blank'>" . 
            this->icons->previous() .
        "</a>";
    }

    public function recover(string entry, string id = "recover", string name = "recover", string title = "Recover the entry")
    {
        return "<button
            type='button'
            class='dd-button'
            data-inline-popup='#" . id . "'
            title='" . title . "'>" . 
            this->icons->recover() .
            "
        </button>
        <div id='" . id . "' class='dd-inline-popup dd-delete-warning'>
            <div class='dd-inline-popup-body dd-flex'>
                <div class='dd-col'><p>Are you sure?</p></div>
                <div class='dd-col-auto'>
                    <button 
                        type='button'
                        class='dd-button' 
                        data-inline-popup-close='#" . id . "'>" .
                        this->icons->cancel() .
                    "</button>
                    <button
                        type='submit' 
                        class='dd-button' 
                        name='" . name . "' 
                        value='" . entry . "'>" .
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
        "</button>";
    }

    public function tab(string url)
    {
        return "
        <button 
            data-tab='#" . url . "'
            role='tab'
            aria-controls='" . url . "' 
            aria-selected='true'
            type='button'
            title='Click to go to section'
            class='dd-button'>" .
            this->icons->down() .
        "</button>";
    }

    public function view(string url, string label = "View live")
    {
        return "
        <a 
            href='" . url ."'
            title='" . label . "'
            class='dd-button'
            target='_blank'>" .
            this->icons->view() .
        "</a>";
    }
}