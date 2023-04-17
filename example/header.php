<head>
    <title><?= $dd_page->name; ?> | <?= $dd_site->name; ?></title>
    <link rel="icon" type="image/png" sizes="64x64" href="/assets/dumbdog.png">
    <link rel="stylesheet" type="text/css" href="<?= $dd_site->theme . '?t=' . time(); ?>">
    <meta name="description" content="<?= $dd_page->meta_description ? $dd_page->meta_description : $dd_site->meta_description; ?>">
    <meta name="keywords" content="<?= $dd_page->meta_keywords ? $dd_page->meta_keywords : $dd_site->meta_keywords; ?>">
    <meta name="author" content="<?= $dd_page->meta_author ? $dd_page->meta_author : $dd_site->meta_author; ?>">
</head>