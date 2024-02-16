/**
 * Dumb Dog database hanlder
 *
 * @package     DumbDog\Controllers\Database
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
  * Copyright 2024 Mike Welsh
*/
namespace DumbDog\Controllers;

use DumbDog\Exceptions\CfgException;

class Database
{
    private cfg;
    private db;
    public system_uuid = "00000000-0000-0000-0000-000000000000";

    public function __construct(object cfg)
    {
        var connection, username, password;
        let username = "";
        let password = "";

        if (empty(cfg->database)) {
            throw new CfgException("missing database config");
        }

        if (empty(cfg->database->db)) {
            throw new CfgException("missing 'db' from the database config");
        }

        let connection = "mysql:";
        if (!empty(cfg->database->type)) {
            let connection = cfg->database->type . ":";
        }
                
        if (empty(cfg->database->host)) {
            let connection .= "host=localhost;";
        } else {
            let connection .= "host=" . cfg->database->host . ";";
        }
        
        if (!empty(cfg->database->port)) {
            let connection .= "port=" . cfg->database->port . ";";
        }

        let connection .= "dbname=" . cfg->database->db . ";";        

        if (!empty(cfg->database->username)) {
            let username = cfg->database->username;
        }

        if (!empty(cfg->database->password)) {
            let password = cfg->database->password;
        }
                
        let this->cfg = cfg;
        let this->db = new \PDO(connection, username, password);
    }

    public function all(string query, array data = [])
    {
        var statement;
        let statement = this->db->prepare(query);
        statement->execute(data);
        return statement->fetchAll(\PDO::FETCH_CLASS, "DumbDog\\Models\\Model");
    }

    public function execute(string query, array data = [], bool always_save = false)
    {
        /**
         * If save mode is disabled just return, but you can override that with always_save.
         */
        if (this->cfg->save_mode == false && !always_save) {
            return true;
        }
        var statement, status, errors;

        ob_start();
        let statement = this->db->prepare(query);
        let status = statement->execute(data);
        let errors = ob_get_contents();
        ob_end_clean();

        if (!status) {
            return errors;
        }

        return status ? true : false;
    }

    public function get(string query, array data = [])
    {
        var statement;
        let statement = this->db->prepare(query);
        statement->execute(data);
        return statement->fetchObject("DumbDog\\Models\\Model");
    }

    public function getUserId()
    {
        if (isset(_SESSION["dd"])) {
            return _SESSION["dd"];
        }
        return this->system_uuid;
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