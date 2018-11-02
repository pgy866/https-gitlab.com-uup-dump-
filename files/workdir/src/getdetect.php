<?php
/*
Copyright 2018 UUP dump authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

$updateId = isset($argv[1]) ? $argv[1] : 'c2a1d787-647b-486d-b264-f90f3782cdc6';
$usePack = isset($argv[2]) ? $argv[2] : 0;
$desiredEdition = isset($argv[3]) ? $argv[3] : 0;
$simple = isset($argv[4]) ? $argv[4] : 0;

require_once 'api/get.php';
require_once 'shared/main.php';

if(PHP_OS == 'WINNT') {
    $z7z = realpath(dirname(__FILE__)).'/../7za.exe';
    if(!file_exists($z7z)) throwError('NO_7ZIP');
} else {
    exec('command -v 7z', $out, $errCode);
    if($errCode != 0) {
        throwError('NO_7ZIP');
    }
    $z7z = '7z';
}

$tmp = 'uuptmp';
if(!file_exists($tmp)) mkdir($tmp);

consoleLogger(brand('get'));

$files = uupGetFiles($updateId, 0, 0);
if(isset($files['error'])) {
    throwError($files['error']);
}

$files = $files['files'];
$filesKeys = array_keys($files);

$filesToRead = array();
$aggregatedMetadata = preg_grep('/AggregatedMetadata/i', $filesKeys);
if(!empty($aggregatedMetadata)) {
    sort($aggregatedMetadata);
    $checkFile = $aggregatedMetadata[0];
    $url = $files[$checkFile]['url'];
    $loc = "$tmp/$checkFile";

    consoleLogger('Downloading aggregated metadata: '.$checkFile);
    downloadFile($url, $loc);
    if(!file_exists($loc)) {
        throwError('INFO_DOWNLOAD_ERROR');
    }

    consoleLogger('Unpacking aggregated metadata: '.$checkFile);
    exec("$z7z l -slt \"$loc\"", $out, $errCode);
    if($errCode != 0) {
        unlink($loc);
        throwError('7ZIP_ERROR');
    }

    $files = preg_grep('/Path = /', $out);
    $files = preg_replace('/Path = /', '', $files);

    $checkEd = preg_quote($desiredEdition);
    $lang = preg_quote($usePack);
    unset($out);

    if(!$desiredEdition) {
        $checkEd = '.*';
    }

    $dataFiles = preg_grep('/DesktopTargetCompDB_'.$checkEd.'_'.$lang.'/i', $files);
    if(empty($dataFiles)) {
        throwError('NO_METADATA_ESD');
    }

    foreach($dataFiles as $val) {
        consoleLogger('Unpacking info file: '.$val);
        exec("$z7z e -o\"$tmp\" \"$loc\" \"$val\" -y", $out, $errCode);
        if($errCode != 0) {
            unlink($loc);
            throwError('7ZIP_ERROR');
        }
        unset($out);

        if(preg_match('/.cab$/i', $val)) {
            exec("$z7z x -bb2 -o\"$tmp\" \"$tmp/$val\" -y", $out, $errCode);
            if($errCode != 0) {
                unlink($loc);
                throwError('7ZIP_ERROR');
            }

            $temp = preg_grep('/^-.*DesktopTargetCompDB_'.$checkEd.'_'.$lang.'/i', $out);
            sort($temp);
            $temp = preg_replace('/^- /', '', $temp[0]);

            $filesToRead[] = preg_replace('/.cab$/i', '', $temp);
            unlink("$tmp/$val");
            unset($temp, $out);
        } else {
            $filesToRead[] = $val;
        }
    }
    unlink($loc);
    unset($loc, $checkFile, $checkEd, $dataFiles);
} else {
    $checkEd = preg_quote($desiredEdition);
    $lang = preg_quote($usePack);

    if(!$desiredEdition) {
        $checkEd = '.*';
    }

    $dataFiles = preg_grep('/DesktopTargetCompDB_'.$checkEd.'_'.$lang.'/i', $filesKeys);
    if(empty($dataFiles)) {
        throwError('NO_METADATA_ESD');
    }

    foreach($dataFiles as $val) {
        $url = $files[$val]['url'];
        $loc = "$tmp/$val";

        consoleLogger('Downloading info file: '.$val);
        downloadFile($url, $loc);
        if(!file_exists($loc)) {
            throwError('INFO_DOWNLOAD_ERROR');
        }

        if(preg_match('/.cab$/i', $val)) {
            exec("$z7z x -bb2 -o\"$tmp\" \"$tmp/$val\" -y", $out, $errCode);
            if($errCode != 0) {
                unlink($loc);
                throwError('7ZIP_ERROR');
            }

            $temp = preg_grep('/^-.*DesktopTargetCompDB_'.$checkEd.'_'.$lang.'/i', $out);
            sort($temp);
            $temp = preg_replace('/^- /', '', $temp[0]);

            $filesToRead[] = preg_replace('/.cab$/i', '', $temp);
            unlink("$tmp/$val");
            unset($temp, $out);
        } else {
            $filesToRead[] = $val;
        }
    }
    unset($loc, $checkEd, $dataFiles);
}

$packages = array();
foreach($filesToRead as $val) {
    $file = $tmp.'/'.$val;
    $xml = simplexml_load_file($file);

    foreach($xml->Packages->Package as $val) {
        foreach($val->Payload->PayloadItem as $PayloadItem) {
            $name = $PayloadItem['Path'];
            $name = preg_replace('/.*\\\/', '', $name);

            $newName = preg_replace('/~31bf3856ad364e35/', '', $name);
            $newName = preg_replace('/~~\.|~\./', '.', $newName);
            $newName = preg_replace('/~/', '-', $newName);
            $newName = strtolower($newName);

            $packages[] = $newName;
        }
    }

    unlink($file);
    unset($file, $xml, $name, $newName);
}

$packages = array_unique($packages);
sort($packages);

$files = uupGetFiles($updateId, 0, 0);
if(isset($files['error'])) {
    throwError($files['error']);
}

$files = array_change_key_case($files['files'], CASE_LOWER);

$newFiles = array();
foreach($packages as $val) {
    $newFiles[$val] = $files[$val];
}

$files = $newFiles;
$filesKeys = array_keys($files);

function sortBySize($a, $b) {
    global $files;

    if ($files[$a]['size'] == $files[$b]['size']) {
        return 0;
    }

    return ($files[$a]['size'] < $files[$b]['size']) ? -1 : 1;
}
usort($filesKeys, 'sortBySize');

if($simple == 1) {
    foreach($filesKeys as $val) {
        echo $val."|".$files[$val]['sha1']."|".$files[$val]['url']."\n";
    }
    die();
}

foreach($filesKeys as $val) {
    echo $files[$val]['url']."\n";
    echo '  out='.$val."\n";
    echo '  checksum=sha-1='.$files[$val]['sha1']."\n\n";
}
?>
