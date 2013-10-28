<?php $page = "Support" ?>
<?php include("header.php") ?>
		
		<h1>Uninstalling Frenzy</h1>
	
		<div class="divider"></div>
		
		<div id="main"> 
		<p>To uninstall Frenzy, click on the Frenzy menu item, then click on the small gear in the top right.<br>Click Quit Frenzy.</p>
		
		<img src="images/quit.jpg">
		
		<p>Navigate to your applications folder and drag the Frenzy application bundle to the trash:</p>

		<img src="images/trash.jpg">
		
		<p>That's it, Frenzy is gone from your system!</p>
		
		<h2>Optional Steps</h2>
		<p>Frenzy creates .frenzy hidden folders inside any Dropbox shared folders that you were using Frenzy with.<br>These folders contain the Frenzy feed items and are not removed automatically.<br><br>There is no harm in leaving these folders as is, but if you want you can remove them yourself by typing the following command into the Terminal application:</p>
		
		<p><code>rm -rf ~/Dropbox/&lt;shared folder&gt;/.frenzy</code></p>
		<p>Replace &lt;shared folder&gt; with the name of the shared folder. You will need to repeat this step for every shared folder you were using Frenzy with.</p>
		<p>Frenzy also creates a folder in your Application Support directory and a preferences file. There is no harm in leaving these where they are, but if you want to remove them, paste the following commands into your Terminal application:</p>
		<p><code>rm -rf ~/Library/Application\ Support/Frenzy<br>
		rm ~/Library/Preferences/com.aptonic.Frenzy.plist</code></p>
		</div>
		
		<div class="divider"></div>

<?php include("footer.php") ?>