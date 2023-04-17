<div class="page-toolbar">
    <?php
    foreach ($dd_menu_header as $item) {
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