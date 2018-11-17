<?php
$lang = isset($_GET['pack']) ? $_GET['pack'] : 'en-us';
$updateId = isset($_GET['id']) ? $_GET['id'] : 0;

require_once 'api/listeditions.php';
require_once 'shared/main.php';

$editions = uupListEditions($lang, $updateId);
if(isset($editions['error'])) {
    throwError($editions['error']);
}

$editions = $editions['editionFancyNames'];
asort($editions);

logToFile('API returned '.count($editions).' editions for '.$updateId.' '.$lang);

foreach($editions as $key => $val) {
    echo $key;
    echo '|';
    echo $val;
    echo "\n";
}
