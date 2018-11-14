<?php
$lang = isset($argv[1]) ? $argv[1] : 'en-us';
$updateId = isset($argv[2]) ? $argv[2] : 0;

require_once 'api/listeditions.php';

$editions = uupListEditions($lang, $updateId);
if(isset($editions['error'])) {
    throwError($editions['error']);
}

$editions = $editions['editionFancyNames'];
asort($editions);

consoleLogger('API returned '.count($editions).' editions for '.$updateId.' '.$lang);

foreach($editions as $key => $val) {
    echo $key;
    echo '|';
    echo $val;
    echo "\n";
}
