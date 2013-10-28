<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<?php if ($_GET['dropbox_setup'] && !isset($no_dropbox_install)): ?>
			<p>The Dropbox setup is now complete.</p><p>Now you need to download and run Frenzy.</p>
			<?php else: ?>
			<p>Make sure Dropbox is running, and then download and run Frenzy.</p>
			<?php endif; ?>
			<a href="<?=$path_prefix?>downloads/Frenzy-<?=$frenzy_version?>.zip"><img width="128" height="111" src="../../images/frenzy-smaller.jpg"></a><br />
			<a class="download" href="<?=$path_prefix?>downloads/Frenzy-<?=$frenzy_version?>.zip">Download</a>
			<p>Frenzy requires an Intel Mac running OS X 10.5 or later.</p>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?>"><img src="../../images/buttons/continue.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>