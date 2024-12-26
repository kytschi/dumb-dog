/**
 * Dumb Dog tables
 *
 * @package     DumbDog\Ui\Gfx\Tables
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *

*/
namespace DumbDog\Ui\Gfx;

use DumbDog\Helper\Security;
use DumbDog\Ui\Gfx\Icons;
use DumbDog\Ui\Gfx\Titles;

class Tables
{
    private cfg;

    public function __construct()
    {
        let this->cfg = constant("CFG");
    }

    public function build(array columns, array data, string url = "", string from = "")
    {
        var titles, html = "", icons;
        let icons = new Icons();
        
        if (count(data)) {
            var iLoop, iLoop_head, key, splits, security, with_tags;
            let security = new Security();
            let iLoop_head = 0;

            let html .= "
            <table class='dd-table'>
                <thead>
                    <tr>";
                        while (iLoop_head < count(columns)) {
                            let splits = explode("|", columns[iLoop_head]);
                            let key = str_replace("_", " ", splits[0]);

                            if (isset(splits[1])) {
                                if (
                                    !in_array(
                                        splits[1],
                                        [
                                            "bool",
                                            "date",
                                            "decrypt",
                                            "event_date",
                                            "with_tags"
                                        ]
                                    )
                                ) {
                                    let key = splits[1];
                                }
                            }

                            let html .= "<th>" . key . "</th>";
                            let iLoop_head = iLoop_head + 1;
                        }
                        let html .= "
                        <th class='dd-tools'>Tools</th>
                    </tr>
                </thead>
                <tbody>";

                let iLoop = 0;
                while (iLoop < count(data)) {
                    let html .=
                    "<tr" . (data[iLoop]->deleted_at ? " class='dd-deleted'" : "") . ">";

                        let iLoop_head = 0;
                        while (iLoop_head < count(columns)) {
                            let with_tags = false;
                            let splits = explode("|", columns[iLoop_head]);
                            let key = splits[0];
                            let key = data[iLoop]->{key};

                            if (isset(splits[1])) {
                                switch(splits[1]) {
                                    case "bool":
                                        let key = (key) ? "Yes": "No";
                                        break;
                                    case "date":
                                        if (key) {
                                            let key = date("d/m/Y", strtotime(key));
                                        }
                                        break;
                                    case "decrypt":
                                        let key = security->decrypt(key);
                                        break;
                                    case "event_date":
                                        let key = this->eventDate(data[iLoop]->event_length, key);
                                        break;
                                    case "with_tags":
                                        let with_tags = true;
                                        break;
                                }
                            }
                            
                            let html .= "
                            <td>" . key;
                                if (property_exists(data[iLoop], "tags") && with_tags) {
                                    if (!empty(data[iLoop]->tags)) {
                                        var tag;
                                        let html .= "
                                        <div class='dd-tags dd-flex'>";
                                            for tag in json_decode(data[iLoop]->tags) {
                                                let html .= "
                                                <a
                                                    href='" . url . "?tag=" . urlencode(tag->value) . "'
                                                    class='dd-link dd-tag'>" .
                                                    tag->value .
                                                "</a>";
                                            }
                                        let html .= "
                                        </div>";
                                    }
                                }
                            let html .= "
                            </td>";
                            let iLoop_head = iLoop_head + 1;
                        }

                        let html .= "
                        <td class='dd-tools'>";
                        if (property_exists(data[iLoop], "url")) {
                            let html .= "<a  href='" . data[iLoop]->url . "' target='_blank' 
                                class='dd-link'
                                title='View me live'>" . icons->view() . "</a>";
                        }
                        let html .= "
                            <a 
                                href='" . url . "/edit/" . data[iLoop]->id . "'
                                class='dd-link'
                                title='Edit me'>" . icons->edit() . "</a>";
                        let html .= "
                        </td>
                    </tr>";
                    let iLoop = iLoop + 1;
                }
                let html .= "
                </tbody>
            </table>";
        } else {
            let titles = new Titles();
            let html = html . titles->noResults();
        }
        return html;
    }

    private function eventDate(event_length, key)
    {
        switch (event_length) {
            case "all_day":
                let key = date("l jS F", strtotime(key));
                break;
            case "weekly":
                let key = "Every " . date("l", strtotime(key)) .
                    " &#64;" . date("H:i", strtotime(key));
                break;
        }

        return key;
    }
}