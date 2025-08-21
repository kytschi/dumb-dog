/**
 * Dumb Dog contacts
 *
 * @package     DumbDog\Controllers\Contacts
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/

namespace DumbDog\Controllers;

use DumbDog\Controllers\Content;
use DumbDog\Exceptions\SaveException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Helper\Security;

class Contacts extends Content
{
    public encrypt = ["first_name", "last_name", "email", "phone", "position"];
    public required = ["first_name"];

    public function save(array data)
    {
        var status, err;

        if (!this->validate(data, this->required)) {
            throw new ValidationException(
                "Missing required fields",
                400,
                this->required
            );
        }

        let data = this->database->encrypt(this->encrypt, data);

        try {
            let status = this->database->execute(
                "INSERT INTO contacts 
                    (
                        id,
                        title,
                        first_name,
                        last_name,
                        email,
                        phone,
                        website,
                        position,
                        tags,
                        status,
                        created_at,
                        created_by,
                        updated_at,
                        updated_by
                    ) 
                VALUES 
                    (
                        :id,
                        :title,
                        :first_name,
                        :last_name,
                        :email,
                        :phone,
                        :website,
                        :position,
                        :tags,
                        :status,
                        NOW(),
                        :created_by,
                        NOW(),
                        :updated_by
                    )",
                    data
            );

            if (!is_bool(status)) {
                throw new SaveException("Failed to save the contact", status);
            }

            return data["id"];
        } catch \Exception, err {
            throw new SaveException(
                "Failed to save the contact",
                err->getCode(),
                err->getMessage()
            );
        }
    }

    public function update(array data)
    {
        var status, err;

        if (!this->validate(_POST, this->required)) {
            throw new ValidationException(
                "Missing required fields",
                400,
                this->required
            );
        }

        let data = this->database->encrypt(this->encrypt, data);

        try {
            let status = this->database->execute(
                "UPDATE contacts 
                SET
                    title=:title,
                    first_name=:first_name,
                    last_name=:last_name,
                    email=:email,
                    phone=:phone,
                    website=:website,
                    position=:position,
                    tags=:tags,
                    status=:status,
                    updated_at=NOW(),
                    updated_by=:updated_by
                WHERE id=:id",
                data
            );
        } catch \Exception, err {
            throw new SaveException(
                "Failed to update the contact",
                err->getCode(),
                err->getMessage()
            );
        }

        if (!is_bool(status)) {
            throw new SaveException(
                "Failed to update the contact",
                status
            );
        }
    }
}