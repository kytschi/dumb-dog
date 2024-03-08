/**
 * Dumb Dog head builder
 *
 * @package     DumbDog\Ui\Head
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace DumbDog\Ui;

use DumbDog\Ui\Javascript;
use DumbDog\Ui\Style;

class Head
{
    private cfg;

    public function __construct()
    {
        let this->cfg = constant("CFG");   
    }

    public function build(string location)
    {
        var style, js;

        let js = new Javascript();
        let style = new Style();

        return "<head>
            <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
            <link rel='icon' type='image/png' sizes='64x64' href='data:image/png;base64," . this->favicon() . "'>" .
            "<title>" . location . " | dumb dog</title>" .
            style->build() .
            js->build() .
            "<meta http-equiv='cache-control' content='no-cache'>
        </head>";
    }

    public function favicon()
    {
        return "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52MECO4C9arjfB87Tv0E8D8DV3rTX64BM5+kV5ta5Ajo2QYurpuasgdc7gADT4Zsyq7kpynkcsD7GX1TBui7BbrWvN4a+zh9AFLUVeIGODgERvOUvd7m3Z2tvf17ptHfDz6mcpLznCBQAAAPi2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNC40LjAtRXhpdjIiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgeG1sbnM6aXB0Y0V4dD0iaHR0cDovL2lwdGMub3JnL3N0ZC9JcHRjNHhtcEV4dC8yMDA4LTAyLTI5LyIKICAgIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIgogICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgIHhtbG5zOnBsdXM9Imh0dHA6Ly9ucy51c2VwbHVzLm9yZy9sZGYveG1wLzEuMC8iCiAgICB4bWxuczpHSU1QPSJodHRwOi8vd3d3LmdpbXAub3JnL3htcC8iCiAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgeG1wTU06RG9jdW1lbnRJRD0iZ2ltcDpkb2NpZDpnaW1wOjU1YzhkYTA2LTc4ZmYtNDU3My1hY2FhLWE3NjBiN2I5ODYxZSIKICAgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo4YzY1YzA2Ni0yMGM0LTRhMzktOGFlYi1lMjA5ZDg0NTI5NmUiCiAgIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDoyN2ZjY2EwYi1kYTBjLTRmM2MtYWM1Zi0zZjUzZjc0ZWNlNGIiCiAgIEdJTVA6QVBJPSIyLjAiCiAgIEdJTVA6UGxhdGZvcm09IkxpbnV4IgogICBHSU1QOlRpbWVTdGFtcD0iMTY4MTc2NTY5MjAzNjQwNiIKICAgR0lNUDpWZXJzaW9uPSIyLjEwLjIyIgogICBkYzpGb3JtYXQ9ImltYWdlL3BuZyIKICAgdGlmZjpPcmllbnRhdGlvbj0iMSIKICAgeG1wOkNyZWF0b3JUb29sPSJHSU1QIDIuMTAiPgogICA8aXB0Y0V4dDpMb2NhdGlvbkNyZWF0ZWQ+CiAgICA8cmRmOkJhZy8+CiAgIDwvaXB0Y0V4dDpMb2NhdGlvbkNyZWF0ZWQ+CiAgIDxpcHRjRXh0OkxvY2F0aW9uU2hvd24+CiAgICA8cmRmOkJhZy8+CiAgIDwvaXB0Y0V4dDpMb2NhdGlvblNob3duPgogICA8aXB0Y0V4dDpBcnR3b3JrT3JPYmplY3Q+CiAgICA8cmRmOkJhZy8+CiAgIDwvaXB0Y0V4dDpBcnR3b3JrT3JPYmplY3Q+CiAgIDxpcHRjRXh0OlJlZ2lzdHJ5SWQ+CiAgICA8cmRmOkJhZy8+CiAgIDwvaXB0Y0V4dDpSZWdpc3RyeUlkPgogICA8eG1wTU06SGlzdG9yeT4KICAgIDxyZGY6U2VxPgogICAgIDxyZGY6bGkKICAgICAgc3RFdnQ6YWN0aW9uPSJzYXZlZCIKICAgICAgc3RFdnQ6Y2hhbmdlZD0iLyIKICAgICAgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo4YjQ4NTM5OC0wYzMyLTRlNmItYTMwNy0xZDhjNDM0YWNjMTEiCiAgICAgIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkdpbXAgMi4xMCAoTGludXgpIgogICAgICBzdEV2dDp3aGVuPSIrMDE6MDAiLz4KICAgIDwvcmRmOlNlcT4KICAgPC94bXBNTTpIaXN0b3J5PgogICA8cGx1czpJbWFnZVN1cHBsaWVyPgogICAgPHJkZjpTZXEvPgogICA8L3BsdXM6SW1hZ2VTdXBwbGllcj4KICAgPHBsdXM6SW1hZ2VDcmVhdG9yPgogICAgPHJkZjpTZXEvPgogICA8L3BsdXM6SW1hZ2VDcmVhdG9yPgogICA8cGx1czpDb3B5cmlnaHRPd25lcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkNvcHlyaWdodE93bmVyPgogICA8cGx1czpMaWNlbnNvcj4KICAgIDxyZGY6U2VxLz4KICAgPC9wbHVzOkxpY2Vuc29yPgogIDwvcmRmOkRlc2NyaXB0aW9uPgogPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgIAo8P3hwYWNrZXQgZW5kPSJ3Ij8+micZnAAAAAZiS0dEAAAAAAAA+UO7fwAAAAlwSFlzAAALEgAACxIB0t1+/AAAAAd0SU1FB+cEERUIDAEysBgAACAASURBVHja5Zt3lFzVle5/56ZKXdU5qpO6W6mVI5IQBixACAM2CBgw0dgk2zgxHgawxwGnNWCbMTYGwwAm2EbCWIggEBaIIISEUGzF7pY6qnNXdVVXuunMH9VKSAiZ8TzPe++s1Uuqqlt1z/3OPnt/e3/7CP5BI502haapqKoqD74npVQAbe/ePWrj3r2UV5Tb06bNsPhfPMQ/4qZXXHGFd/uOnYU+r6+orbNndGFeaKZwrfJRJYXTcnOy8gIBn0/XNdVxHCceTybC0fhwd+/gBynLbmtu7dmcm+NryQ4E+wsK8nreefvtpBDC/X8SwEsvW6Jt2rQ1mE7boQnjxoxubG6aU1aUd25pcf6M4qL8QFXlKKWyrEQU5GeLYFYQxzZRFBVXgpQSASiKgqopKAJM26Grp5/9LQfcjgNdsm8gbEaj8db+wXCni9YSjQ43B7ICjcl0emNh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";
    }
}