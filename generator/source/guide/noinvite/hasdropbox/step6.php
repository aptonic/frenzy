<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<div id="getting-started">
			<h3>FINISHED</h3>
			<p>That's it, you're good to go! Try sharing something.</p>
			<img width="676" height="538" src="../../images/ui-screenshot.jpg">
			
			<?php if ($_GET['last_screen_invited']): ?>
			<p>When your friends share things they will show up in your feed.</p>
			<?php else: ?>
			<p>When your friends join your shared folder and set it up with Frenzy they will see what you shared in their feed.</p>	
			<?php endif; ?>
			
			<p>You can access the Frenzy preferences by clicking on the gear in the top right corner of the main Frenzy window.<br>
			Here you can change your avatar, display name and the hotkey used to share with Frenzy.</p>
			<img width="480" height="408" class="shadowed" src="../../images/preferences-tab1.jpg">
			<p>The Dropbox tab lists detected shared folders. The currently active ones are ticked:</p>
			<img width="480" height="443" class="shadowed" src="../../images/preferences-tab2.jpg">
			<p>Shared folders that are in subfolders are not automatically detected. If you want to use a shared folder with Frenzy that is in a subfolder, click the Choose Folder... button to add it to the list of available folders.</p>
			<p>We hope you enjoy using Frenzy.</p>
			
			<p>If you have questions or feedback, feel free to email us at <a href="mailto:support@aptonic.com">support@aptonic.com</a></p>
			<a href="<?=$path_prefix?>index"><img src="../../images/buttons/home.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>