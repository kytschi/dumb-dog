<!DOCTYPE html>
<html lang='en'>
    <head>
        <title><?= $DUMBDOG->page->name; ?> | <?= $DUMBDOG->site->name; ?></title>
        <link rel="icon" type="image/png" sizes="64x64" href="/assets/dumbdog.png">
        <link rel="stylesheet" type="text/css" href="<?= $DUMBDOG->site->theme . '?t=sdsssd'; ?>">
        <meta name="description" content="<?= $DUMBDOG->page->meta_description ? $DUMBDOG->page->meta_description : $DUMBDOG->meta_description; ?>">
        <meta name="keywords" content="<?= $DUMBDOG->page->meta_keywords ? $DUMBDOG->page->meta_keywords : $DUMBDOG->settings->meta_keywords; ?>">
        <meta name="author" content="<?= $DUMBDOG->page->meta_author ? $DUMBDOG->page->meta_author : $DUMBDOG->settings->meta_author; ?>">
    </head>
    <body id="home">
        <main>
            <h1 class="page-title">
                <span style="background-image: url(/assets/templates.png);"><?= $DUMBDOG->page->name; ?></span>
            </h1>
            <div class="page-toolbar">
                <?php
                foreach ($DUMBDOG->menu->header as $item) {
                    ?>
                    <a href="<?= $item->url; ?>" class="button" title="<?= $item->name; ?>">
                        <img src="/website/assets/<?= strtolower($item->name); ?>.png">
                    </a>
                    <?php
                }
                ?>
                <a href="/dumb-dog" class="button logo" title="Check out my rear-end">
                    <img src="/assets/dumbdog.png">
                </a>
            </div>