<!DOCTYPE html>
<html lang='en'>
    <head>
        <title><?= $DUMBDOG->page->title; ?> | <?= $DUMBDOG->site->name; ?></title>
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
                    <?= $DUMBDOG->page->sub_title ? $DUMBDOG->page->sub_title : $DUMBDOG->page->title; ?>
                </span>
            </h1>
            <div class="page-toolbar">
                <?php
                if (count($menu = $DUMBDOG->menusByTag("header"))) {
                    $menu = reset($menu);
                    foreach ($menu->items as $item) {
                        ?>
                        <a 
                            href="<?= $item->url; ?>"
                            class="button"
                            title="<?= $item->alt ? $item->alt : $item->name; ?>">
                            <img src="/website/assets/<?= str_replace(" ", "-", strtolower($item->name)); ?>.png">
                        </a>
                        <?php
                    }
                }
                ?>
                <a href="/dumb-dog" class="button logo" title="Check out my rear-end">
                    <img src="/website/assets/dumbdog.png">
                </a>
            </div>