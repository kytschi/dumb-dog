<?php $this->layout("plates/template", ["DUMBDOG" => $DUMBDOG]); ?>
<?php $this->start('page') ?>
<div class="box">
    <div class="box-body">
        <?= $DUMBDOG->page->content; ?>
    </div>
</div>
<?php $this->stop() ?>