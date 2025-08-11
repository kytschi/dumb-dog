/**
 * Dumb Dog meta
 *
 * @package     DumbDog\Ui\Meta
 * @author 		Mike Welsh (hello@kytschi.com)
 * @copyright   2025 Mike Welsh
 *
*/
namespace DumbDog\Ui;

use DumbDog\Controllers\Controller;

class Meta extends Controller
{
    public function build(page)
    {
        echo "<meta name=\"referrer\" content=\"origin\">";
        echo "<meta name=\"author\" content=\"" .
            (page->meta_author ? page->meta_author : this->cfg->settings->meta_author) .
            "\">";
        echo "<meta name=\"keywords\" content=\"" .
            (page->meta_keywords ? page->meta_keywords : this->cfg->settings->meta_keywords) .
            "\">";
        echo "<meta name=\"description\" content=\"" .
            (page->meta_description ? page->meta_description : this->cfg->settings->meta_description) .
            "\">";
        echo "<meta name=\"revised\" content=\"" . date("l, F d, H:i a", strtotime(page->updated_at)) . "\">";

        echo "<meta property=\"og:type\" content=\"website\">";
        echo "<meta property=\"og:url\" content=\"" . this->cfg->settings->domain . "\">";
        echo "<meta property=\"og:site_name\" content=\"" . this->cfg->settings->name . "\">";
        echo "<meta property=\"og:image\" itemprop=\"image primaryImageOfPage\" 
            content=\"" . this->cfg->settings->domain ."/website/\">";
    }
}
/*
    <link rel="shortcut icon" href="https://dumbdog">
    <link rel="apple-touch-icon" href="https://dumbdog">
    <link rel="image_src" href="https://dumbdog"> 
    
    <meta name="twitter:card" content="summary">
    <meta name="twitter:domain" content="dumbdog">
    <meta name="twitter:title" property="og:title" itemprop="name" content="Dumb dog">
    <meta name="twitter:description" property="og:description" itemprop="description" content="Dumb dog">
*/