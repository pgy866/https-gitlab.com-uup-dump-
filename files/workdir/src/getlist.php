<?php
$updateId = isset($_GET['id']) ? $_GET['id'] : 'c2a1d787-647b-486d-b264-f90f3782cdc6';
$usePack = isset($_GET['pack']) ? $_GET['pack'] : 0;
$desiredEdition = isset($_GET['edition']) ? $_GET['edition'] : 0;

require_once 'api/get.php';
require_once 'shared/main.php';

logToFile('Attempting to get list of files for '.$updateId.' '.$usePack.' '.$desiredEdition.'...');
$files = uupGetFiles($updateId, $usePack, $desiredEdition, 2);
if(isset($files['error'])) {
    throwError($files['error']);
}

$files = $files['files'];
$filesKeys = array_keys($files);

logToFile('API returned '.count($files).' files for '.$updateId.' '.$usePack.' '.$desiredEdition);

function sortBySize($a, $b) {
    global $files;

    if ($files[$a]['size'] == $files[$b]['size']) {
        return 0;
    }

    return ($files[$a]['size'] < $files[$b]['size']) ? -1 : 1;
}
usort($filesKeys, 'sortBySize');

foreach($filesKeys as $val) {
    echo $val."|".$files[$val]['sha1']."|".$files[$val]['size']."\n";
}
