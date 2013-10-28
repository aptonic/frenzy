<?php $page = "Getting Started" ?>
<?php include("../../../header.php") ?>

		<h1 class="getting-started">Getting Started</h1>
	
		<div class="divider"></div>
		
		<div id="getting-started">
			<h3>STEP <?=$step_num ?></h3>
			<p>Frenzy works with the shared folders feature of Dropbox.</p>
			<p>When you launch Frenzy for the first time, if you don't have any shared folders setup, you'll be presented with the following dialog:</p>
			<img width="748" height="428" class="shadowed" src="../../images/create-shared-folder.jpg">
			<p>If you wish, you can change the name of the shared folder to be created. For example, if you were planning to share things with your family, you might call the folder 'Family'</p>
			
			<p>You can then click Create shared folder.</p>
			
			<p>Frenzy will open a web browser and direct you to the Dropbox website. You may be asked to login to Dropbox first. You will then see the below page:</p>
			<img width="821" height="654" class="shadowed" src="../../images/dropbox-share.jpg">
			<p>You should enter the email address of the person you wish to use Frenzy with. If you want, you can invite multiple people by entering multiple email addresses, each separated by a comma. </p>
			<p>In the personal message box, it's a good idea to include the URL <span style="font-weight:bold">http://frenzyapp.com/invite</span> - this is a special URL we have setup that links to a guide much like the one you're reading now that helps your friends get setup with Frenzy.</p>
			
			<p>Once you've filled in the fields, click Share Folder. The below dialog should appear:</p>
			<img width="516" height="432" class="shadowed" src="../../images/folder-shared.jpg">
			
			<p>Everything above only applies if you don't have any shared folders setup. If you already have one or more shared folders setup, Frenzy will automatically detect them and you will instead see the below dialog:</p>
			<img width="692" height="450" class="shadowed" src="../../images/select-folders.jpg">
			<p>You should tick the shared folders you wish to use Frenzy with and click Continue. If you need to create a new shared folder, you should quit Frenzy, create a shared folder using the steps given <a href="https://www.dropbox.com/help/19" target="_BLANK">here</a> and then relaunch Frenzy.</p>
			
			<p>This list will not show shared folders that are in subfolders. To use Frenzy with a shared folder that is in a subfolder, click Choose Folder...</p>
			<a href="step<?=$original_step_num + 1?><?=$append_has_invite?>"><img src="../../images/buttons/continue.jpg"></a>
		</div>
		
		<div class="divider"></div>
		
<?php include("../../../footer.php") ?>