<?php
$pages = $DUMBDOG->pages->all();
require_once("./website/header.php");
?>
<div id="tiles">
<?php
foreach ($pages as $page) {
    ?>
    <div class='tile'>
        <div class="box">
            <div class="box-title">
                <span><?= $page->name; ?></span>
            </div>
            <div class="box-body">&nbsp;</div>
            <div class="box-footer">
                <a href="<?= $page->url; ?>" class="button" title="view <?= $page->name;?>">
                    <span>
                        view
                    </span>
                </a>
            </div>
        </div>
    </div>
    <?php
}
?>
</div>
<?php require_once("./website/footer.php"); ?>