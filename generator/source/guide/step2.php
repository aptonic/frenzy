<?php $page = "Getting Started" ?>
<?php include("../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<?php $invite_noinvite = ($_GET['hasinvite'] ? "invite/" : "noinvite/") ?>
		<div id="getting-started">
			<h3>Step 2</h3>
			<a href="<?=$invite_noinvite?>hasdropbox/step3">I already have Dropbox installed, but I've never used Frenzy.</a>
			<h1 class="or">OR</h1>
			<a href="<?=$invite_noinvite?>nodropbox/step3">I've never used Dropbox or Frenzy.</a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../footer.php") ?>