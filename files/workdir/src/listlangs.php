<?php
require_once 'shared/main.php';

$updateId = isset($_GET['id']) ? $_GET['id'] : 0;

require_once 'api/listlangs.php';
$langs = uupListLangs($updateId);
$langs = $langs['langFancyNames'];
asort($langs);

logToFile('API returned '.count($langs).' languages for '.$updateId);

foreach($langs as $key => $val) {
    echo $key;
    echo '|';
    echo $val;
    echo "\n";
}
