<!DOCTYPE html>
<html lang='en'>
    <?php require_once("./website/header.php"); ?>
    <body id="home">
        <main>
            <h1 class="page-title">
                <span style="background-image: url(/assets/templates.png);"><?= $dd_page->name; ?></span>
            </h1>
            <?php require_once("./website/menu_header.php"); ?>
            <div class="box">
                <div class="box-body">
                    <?= $dd_page->content; ?>
                </div>
            </div>
            <?php require_once("./website/footer.php"); ?>
        </main>
    </body>
</html>