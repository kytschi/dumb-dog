/**
 * Dumb dog blog categories builder
 *
 * @package     DumbDog\Controllers\BlogCategories
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\ContentCategories;

class BlogCategories extends ContentCategories
{
    public global_url = "/blog-categories";
    public type = "blog-category";
    public title = "Blog categories";
    public back_url = "/blog-posts";

    public routes = [
        "/blog-categories/add": [
            "BlogCategories",
            "add",
            "create a blog category"
        ],
        "/blog-categories/edit": [
            "BlogCategories",
            "edit",
            "edit the blog category"
        ],
        "/blog-categories": [
            "BlogCategories",
            "index",
            "blog categories"
        ]
    ];
}