/**
 * Dumb Dog controller helper
 *
 * @package     DumbDog\Controllers\Controller
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Controllers\Database;
use DumbDog\Exceptions\Exception;
use DumbDog\Exceptions\NotFoundException;
use DumbDog\Exceptions\ValidationException;
use DumbDog\Ui\Gfx\Titles;

class Controller
{   
    protected cfg;
    protected libs;
    public database;

    public global_url = "";

    public function __construct(object cfg, array libs = [])
    {
        let this->cfg = cfg;
        let this->libs = libs;
        let this->database = new Database(this->cfg);
        let this->global_url = this->cfg->dumb_dog_url . this->global_url;

        this->__globals();
    }

    public function __globals()
    {
        //Nothing.
    }

    public function cleanContent(string content)
    {
        var checks = [
            "\\":"&#92;",
            "’": "&#39;"
        ],
        check, replace;

        for check, replace in checks {
            let content = str_replace(check, replace, content);
        }
        return content;
    }

    public function cleanUrl(string url)
    {
        if (strpos(url, "https://") === 0) {
            return url;
        } elseif (strpos(url, "http://") === 0) {
            return url;
        } elseif (strpos(url, "www.") === 0) {
            return url;
        } elseif (strpos(url, "ftp://") === 0) {
            return url;
        } elseif (strpos(url, "sftp://") === 0) {
            return url;
        } elseif (url == "/") {
            return url;
        }

        return preg_replace(
            "~[^-a-zA-Z0-9-/?&=]+~",
            "-",
            strtolower(rtrim(url, "/"))
        );
    }

    public function consoleLogError(string message)
    {
        return "<script type='text/javascript'>console.log('DUMB DOG ERROR:', '" . str_replace(["\n", "\r\n"], "", strip_tags(message)) . "');</script>";
    }

    public function createSlug(string value)
    {
        return str_replace(
            [" "],
            "-",
            str_replace([",", "=", "&", "?", "#", ":", ";", "/", "//", "\\", "\\\\", "’"], "", strtolower(value))
        );
    }

    public function dateToSql(string str)
    {
        var date;
        let date = \DateTime::createFromFormat("d/m/Y H:i:s", str);
        if (empty(date)) {
            throw new \Exception("Failed to process the date");
        }

        return date->format("Y-m-d H:i:s");
    }

    public function deletedState(string message)
    {
        return "<div class='dd-deleted dd-alert'><span>deleted</span></div>";
    }

    public function getLib(string name)
    {
        if (isset(this->libs[name])) {
            return this->libs[name];
        }
        
        return null;
    }

    public function getPageId(string path)
    {
        var splits;

        let splits = explode("/", path);
        return array_pop(splits);
    }

    public function getUserId()
    {
        return this->database->getUserId();
    }

    public function missingRequired(string message = "Missing required fields")
    {
        return "<div class='dd-error dd-box'>
        <div class='dd-box-title'>
            <span>double check your inputs</span>
        </div>
        <div class='dd-box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function redirect(string url)
    {
        header("Location: " . url);
        die();
    }

    public function saveFailed(string message)
    {
        return "<div class='dd-error dd-box'>
        <div class='dd-box-title'>
            <span>save error</span>
        </div>
        <div class='dd-box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function saveSuccess(string message)
    {
        return "<div class='success dd-box'>
        <div class='dd-box-title'>
            <span>save all done</span>
        </div>
        <div class='dd-box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function session(string name, value = null)
    {
        if (value) {
            let _SESSION[name] = value;
            session_write_close();
        } else {
            return isset(_SESSION[name]) ? _SESSION[name] : "";
        }
    }

    public function session_clear(string name = "")
    {
        if (name) {
            unset(_SESSION[name]);
        } else {
            session_destroy();
        }
    }

    public function tags(string path, string table)
    {
        var database, data, html = "";

        let database = new Database(this->cfg);
        let data = database->all("SELECT tags FROM " . table . " WHERE tags IS NOT NULL AND tags != ''");

        if (data) {
            let html .= "<div id='dd-tags'>";
            var selected = "";
            if (isset(_GET["tag"])) {
                let selected = urldecode(_GET["tag"]);
            }
            var tag, json, value, url, tags = [];
            for tag in data {
                let json = json_decode(tag->tags, false, 512, JSON_THROW_ON_ERROR);
                if (empty(json) || !is_array(json)) {
                    continue;
                }

                for value in json {
                    let tags[value->value] = value->value;
                }
            }
            asort(tags);

            for tag in tags {
                let url = path . "?tag=" . urlencode(tag);
                if (selected == tag) {
                    let url = path;
                }
                let html .= "<a href='" . this->cfg->dumb_dog_url . "/" . url . "' class='dd-link dd-tag". 
                    (selected == tag ? " selected" : "") . "'>" . 
                    tag .
                    (selected == tag ? " <span>x</span>" : "") . 
                    "</a>";
            }
            let html .= "</div>";
        }

        return html;
    }

    public function triggerDelete(string table, string path, string id = "")
    {
        var data = [], status = false;

        if (this->cfg->save_mode == true) {
            let data["id"] = id ? id : this->getPageId(path);
            let data["updated_by"] = this->getUserId();
            let status = this->database->execute("
                UPDATE " . table . " 
                SET 
                    deleted_at=NOW(),
                    deleted_by=:updated_by,
                    updated_at=NOW(),
                    updated_by=:updated_by
                WHERE id=:id",
                data
            );
        } else {
            let status = true;
        }

        if (!is_bool(status)) {
            throw new Exception("Failed to delete the entry");
        } else {
            if (strpos(path, "?") !== false) {
                let path = path . "&deleted=true";
            } else {
                let path = path . "?deleted=true";
            }
            this->redirect(path);
        }
    }

    public function triggerRecover(string table, string path, string id = "")
    {
        var data = [], status = false;

        if (this->cfg->save_mode == true) {
            let data["id"] = id ? id : this->getPageId(path);
            let data["updated_by"] = this->getUserId();
            let status = this->database->execute("
                UPDATE " . table . " 
                SET 
                    deleted_at=null,
                    deleted_by=null,
                    updated_at=NOW(),
                    updated_by=:updated_by
                WHERE id=:id",
                data
            );
        } else {
            let status = true;
        }

        if (!is_bool(status)) {
            throw new Exception("Failed to recover the entry");
        } else {
            if (strpos(path, "?") !== false) {
                let path = path . "&recovered=true";
            } else {
                let path = path . "?recovered=true";
            }
            this->redirect(path);
        }
    }

    public function validate(array data, array checks)
    {
        var iLoop = 0;
        while (iLoop < count(checks)) {
            if (!isset(data[checks[iLoop]])) {
                return false;
            } elseif (empty(data[checks[iLoop]])) {
                return false;
            }
            let iLoop = iLoop + 1;
        }
        return true;
    }

    public function validFrom()
    {
        if (isset(_GET["from"])) {
            if (in_array(_GET["from"], ["pages", "products"])) {
                return _GET["from"];
            }
        }
        return "pages";
    }
}