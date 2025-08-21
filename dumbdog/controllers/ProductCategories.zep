/**
 * Dumb dog product categories
 *
 * @package     DumbDog\Controllers\ProductCategories
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\ContentCategories;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\ValidationException;

class ProductCategories extends ContentCategories
{
    public global_url = "/product-categories";
    public type = "product-category";
    public title = "Product categories";
    public back_url = "/products";

    public list = [
        "name|with_tags",
        "parent",
        "template"
    ];

    private valid_columns = [
        "url",
        "name",
        "status",
        "meta_keywords",
        "meta_author",
        "meta_description",
        "created_at",
        "updated_at"
    ];

    /**
     * I'm used by the helper for the frontend.
     */
    public function get(array filters = [])
    {
        var query, where, join, data = [], order = "", item, item_sub, key;
                
        let query = "
        SELECT
            content.*,
            IF(banner.filename IS NOT NULL, CONCAT('" . this->files->folder . "', banner.filename), '') AS banner_image,
            IF(banner.filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', banner.filename), '') AS banner_thumbnail,
            templates.file AS template 
        FROM content ";

        let join = "LEFT JOIN files AS banner ON banner.resource_id = content.id AND resource='banner-image'
        JOIN templates ON templates.id=content.template_id ";

        let where = " WHERE content.status='live' AND content.deleted_at IS NULL AND content.type = 'product-category'";
                
        if (count(filters)) {
            for key, item in filters {
                switch (key) {
                    case "children":
                        let where .= " AND parent_id=:parent_id";
                        let data["parent_id"] = item;
                        break;
                    case "random":
                        let order .= " ORDER BY RAND() LIMIT " . intval(item);
                        break;
                    case "order":
                        var splits, check, id = 0;
                        let splits = explode(" ", item);
                        let check = reset(splits);
                        if (in_array(check, this->valid_columns)) {
                            let order = " ORDER BY ". check;
                            let id = count(splits);
                            let id -= 1;
                            let check = splits[id];
                            if (in_array(strtoupper(check), this->valid_dir)) {
                                let order .= " ". check;
                            }
                        }
                        break;
                    case "tag":
                        let where .= " AND tags like :tag";
                        let data["tag"] = "%{\"value\":\"" . item . "\"}%";
                        break;
                    case "where":
                        if (isset(item["query"])) {
                            let where .= " AND " . item["query"];
                        }
                        if (isset(item["data"])) {
                            let data = array_merge(data, item["data"]);
                        }
                        break;
                    default:
                        continue;
                }
            }
        }
        
        let data = this->database->all(query . join . where . order, data);

        for item in data {
            let item->stacks = this->database->all("
            SELECT *
            FROM content_stacks
            WHERE content_id='" . item->id . "' AND deleted_at IS NULL AND content_stack_id IS NULL");
            for item_sub in item->stacks {
                let item_sub->stacks = this->database->all("
                SELECT *
                FROM content_stacks
                WHERE content_stack_id='" . item_sub->id . "' AND deleted_at IS NULL");                
            }

            let item->images = this->database->all(
                "SELECT 
                    IF(filename IS NOT NULL, CONCAT('" . this->files->folder . "', filename), '') AS image,
                    IF(filename IS NOT NULL, CONCAT('" . this->files->folder . "thumb-', filename), '') AS thumbnail 
                FROM files 
                WHERE resource_id=:resource_id AND resource='content-image' AND deleted_at IS NULL AND visible=1
                ORDER BY sort ASC",
                [
                    "resource_id": item->id
                ]
            );
        }

        return data;
    }

    public function renderToolbar()
    {
        return "
        <div class='dd-page-toolbar'>" . 
            this->buttons->round(
                this->global_url . "/add",
                "add",
                "add",
                "Add a new " . str_replace("-", " ", this->type)
            ) .
        "</div>";
    }
}