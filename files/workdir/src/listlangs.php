<?php
$updateId = isset($argv[1]) ? $argv[1] : 0;

require_once 'api/listlangs.php';
$langs = uupListLangs($updateId);
$langs = $langs['langFancyNames'];
asort($langs);

consoleLogger('API returned '.count($langs).' languages for '.$updateId);

foreach($langs as $key => $val) {
    echo $key;
    echo '|';
    echo $val;
    echo "\n";
}
?>
