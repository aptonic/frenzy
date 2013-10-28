<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>

		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<p>You should have received an email invitation from your friend via Dropbox.</p>
			<img src="../../images/folder-shared-dropbox.jpg">
			<p>Click the link shown above in the email you received. You will be directed to the Dropbox website to accept the folder invitation.</p>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?>"><img src="../../images/buttons/continue.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>