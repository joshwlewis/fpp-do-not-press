<?php

function getEndpointsfppBigButtons() {
    $result = array();

    $ep = array(
        'method' => 'GET',
        'endpoint' => 'settings',
        'callback' => 'getDoNotPressSettings');

    array_push($result, $ep);

    return $result;
}

// GET /api/plugin/do-not-press/settings
function getDoNotPressSettings() {
    $result = array();
    $result['target_playlist'] = 'do-not-press';
    $result['err_playlist'] = 'do-not-press-err';
    $result['ok_playlist'] = 'do-not-press-ok';

    return json($result);
}

?>
