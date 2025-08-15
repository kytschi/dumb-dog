/**
 * Dumb dog blog
 *
 * @package     DumbDog\Controllers\Blog
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
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

    public routes = [
        "/blog-posts/add": [
            "Blog",
            "add",
            "create a blog entry"
        ],
        "/blog-posts/edit": [
            "Blog",
            "edit",
            "edit the blog entry"
        ],
        "/blog-posts": [
            "Blog",
            "index",
            "blog entries"
        ]
    ];
}