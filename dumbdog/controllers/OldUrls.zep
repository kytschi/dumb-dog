/**
 * Dumb Dog old urls builder
 *
 * @package     DumbDog\Controllers\OldUrls
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
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