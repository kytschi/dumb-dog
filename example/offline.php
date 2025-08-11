<!DOCTYPE html>
<html lang='en'>
    <head>
        <title><?= $DUMBDOG->page->name; ?> | <?= $DUMBDOG->site->name; ?></title>
        <link rel="icon" type="image/png" sizes="64x64" href="/website/assets/dumbdog.png">
        <link rel="stylesheet" type="text/css" href="<?= $DUMBDOG->site->theme . '?t=2'; ?>">
        <meta name="description" content="<?= $DUMBDOG->page->meta_description ? $DUMBDOG->page->meta_description : $DUMBDOG->site->meta_description; ?>">
        <meta name="keywords" content="<?= $DUMBDOG->page->meta_keywords ? $DUMBDOG->page->meta_keywords : $DUMBDOG->site->meta_keywords; ?>">
        <meta name="author" content="<?= $DUMBDOG->page->meta_author ? $DUMBDOG->page->meta_author : $DUMBDOG->site->meta_author; ?>">
    </head>
    <body id="home">
        <main>
            <h1 class="page-title">
                <span style="background-image: url(/website/assets/templates.png);">
                    <?= $DUMBDOG->site->offline_title ? $DUMBDOG->site->offline_title : $DUMBDOG->site->name; ?>
                </span>
            </h1>
            <div class="box">
                <div class="box-body">
                    <?= $DUMBDOG->site->offline_content ? $DUMBDOG->site->offline_content : $DUMBDOG->page->content; ?>
                </div>
            </div>
            <footer>
                <div class="footer-item">
                    <img src="/website/assets/dumbdog.png" alt="dumb-dog">
                    <a href="https://github.com/kytschi/dumb-dog" target="_blank">Powered by Dumb Dog</a>
                </div>
            </footer>
        </main>
    </body>
</html>