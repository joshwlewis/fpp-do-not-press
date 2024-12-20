<?php
$playlists = Array();
foreach(scandir($playlistDirectory) as $pFile)
    if ($pFile != "." && $pFile != "..") {
        if (preg_match('/\.json$/', $pFile))  {
            $pFile = preg_replace('/\.json$/', '', $pFile);
            $playlists[$pFile] = $pFile;
        }
    }
?>

<div id="start" class="settings">
<fieldset>
<legend>DO NOT PRESS</legend>

<p>Target Playlist: <?php PrintSettingSelect("TargetPlaylist", "PlaylistSelect", "0", "0", "disabled", $playlists, "do-not-press"); ?></p>
<p>Primary Playlist: <?php PrintSettingSelect("PrimaryPlaylist", "PlaylistSelect", "0", "0", "disabled", $playlists, "do-not-press"); ?></p>

</fieldset>
</div>

<br />
