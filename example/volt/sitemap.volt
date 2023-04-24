{% include './website/volt/header.volt' %}
<div id="tiles">
    {% for item in DUMBDOG.menu.header %}
    <div class='tile'>
        <div class="box">
            <div class="box-title">
                <span>{{ item.name }}</span>
            </div>
            <div class="box-body">&nbsp;</div>
            <div class="box-footer">
                <a href="{{ item.url }}" class="button" title="view {{ item.name }}">
                    <span>
                        view
                    </span>
                </a>
            </div>
        </div>
    </div>
    {% endfor %}
</div>
{% include './website/volt/footer.volt' %}