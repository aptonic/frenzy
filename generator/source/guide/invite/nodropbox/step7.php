<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<p>When you launch Frenzy for the first time, it will detect the shared folder you just joined.</p>
			<img class="shadowed-smaller" width="592" height="385" src="../../images/frenzy-join-folder.jpg"></a><br />
			<p>Click Continue to use Frenzy with this folder.</p>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?>"><img src="../../images/buttons/continue.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>