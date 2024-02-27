/**
 * Dumb Dog dates helper
 *
 * @package     DumbDog\Helper\Dates
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
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
}