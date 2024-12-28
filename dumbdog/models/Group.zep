/**
 * Dumb Dog group model
 *
 * @package     DumbDog\Models\Group
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Models;

use DumbDog\Models\Model;

class Group extends Model
{
    public id = "";
    public name = "";
    public slug = "";
    public can_edit = 1;
    public status = "active";
    public created_at = null;
    public created_by = null;
    public updated_at = null;
    public updated_by = null;
    public deleted_at = null;
    public deleted_by = null;

    public function __construct(string id = "", string name = "", string slug = "", string status = "active", int can_edit = 1)
    {
        let this->id = id;
        let this->name = name;
        let this->slug = slug;
        let this->status = status;
        let this->can_edit = can_edit;
    }
}
