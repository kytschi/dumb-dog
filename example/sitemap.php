<?php
$pages = $DUMBDOG->pages(["where" => ["query" => "sitemap_include=1"]]);
require_once("./website/header.php");
?>
<div class="box">
    <div class="box-body">
    <?php
    foreach ($pages as $item) {
        ?>
        <p>
            <a href="<?= $item->url; ?>" title="view <?= $item->name;?>">
                <span><?= $item->name; ?></span>
            </a>
        </p>
        <?php
    }
    ?>
    </div>
</div>
<?php
require_once("./website/footer.php");
