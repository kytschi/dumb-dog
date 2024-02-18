/**
 * Dumb Dog contacts
 *
 * @package     DumbDog\Controllers\Contacts
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Security;

class Contacts extends Content
{
    public encrypt = ["first_name", "last_name", "email", "phone", "website", "position"];
    public required = ["first_name"];

    public function save(array data)
    {
        var status, err, save = [], 
            nulls = ["title", "last_name", "email", "phone", "website", "position", "tags"];

        if (!this->validate(data, this->required)) {
            throw new ValidationException("Missing required data");
        }

        let save["first_name"] = data["first_name"];

        for status in nulls {
            if (isset(data[status])) {
                let save[status] = data[status];
            }
        }

        for status in nulls {
            if (!isset(save[status])) {
                let save[status] = null;
            }
        }

        let save["created_by"] = this->database->getUserid();
        let save["updated_by"] = this->database->getUserid();
        let save["id"] = this->database->uuid();

        let save = this->database->encrypt(this->encrypt, save);

        try {
            let status = this->database->execute(
                "INSERT INTO contacts 
                    (id,
                    title,
                    first_name,
                    last_name,
                    email,
                    phone,
                    website,
                    position,
                    tags,
                    created_at,
                    created_by,
                    updated_at,
                    updated_by) 
                VALUES 
                    (:id,
                    :title,
                    :first_name,
                    :last_name,
                    :email,
                    :phone,
                    :website,
                    :position,
                    :tags,
                    NOW(),
                    :created_by,
                    NOW(),
                    :updated_by)",
                    save
            );

            if (!is_bool(status)) {
                throw new SaveException("Failed to save the message", status);
            }
            return save["id"];
        } catch \Exception, err {
            throw err;
        }
    }
}