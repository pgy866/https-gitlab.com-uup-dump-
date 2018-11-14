<?php
require_once dirname(__FILE__).'/../api/shared/main.php';

function downloadFile($url, $location) {
    $file = fopen($location, 'w+');
    $req = curl_init($url);

    curl_setopt($req, CURLOPT_HEADER, 0);
    curl_setopt($req, CURLOPT_FILE, $file);
    curl_setopt($req, CURLOPT_ENCODING, '');
    curl_setopt($req, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($req, CURLOPT_SSL_VERIFYPEER, 0);

    curl_exec($req);
    curl_close($req);
    fclose($file);
}

function throwError($errorCode) {
    switch ($errorCode) {
        case 'ERROR':
            $errorFancy = 'Generic error.';
            break;
        case '7ZIP_ERROR':
            $errorFancy = '7-Zip has returned an error.';
            break;
        case 'INFO_DOWNLOAD_ERROR':
            $errorFancy = 'Failed to retrieve information.';
            break;
        case 'UNSUPPORTED_API':
            $errorFancy = 'Installed API version is not compatible with this version of UUP dump.';
            break;
        case 'NO_FILEINFO_DIR':
            $errorFancy = 'The fileinfo directory does not exist.';
            break;
        case 'NO_BUILDS_IN_FILEINFO':
            $errorFancy = 'The fileinfo database does not contain any build.';
            break;
        case 'SEARCH_NO_RESULTS':
            $errorFancy = 'No builds could be found for specified query.';
            break;
        case 'UNKNOWN_ARCH':
            $errorFancy = 'Unknown processor architecture.';
            break;
        case 'UNKNOWN_RING':
            $errorFancy = 'Unknown ring.';
            break;
        case 'UNKNOWN_FLIGHT':
            $errorFancy = 'Unknown flight.';
            break;
        case 'UNKNOWN_COMBINATION':
            $errorFancy = 'The flight and ring combination is not correct. Skip ahead is only supported for Insider Fast ring.';
            break;
        case 'ILLEGAL_BUILD':
            $errorFancy = 'Specified build number is less than 15063 or larger than 65536.';
            break;
        case 'ILLEGAL_MINOR':
            $errorFancy = 'Specified build minor is incorrect.';
            break;
        case 'NO_UPDATE_FOUND':
            $errorFancy = 'Server did not return any updates.';
            break;
        case 'EMPTY_FILELIST':
            $errorFancy = 'Server has returned an empty list of files.';
            break;
        case 'NO_FILES':
            $errorFancy = 'There are no files available for your selection.';
            break;
        case 'NO_METADATA_ESD':
            $errorFancy = 'There are no metadata ESD files available for your selection.';
            break;
        case 'UNSUPPORTED_LANG':
            $errorFancy = 'Specified language is not supported.';
            break;
        case 'UNSPECIFIED_LANG':
            $errorFancy = 'Language was not specified.';
            break;
        case 'UNSUPPORTED_EDITION':
            $errorFancy = 'Specified edition is not supported.';
            break;
        case 'UNSUPPORTED_COMBINATION':
            $errorFancy = 'The language and edition combination is not correct.';
            break;
        case 'NOT_CUMULATIVE_UPDATE':
            $errorFancy = 'Selected update does not contain Cumulative Update.';
            break;
        case 'UPDATE_INFORMATION_NOT_EXISTS':
            $errorFancy = 'Information about specified update doest not exist in database.';
            break;
        case 'KEY_NOT_EXISTS':
            $errorFancy = 'Specified key does not exist in update information';
            break;
        case 'UNSPECIFIED_UPDATE':
            $errorFancy = 'Update ID was not specified.';
            break;
        case 'ARIA2_SUPPORT_NOT_ENABLED':
            $errorFancy = 'Support of aria2 has been disabled.';
            break;
        case 'ARIA2_CONNECT_FAIL':
            $errorFancy = 'Could not connect to aria2 RPC.';
            break;
        case 'ARIA2_RPC_ERROR':
            $errorFancy = 'Aria2 RPC has returned an error.';
            break;
        default:
            $errorFancy = $errorCode;
            break;
    }

    consoleLogger('ERROR: '.$errorFancy);
    die(E_ERROR);
}
?>
