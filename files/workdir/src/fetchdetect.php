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

$arch = isset($argv[1]) ? $argv[1] : 'amd64';
$ring = isset($argv[2]) ? $argv[2] : 'WIF';
$flight = isset($argv[3]) ? $argv[3] : 'Active';
$build = isset($argv[4]) ? intval($argv[4]) : 16251;
$minor = isset($argv[5]) ? intval($argv[5]) : 0;
$sku = isset($argv[6]) ? intval($argv[6]) : 48;

require_once 'api/get.php';
require_once 'api/fetchupd.php';
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

consoleLogger(brand('fetchupd'));
$fetchedUpdate = uupFetchUpd($arch, $ring, $flight, $build, $minor, $sku);
if(isset($fetchedUpdate['error'])) {
    throwError($fetchedUpdate['error']);
}

if(!file_exists('packs/'.$fetchedUpdate['updateId'].'.json.gz')) {
    consoleLogger('Generating packs...');
    $files = uupGetFiles($fetchedUpdate['updateId'], 0, 0);
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
        $dataFiles = preg_grep('/DesktopTargetCompDB_.*_.*\./i', $files);
        unset($out);

        exec("$z7z x -o\"$tmp\" \"$loc\" -y", $out, $errCode);
        if($errCode != 0) {
            unlink($loc);
            throwError('7ZIP_ERROR');
        }
        unset($out);

        foreach($dataFiles as $val) {
            consoleLogger('Unpacking info file: '.$val);

            if(preg_match('/.cab$/i', $val)) {
                exec("$z7z x -bb2 -o\"$tmp\" \"$tmp/$val\" -y", $out, $errCode);
                if($errCode != 0) {
                    unlink($loc);
                    throwError('7ZIP_ERROR');
                }

                $temp = preg_grep('/^-.*DesktopTargetCompDB_.*_.*\./i', $out);
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
        $dataFiles = preg_grep('/DesktopTargetCompDB_.*_.*\./i', $filesKeys);

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

                $temp = preg_grep('/^-.*DesktopTargetCompDB_.*_.*\./i', $out);
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

    $langsEditions = array();
    $packages = array();
    foreach($filesToRead as $val) {
        $filNam = preg_replace('/\.xml.*/', '', $val);
        $file = $tmp.'/'.$val;
        $xml = simplexml_load_file($file);

        $lang = preg_replace('/.*DesktopTargetCompDB_.*_/', '', $filNam);
        $edition = preg_replace('/.*DesktopTargetCompDB_|_'.$lang.'/', '', $filNam);

        $lang = strtolower($lang);
        $edition = strtoupper($edition);

        foreach($xml->Packages->Package as $val) {
            foreach($val->Payload->PayloadItem as $PayloadItem) {
                $name = $PayloadItem['Path'];
                $name = preg_replace('/.*\\\/', '', $name);
                $packages[$lang][$edition][] = $name;
            }
        }

        $packages[$lang][$edition] = array_unique($packages[$lang][$edition]);
        sort($packages[$lang][$edition]);

        unlink($file);
        unset($file, $xml, $name, $newName, $lang, $edition);
    }

    $removeFiles = scandir($tmp);
    foreach($removeFiles as $val) {
        if($val == '.' || $val == '..') continue;
        unlink($tmp.'/'.$val);
    }

    if(!file_exists('packs')) mkdir('packs');

    $success = file_put_contents(
        'packs/'.$fetchedUpdate['updateId'].'.json.gz',
        gzencode(json_encode($packages)."\n")
    );

    if($success) {
        consoleLogger('Successfully written generated packs.');
    } else {
        consoleLogger('An error has occured while writing generated packs to the disk.');
    }

}

echo $fetchedUpdate['foundBuild'];
echo '|';
echo $fetchedUpdate['arch'];
echo '|';
echo $fetchedUpdate['updateId'];
echo '|';
echo $fetchedUpdate['updateTitle'];
echo '|';
echo $fetchedUpdate['fileWrite'];
echo "\n";
?>
