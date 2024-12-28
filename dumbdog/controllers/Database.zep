/**
 * Dumb Dog database hanlder
 *
 * @package     DumbDog\Controllers\Database
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Controllers;

use DumbDog\Exceptions\CfgException;
use DumbDog\Helper\Security;

class Database
{
    private cfg;
    private db;
    private security;
    private statement;
    public system_uuid = "00000000-0000-0000-0000-000000000000";

    private connection = "";
    private username = "";
    private password = "";

    public function __construct(cfg = null)
    {
        if (empty(cfg)) {
            let cfg = constant("CFG");
        }

        if (empty(cfg->database)) {
            throw new CfgException("missing database config");
        }

        if (empty(cfg->database->db)) {
            throw new CfgException("missing 'db' from the database config");
        }

        let this->connection = "mysql:";
        if (!empty(cfg->database->type)) {
            let this->connection = cfg->database->type . ":";
        }
                
        if (empty(cfg->database->host)) {
            let this->connection = this->connection . "host=localhost;";
        } else {
            let this->connection = this->connection . "host=" . cfg->database->host . ";";
        }
        
        if (!empty(cfg->database->port)) {
            let this->connection = this->connection . "port=" . cfg->database->port . ";";
        }

        let this->connection = this->connection . "dbname=" . cfg->database->db . ";";        

        if (!empty(cfg->database->username)) {
            let this->username = cfg->database->username;
        }

        if (!empty(cfg->database->password)) {
            let this->password = cfg->database->password;
        }
                
        let this->cfg = cfg;
        let this->security = new Security(cfg);
    }

    public function all(string query, array data = [], string model = "DumbDog\\Models\\Model")
    {
        var results = [];
        
        this->connect();
        let this->statement = this->db->prepare(query);
        this->statement->execute(data);
        let results = this->statement->fetchAll(\PDO::FETCH_CLASS, model);
        this->close();

        return results;
    }

    private function close()
    {
        let this->statement = null;
        let this->db = null;
    }

    private function connect()
    {
        let this->db = new \PDO(this->connection, this->username, this->password);
    }

    public function decrypt(decrypt, model = null)
    {
        var key;

        if (!is_array(decrypt)) {
            return this->security->decrypt(decrypt);
        } else {
            for key in decrypt {
                if (!isset(model->{key})) {
                    continue;
                }

                let model->{key} = this->security->decrypt(model->{key});
            }
            return model;
        }
    }

    public function encrypt(encrypt, array data = [])
    {
        var key;

        if (!is_array(encrypt)) {
            return this->security->encrypt(this->security->clean(encrypt));
        } else {
            for key in encrypt {
                if (!isset(data[key])) {
                    continue;
                }

                let data[key] = this->security->encrypt(this->security->clean(data[key]));
            }

            return data;
        }
    }

    public function execute(string query, array data = [], bool always_save = false)
    {
        /**
         * If save mode is disabled just return, but you can override that with always_save.
         */
        if (this->cfg->save_mode == false && !always_save) {
            return true;
        }

        var status, errors;

        this->connect();

        ob_start();
        let this->statement = this->db->prepare(query);
        let status = this->statement->execute(data);
        let errors = ob_get_contents();
        ob_end_clean();

        this->close();

        if (!status) {
            return errors;
        }

        if (
            substr(query, strlen("DELETE")) == "DELETE" ||
            substr(query, strlen("INSERT")) == "INSERT" ||
            substr(query, strlen("UPDATE")) == "UPDATE"
        ) {
            ob_start();
            let this->statement = this->db->prepare("UPDATE settings SET last_update=NOW() WHERE name IS NOT NULL");
            let status = this->statement->execute();
            let errors = ob_get_contents();
            ob_end_clean();

            if (!status) {
                return errors;
            }
        }

        return true;
    }

    public function get(string query, array data = [])
    {
        var result = null;

        this->connect();

        let this->statement = this->db->prepare(query);
        this->statement->execute(data);

        let result = this->statement->fetchObject("DumbDog\\Models\\Model");

        this->close();

        return result;
    }

    public function isAdmin()
    {
        return this->get("
            SELECT groups.slug
            FROM users
            JOIN groups ON groups.id AND users.group_id 
            WHERE users.id=:id AND groups.slug IN ('su', 'admin')",
            [
                "id": this->getUserId()
            ]
        ) ? true : false;
    }

    public function isManager()
    {
        return this->get("
            SELECT groups.slug
            FROM users
            JOIN groups ON groups.id AND users.group_id 
            WHERE users.id=:id AND groups.slug IN ('su', 'admin', 'manager')",
            [
                "id": this->getUserId()
            ]
        ) ? true : false;
    }

    public function getUserId()
    {
        if (isset(_SESSION["dd"])) {
            return _SESSION["dd"];
        }
        return this->system_uuid;
    }

    public function toDate(string str)
    {
        var date;
        let date = \DateTime::createFromFormat("d/m/Y H:i:s", str);
        if (empty(date)) {
            throw new \Exception("Failed to process the date");
        }

        return date->format("Y-m-d H:i:s");
    }

    public function uuid() {
        return sprintf(
            "%04x%04x-%04x-%04x-%04x-%04x%04x%04x",
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff ) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff)
        );
    }
}