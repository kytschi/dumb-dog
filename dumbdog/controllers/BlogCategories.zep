/**
 * Dumb dog blog categories builder
 *
 * @package     DumbDog\Controllers\BlogCategories
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
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
}