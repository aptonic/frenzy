<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<p>Accept the folder invitation:</p>
			<img  src="../../images/accept-invite.jpg"><br><br>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?><?=($append_has_invite == "" ? "?" : "&") ?>dropbox_setup=1"><img src="../../images/buttons/continue.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>