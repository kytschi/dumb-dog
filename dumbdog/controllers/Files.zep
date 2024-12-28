/**
 * Dumb Dog file handler
 *
 * @package     DumbDog\Controllers\Files
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Controller;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Inputs;

class Files extends Controller
{
    public folder = "/website/files/";
    protected inputs;

    public routes = [
        "/files/add": [
            "Files",
            "add",
            "create a file"
        ],
        "/files/edit": [
            "Files",
            "edit",
            "edit the file"
        ],
        "/files": [
            "Files",
            "index",
            "files"
        ]
    ];

    public function __globals()
    {
        let this->inputs = new Inputs();
    }

    public function addResource(
        string input_name,
        string resource_id,
        string resource_name,
        bool delete_old = false
    ) {
        this->insert(input_name, resource_id, resource_name, delete_old);
    }

    private function createFilename(string input_name)
    {
        var security;
        let security = new Security();
        return security->randomString(16) . "-" . this->createSlug(_FILES[input_name]["name"]);
    }

    private function createThumb(image, string filename)
    {
        var width, height, desired_width = 400, desired_height, save;
        
        let width = imagesx(image);
        let height = imagesy(image);

        let desired_height = floor(height * (desired_width / width));
        let save = imagecreatetruecolor(desired_width, desired_height);
        imagesavealpha(save, true);
        imagefill(save, 0, 0, imagecolorallocatealpha(save, 0, 0, 0, 127));
        imagecopyresampled(save, image, 0, 0, 0, 0, desired_width, desired_height, width, height);

        imagewebp(save, getcwd() . this->folder . "thumb-" . filename);
    }

    public function deleteResource(string id, string path)
    {
        var status;
        let status = this->database->execute("
            UPDATE 
                files 
            SET 
                deleted_at=NOW(),
                deleted_by=:deleted_by
            WHERE 
                id=:id",
            [
                "id": id,
                "deleted_by": this->database->getUserId()
            ]
        );
        if (!is_bool(status)) {
            throw new Exception("Failed to delete the file in the database");
        }

        this->redirect(path);
    }

    private function insert(
        string input_name,
        string resource_id = "",
        string resource_name = "",
        bool delete_old = false
    ) {
        var filename, status, data = [];
        let filename = this->createFilename(input_name);
        
        if (delete_old) {
            let status = this->database->execute("
                UPDATE 
                    files 
                SET 
                    deleted_at=NOW(),
                    deleted_by=:deleted_by
                WHERE 
                    resource_id=:resource_id",
                [
                    "resource_id": resource_id,
                    "deleted_by": this->database->getUserId()
                ]
            );
            if (!is_bool(status)) {
                throw new Exception("Failed to delete the old file in the database");
            }
        }
        
        let data["resource"] = resource_name;
        let data["resource_id"] = resource_id;
        let data["name"] =  _FILES[input_name]["name"];
        let data["filename"] = this->saveFile(input_name, filename);
        let data["mime_type"] = mime_content_type(getcwd() . this->folder . data["filename"]);
        let data["created_by"] = this->database->getUserId();
        let data["updated_by"] = this->database->getUserId();
        let data["tags"] = resource_id ? "" : this->inputs->isTagify(_POST["tags"]);
        
        let status = this->database->execute(
            "INSERT INTO files 
                (id,
                resource,
                resource_id,
                name,
                filename,
                mime_type,
                tags,
                created_at,
                created_by,
                updated_at,
                updated_by) 
            VALUES 
                (UUID(),
                :resource,
                :resource_id,
                :name,
                :filename,
                :mime_type,
                :tags,
                NOW(),
                :created_by,
                NOW(),
                :updated_by)",
            data
        );

        if (!is_bool(status)) {
            throw new Exception("Failed to save the file in the database");
        }

        return status;
    }

    public function saveFile(string input_name, string filename)
    {
        var save = true, upload;

        if (this->cfg->save_mode == false) {
            return;
        }

        if (empty(_FILES[input_name]["tmp_name"])) {
            throw new Exception("Failed to upload the file");
        }

        switch (_FILES[input_name]["type"]) {
            case "image/bmp":
                let upload = imagecreatefrombmp(_FILES[input_name]["tmp_name"]);
                break;
            case "image/jpeg":
                let upload = imagecreatefromjpeg(_FILES[input_name]["tmp_name"]);
                break;
            case "image/png":
                let upload = imagecreatefrompng(_FILES[input_name]["tmp_name"]);
                break;
            case "image/x-bmp":
                let upload = imagecreatefrombmp(_FILES[input_name]["tmp_name"]);
                break;
            default:
                copy(
                    _FILES[input_name]["tmp_name"],
                    getcwd() . this->folder . filename
                );
                return filename;
        }

        if (save) {
            let filename = str_replace("." . pathinfo(filename, PATHINFO_EXTENSION), ".webp", filename);
            imagewebp(upload, getcwd() . this->folder . filename);
        }

        this->createThumb(upload, filename);

        return filename;
    }
}