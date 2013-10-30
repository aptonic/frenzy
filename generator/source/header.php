<?php include("version.php") ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta content="Frenzy is a Dropbox powered social network for the Mac that allows you to share links, files and messages with your friends." name="description">
	<title>Frenzy - The Dropbox powered social network</title>
	<?php
	error_reporting(E_ERROR | E_WARNING | E_PARSE);
	
	if ($_SERVER["SERVER_NAME"] == "127.0.0.1") {
		$path_prefix = "http://127.0.0.1/~john/frenzy/generator/source/";
	} else {
		$path_prefix = "/";
	}
	
	?>
	<link rel="stylesheet" href="<?=$path_prefix?>css/master.css" type="text/css" charset="utf-8">
	<link rel="stylesheet" href="<?=$path_prefix?>fancybox/jquery.fancybox-1.3.4.css" type="text/css" media="screen" />
	<script src="http://cdn.jquerytools.org/1.2.5/full/jquery.tools.min.js"></script>
	<script type="text/javascript" src="<?=$path_prefix?>fancybox/jquery.fancybox-1.3.4.pack.js"></script>
	<script type="text/javascript" src="<?=$path_prefix?>fancybox/jquery.easing-1.3.pack.js"></script>
	<?php if ($page == "Home"): ?>
	<script type="text/javascript">
	function initScroller() {
		$("#scroller").scrollable({circular: true}).navigator().autoscroll({
			interval: 10000,
			keyboard: 'static'		
		});
		
		$("#scroller").click(function() {
			$("#scroller").scrollable().next();
		});	
		
		setTimeout(function(){ $("#scroller").scrollable().seekTo(0,0); }, 0);

	}
	$(document).ready(function() {
		$("a#video").fancybox({ 
		   'hideOnContentClick': false, 
		   'zoomSpeedIn':  100, 
		   'zoomSpeedOut': 50, 
		   'frameWidth': 768, 
		   'frameHeight': 576, 
		   'overlayShow': true, 
		   'overlayOpacity': 0.75, 
		   'transitionIn'	:	'fade',
		   'transitionOut'	:	'fade',
		   'speedIn'		:	600, 
		   'speedOut'		:	200,
		   'callbackOnClose': function() { $("#fancy_content").empty();} 
		}); 
		
		if (navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i)) {
			$("a#video").attr("href", "quick-iphone.txt");
		} else {
			$("a#video").attr("href", "quick.txt");
		}
	});
	
	
	$(function() {
	    $("img.watch")
	        .mouseover(function() { 
	            var src = $(this).attr("src").match(/[^\.]+/) + "-h.jpg";
	            $(this).attr("src", src);
	        })
	        .mouseout(function() {
	            var src = $(this).attr("src").replace("-h", "");
	            $(this).attr("src", src);
	        });
	});
	
	</script>
	<?php endif; ?>
</head>

		
<?php 

$basename = basename($_SERVER['REQUEST_URI'], "");

if (strlen($basename) >= 5) {
 	if (substr($basename, 0, 4) == "step") {
		// Getting started guide steps
		$step_num = $basename[4];
		$original_step_num = $step_num;

		if ($_GET['from_invite']) {
			$append_has_invite = "?from_invite=1";
			$step_num = $step_num - 2;
		} else {
			$append_has_invite = "";
		}
	}
}

?>

<body<?=($page == "Home" ? " onload=\"initScroller()\"" : "") ?>>
	<a href="https://github.com/aptonic/frenzy"><img style="position: absolute; top: 0; left: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_left_darkblue_121621.png" alt="Fork me on GitHub"></a>
	<div id="wrapper">
		<?php include("topnav.php") ?>