<?php
$pages = $DUMBDOG->pages->get();
require_once("./website/header.php");
?>
<div id="tiles">
<?php
foreach ($pages as $item) {
    ?>
    <div class='tile'>
        <div class="box">
            <div class="box-title">
                <span><?= $item->name; ?></span>
            </div>
            <div class="box-body">&nbsp;</div>
            <div class="box-footer">
                <a href="<?= $item->url; ?>" class="button" title="view <?= $item->name;?>">
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