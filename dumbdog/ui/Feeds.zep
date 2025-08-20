/**
 * Dumb Dog feeds
 *
 * @package     DumbDog\Ui\Feeds
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 *
*/

namespace DumbDog\Ui;

use DumbDog\Controllers\Controller;

class Feeds extends Controller
{
    private url = "";

    public function __globals()
    {
        let this->url = (_SERVER["HTTPS"] ? "https://" : "http://") . _SERVER["SERVER_NAME"];
    }

    public function process(path)
    {
        if(
            path == "/rss" ||
            path == "/rss.xml" ||
            path == "/rss.rss" ||
            path == "/feed.rss"
        ) {
            this->rss();
        } elseif(
            path == "/atom" ||
            path == "/atom.xml" ||
            path == "/atom.atom" ||
            path == "/feed" ||
            path == "/feed.xml" ||
            path == "/feed.atom" ||
            path == "/feeds" ||
            path == "/feeds.xml" ||
            path == "/feeds.atom"
        ) {
            this->atom();
        } elseif(
            path == "/comments/feed" ||
            path == "/comments/feed.xml" ||
            path == "/comments/feed.rss" ||
            path == "/comments.xml" ||
            path == "/comments.rss"
        ) {
            this->rss("comments");
        } elseif(
            path == "/comments/feed.atom" ||
            path == "/comments.atom"
        ) {
            this->atom("comments");
        } elseif(
            path == "/news/feed" ||
            path == "/news/feed.xml" ||
            path == "/news/feed.rss" ||
            path == "/news.xml" ||
            path == "/news.rss"
        ) {
            this->rss("news");
        } elseif(
            path == "/news/feed.atom" ||
            path == "/news.atom"
        ) {
            this->atom("news");
        } elseif(path == "/robots.txt") {
            this->robots();
        } elseif(path == "/sitemap.xml") {
            this->sitemap();
        } elseif(path == "/humans.txt") {
            this->humans();
        }
    }

    private function atom(string type = "")
    {
        var pages, page;
                
        header("Content-Type: text/xml");
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
        echo "<feed xmlns=\"http://www.w3.org/2005/Atom\">";
        echo "<title>" . htmlspecialchars(this->cfg->settings->name, ENT_XML1) . "</title>\n";
        echo "<link>" . htmlspecialchars(this->url, ENT_XML1) . "</link>\n";
        echo "<summary>" . htmlspecialchars(this->cfg->settings->meta_description, ENT_XML1) . "</summary>\n";

        let pages = this->getPages(type);
        if (pages) {
            for page in pages {
                echo "<entry>";
                echo "<title>" . htmlspecialchars(page->name, ENT_XML1) . "</title>\n";
                echo "<link>" .   htmlspecialchars(this->url . page->url, ENT_XML1) . "</link>\n";
                echo "<published>" . (new \DateTime($page->created_at))->format(\DateTime::ATOM) . "</published>\n";
                echo "<updated>" . (new \DateTime($page->updated_at))->format(\DateTime::ATOM) . "</updated>";
                if (page->slogan) {
                    echo "<summary>" .  htmlspecialchars(page->slogan, ENT_XML1) . "</summary>\n";
                } elseif (page->meta_description) {
                    echo "<summary>" .  htmlspecialchars(page->meta_description, ENT_XML1) . "</summary>\n";
                }
                if (page->subtitle) {
                    echo "<subtitle>" . htmlspecialchars(page->sub_title, ENT_XML1) . "</subtitle>\n";
                }
                if (page->content) {
                    echo "<content type=\"html\">\n" .
                        htmlspecialchars(page->content, ENT_XML1) .
                    "\n</content>\n";
                }
                echo "</entry>\n";                      
            }    
        }
        echo "</feed>";
        exit(0);
    }

    private function humans()
    {
        header("Content-Type: text/plain");
        if (!empty(this->cfg->settings->humans_txt)) {
            echo this->cfg->settings->humans_txt;
        } else {
            echo "/* TEAM */\n";
            echo "Your title: " . this->cfg->settings->name . "\n";
            echo "Site: " . this->cfg->settings->name . "\n";
            if (!empty(this->cfg->settings->address)) {
                echo "Location: " . str_replace("\n", ", ", this->cfg->settings->address) . "\n";
            }
            echo "/* SITE */\n";
            if (!empty(this->cfg->settings->last_update)) {
                echo "Last update: " . date("Y/m/d", strtotime(this->cfg->settings->last_update)) . "\n";
            }
            echo "Doctype: HTML5\n";
        }
        exit(0);
    }

    private function getPages(string type = "")
    {
        var query, data = [];

        let query = "SELECT content.* FROM content 
        WHERE content.status='live' AND content.sitemap_include=1 AND content.deleted_at IS NULL";

        switch (type) {
            case "comments":
                let query .= " AND type IN ('reviews')";
                let data["type"] = type;
                break;
            case "news":
                let query .= " AND type IN ('blog', 'blog-category')";
                let data["type"] = type;
                break;
        }

        return this->database->all(query, data);
    }

    private function robots()
    {
        header("Content-Type: text/plain");
        echo this->cfg->settings->robots_txt;
        exit(0);
    }

    private function rss(string type = "")
    {
        var pages, page;

        header("Content-Type: text/xml");
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
        echo "<rss version=\"2.0\">";
        echo "<channel>\n";
        echo "<title>" . htmlspecialchars(this->cfg->settings->name, ENT_XML1) . "</title>\n";
        echo "<link>" . htmlspecialchars(this->url, ENT_XML1) . "</link>\n";
        echo "<description>" . htmlspecialchars(this->cfg->settings->meta_description, ENT_XML1) . "</description>\n";

        let pages = this->getPages(type);

        if (pages) {
            for page in pages {
                echo "<item>";
                echo "<title>" . htmlspecialchars(page->name, ENT_XML1) . "</title>\n";
                echo "<link>" .   htmlspecialchars(this->url . page->url, ENT_XML1) . "</link>\n";
                echo "<guid>" .   htmlspecialchars(this->url . page->url, ENT_XML1) . "</guid>\n";
                echo "<pubDate>" . (new \DateTime($page->created_at))->format(\DateTime::ATOM) . "</pubDate>\n";
                if (page->slogan) {
                    echo "<description>" .  htmlspecialchars(page->slogan, ENT_XML1) . "</description>\n";
                } elseif (page->meta_description) {
                    echo "<description>" .  htmlspecialchars(page->meta_description, ENT_XML1) . "</description>\n";
                }
                echo "</item>\n";                      
            }    
        }

        echo "</channel>\n";
        echo "</rss>";
        exit(0);
    }

    private function sitemap()
    {
        var pages, page;
        let pages = this->getPages();

        if (pages) {
            header("Content-Type: text/xml");
            echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
            echo "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">";
            for page in pages {
                echo "<url>";
                echo "<loc>" .  this->url . page->url . "</loc>";
                echo "<lastmod>" . (new \DateTime(page->updated_at))->format(\DateTime::ATOM) . "</lastmod>";
                echo "</url>";
            }
            echo "</urlset>";
        }
        exit(0);
    }

    public function siteTags()
    {
        echo "<link rel=\"alternate\" type=\"application/atom+xml\"
            title=\"Feed for " . this->cfg->settings->name . "\" 
            href=\"/atom.xml\">";
        echo "<link rel=\"alternate\" type=\"application/rss+xml\" 
            title=\"Feed for " . this->cfg->settings->name . "\" 
            href=\"/rss.xml\" />";
        echo "<link rel=\"author\" href=\"/humans.txt\">";
        /*
        <link rel="search" type="application/opensearchdescription+xml" title="Dumb Dog" href="/opensearch.xml">
        
        */
    }
}