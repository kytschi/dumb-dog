/**
 * Dumb Dog old urls builder
 *
 * @package     DumbDog\Controllers\OldUrls
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\Exception;

class OldUrls
{
    public function add(database, string content_id)
    {
        var data = [], status = false;

        if (isset(_POST["add_old_url"])) {
            if (!empty(_POST["add_old_url"])) {
                let data["content_id"] = content_id;
                let data["url"] = _POST["add_old_url"];
                let data["created_by"] = database->getUserId();
                let data["updated_by"] = database->getUserId();
                            
                let status = database->execute(
                    "INSERT INTO old_urls 
                        (id,
                        content_id,
                        url,
                        created_at,
                        created_by,
                        updated_at,
                        updated_by) 
                    VALUES 
                        (UUID(),
                        :content_id,
                        :url,
                        NOW(),
                        :created_by,
                        NOW(),
                        :updated_by)",
                    data
                );

                if (!is_bool(status)) {
                    throw new Exception("Failed to save the old url");
                }
            }
        }
    }
}