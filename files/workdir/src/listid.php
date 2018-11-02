<?php
$search = isset($argv[1]) ? $argv[1] : 0;

require_once 'api/listid.php';
require_once 'shared/main.php';

consoleLogger(brand('listid'));
$ids = uupListIds($search);
if(isset($ids['error'])) {
    throwError($ids['error']);
}

foreach($ids['builds'] as $val) {
    echo $val['build'];
    echo '|';
    echo $val['arch'];
    echo '|';
    echo $val['uuid'];
    echo '|';
    echo $val['title'];
    echo "\n";
}
?>
