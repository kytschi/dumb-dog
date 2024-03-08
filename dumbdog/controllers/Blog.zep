/**
 * Dumb dog blog
 *
 * @package     DumbDog\Controllers\Blog
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;

class Blog extends Content
{
    public global_url = "/blog-posts";
    public category = "blog-category";
    public type = "blog";
    public title = "Blog";

    public required = ["name", "title", "template_id"];
}