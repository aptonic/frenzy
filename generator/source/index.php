<?php $page = "Home" ?>
<?php include("header.php") ?>

		<div id="leftnav" class="unselectable">
			<a class="prev browse left"></a>
		</div>
		
		<div id="scroller" class="scrollable">
			<div class="items unselectable">
				<div>
					<div id="main-panel">
						<img alt="Frenzy Icon" width="300" height="288" src="images/Frenzy.jpg">
						<h1>Frenzy</h1>
						<h2>The Dropbox powered social network</h2>
						<a id="video"><img class="watch" alt="Watch Screencast" width="182" height="34" src="images/watch.jpg"></a> 
					
					</div>
				</div>
				<div>
					<img alt="Frenzy Screenshot" src="images/panel1.jpg">
				</div>
				<div>
					<img alt="Frenzy Screenshot" src="images/panel2.jpg">
				</div>
			</div>
		</div>
		
		<div id="rightnav" class="unselectable">
			<a class="next browse right"></a>
		</div>
		
		<div class="divider"></div>
		
		<div id="container">
			<div id="leftcolumn">
				<h3 class="file">
					File based
				</h3>
				<p>

					Frenzy uses Dropbox to store your feed items and keep everything in sync.
				</p>
				<p>
					You don't need another account and there's no other server involved.
				</p>
				<h3 class="simple">
					Simple and minimal
				</h3>
				<p>
					Frenzy is designed to get out of your way and let you get right back to work.
				</p>
				<p>
					Use the key combo to share what you're looking at, type your message and then Frenzy will immediately return focus back to the application you were using.
				</p>
			</div>
			
			<div id="rightcolumn">
				<h3 class="offline">
					Works offline
				</h3>
				<p>
					Because Frenzy uses Dropbox, your feed items sync whenever you're next online.
				</p>
				<p>
					No more connection problems or fail whales.<br><br>
				</p>
				<h3 class="friends">
					Completely private
				</h3>
				<p>
					Frenzy is designed from the ground up to be for just you and a bunch of your close friends.
				</p>
				<p>
					All the Frenzy data is kept inside your Dropbox folders.
				</p>
			</div>
		</div>
		
		<div class="divider"></div>
		
		<div id="lower-container">
		
			<div id="download-section">
				<p>Frenzy is totally free</p>
				<a href="downloads/Frenzy-<?=$frenzy_version?>.zip"><img width="150" height="47" src="images/download.jpg"></a>
				<p>Frenzy <?=$frenzy_version?></p>
				<p>Requires OS X 10.7+</p><br>
                <div class="share-button">
                        <a href="http://twitter.com/share" class="twitter-share-button" data-url="http://frenzyapp.com/" data-text="Frenzy 1.0 Launches - The Dropbox powered social network for Mac #frenzyapp" data-count="horizontal" data-via="johnwinter">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>
                </div>

			</div>
		</div>
		
		<div class="divider-l"></div>
		
<?php include("footer.php") ?>