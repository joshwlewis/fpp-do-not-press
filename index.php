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

<p>Target Playlist: <?php PrintSettingSelect("Target Playlist", "TargetPlaylist", "0", "0", "disabled", $playlists, "do-not-press"); ?></p>

<p>Primary Playlist: <?php PrintSettingSelect("Primary Playlist", "PrimaryPlaylist", "0", "0", "disabled", $playlists, "do-not-press"); ?></p>

<p>Success Playlist: <?php PrintSettingSelect("Success Playlist", "SuccessPlaylist", "0", "0", "disabled", $playlists, "do-not-press"); ?></p>

<p>Error Playlist: <?php PrintSettingSelect("Error Playlist", "ErrorPlaylist", "0", "0", "disabled", $playlists, "do-not-press"); ?></p>

<p>Interrupt Cooldown: <?php PrintSettingTextSaved("Cooldown", 0, 0, 1000000, 0, "do-not-press", 360000, "", "", "number"); ?></p>

</fieldset>
</div>

<br />