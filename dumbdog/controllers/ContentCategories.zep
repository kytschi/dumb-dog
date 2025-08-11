/**
 * Dumb Dog content categories
 *
 * @package     DumbDog\Controllers\ContentCategories
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\ValidationException;

class ContentCategories extends Content
{
    public global_url = "/page-categories";
    public type = "page-category";
    public title = "Page categories";
    public back_url = "/pages";

    public list = [
        "name|with_tags",
        "parent",
        "template"
    ];

    public routes = [
        "/page-categories/add": [
            "PageCategories",
            "add",
            "create a page category"
        ],
        "/page-categories/edit": [
            "PageCategories",
            "edit",
            "edit the page category"
        ],
        "/page-categories": [
            "PageCategories",
            "index",
            "page categories"
        ]
    ];

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
                this->global_url . "/add",
                "add",
                "add",
                "Add a new " . str_replace("-", " ", this->type)
            ) .
        "</div>";

        return html;
    }
}