<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<p>You need to download and run the Dropbox application.</p>
			<a target="_BLANK" href="https://www.dropbox.com/install"><img width="150" height="140" src="../../images/dropbox.jpg"></a><br>
			<a target="_BLANK"  href="https://www.dropbox.com/install">Download Dropbox</a>
			<p>When you run Dropbox for the first time, you will be asked to setup an account:</p>
			<img class="shadowed-smaller" width="546" height="498" src="../../images/dropbox-setup1.jpg">
			<p>Fill in your details and click Continue to create a Dropbox account.</p>
			<img class="shadowed-smaller" width="546" height="498" src="../../images/dropbox-setup2.jpg">
			<p>A 2GB free Dropbox account with typical settings is sufficient to use Frenzy.</p>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?>"><img src="../../images/buttons/continue.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>