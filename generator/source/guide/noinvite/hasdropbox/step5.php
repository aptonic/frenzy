<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
		<?php $last_screen_invited_append = (isset($last_screen_invited) ? "last_screen_invited=1" : "") ?>
		<div class="divider"></div>
		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<p>The final Frenzy setup dialog will now be shown.</p>
			<img width="679" height="570" class="shadowed" src="../../images/firstlaunch-complete.jpg">
			<p>This dialog allows you to set the hotkey used for sharing. The default is Control+Option+S<br>You can also change this in the preferences.</p>
			<p>If you have Firefox installed, you will be prompted to install a plugin so that you can use the hotkey to share things while browsing in Firefox. The other supported browsers do not require a plugin.</p>
			<img width="679" height="320" class="shadowed" src="../../images/install-ffplugin.jpg"><br>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?><?=($append_has_invite == "" ? "?" : "&") ?><?=$last_screen_invited_append?>"><img src="../../images/buttons/finish.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>