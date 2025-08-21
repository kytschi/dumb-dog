/**
 * Dumb Dog dates helper
 *
 * @package     DumbDog\Helper\Dates
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
*/
namespace DumbDog\Helper;

class Dates
{
    public function getTime(datetime, bool seconds = true)
    {
        let datetime = strtotime(datetime);
        return date(seconds ? "H:i:s" : "H:i", datetime);
    }

    public function prettyDate(
        string datetime,
        bool time = true,
        bool seconds = true,
        bool today = false,
        string unknown = "Unknown"
    ) {
        var timestamp, err;

        try {
            if (empty(datetime)) {
                if (today) {
                    return today ? date(time ? (seconds ? "d/m/Y H:i:s" : "d/m/Y H:i") : "d/m/Y") : unknown;
                }
                return unknown;
            }

            if (strtolower(datetime) == "unknown") {
                return unknown;
            }
            let timestamp = strtotime(datetime);
            if (empty(timestamp)) {
                let timestamp = strtotime("NOW");
            }
            return date(
                time ? (seconds ? "d/m/Y H:i:s" : "d/m/Y H:i") : "d/m/Y",
                timestamp
            );
        } catch Exception, err {
            return err ? "Failed to render the date" : "Failed to render the date";
        }
    }

    public function prettyDateFull(
        string datetime,
        bool time = true,
        bool seconds = true,
        bool today = false,
        string unknown = "Unknown"
    ) {
        var timestamp, err;

        try {
            if (empty(datetime)) {
                if (today) {
                    return today ? date(time ? (seconds ? "M dS, Y H:i:s" : "M dS, Y H:i") : "M dS, Y") : unknown;
                }
                return unknown;
            }
            if (strtolower(datetime) == "unknown") {
                return unknown;
            }

            let timestamp = strtotime(datetime);
            if (empty(timestamp)) {
                let timestamp = strtotime("NOW");
            }
            return date(time ? "M jS, Y H:i" : "M jS, Y", timestamp);
        } catch Exception, err {
            return err ? "Failed to render the date" : "Failed to render the date";
        }
    }

    public function toSQL(datetime, bool time = true)
    {
        var splits, err, date;

        try {
            if (empty(datetime)) {
                return null;
            }

            if (is_numeric(datetime)) {
                return null;
            }

            if (!datetime) {
                return null;
            }

            if (time) {
                let splits = explode(" ", datetime);
                if (isset(splits[1])) {
                    let splits = explode(":", splits[1]);
                    if (count(splits) < 3) {
                        let datetime .= ":00";
                    }
                }
            } elseif (strpos(datetime, ":") !== false) {
                let datetime = explode(" ", datetime)[0];
            }

            if (strpos(datetime, "/") !== false) {
                let date = \DateTime::createFromFormat((time ? "d/m/Y H:i:s" : "d/m/Y"), datetime);
                if (empty(date)) {
                    return null;
                }
                if (substr(date->format("Y"), 0, 2) == "00") {
                    let date = \DateTime::createFromFormat((time ? "d/m/y H:i:s" : "d/m/y"), datetime);
                }
                return date->format(time ? "Y-m-d H:i:s" : "Y-m-d");
            }

            let date = strtotime(datetime);
            if (!date) {
                return null;
            }

            return date((time ? "Y-m-d H:i:s" : "Y-m-d"), date);
        } catch Exception, err {
            return err ? "Failed to render the date" : "Failed to render the date";
        }
    }
}