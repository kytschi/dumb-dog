{include file='smarty/header.tpl'}
<div id="tiles">
    {foreach $DUMBDOG->pages->get() as $item}
    <div class='tile'>
        <div class="box">
            <div class="box-title">
                <span>{$item->name}</span>
            </div>
            <div class="box-body">&nbsp;</div>
            <div class="box-footer">
                <a href="{$item->url}" class="button" title="view {$item->name}">
                    <span>
                        view
                    </span>
                </a>
            </div>
        </div>
    </div>
    {/foreach}
</div>
{include file='smarty/footer.tpl'}