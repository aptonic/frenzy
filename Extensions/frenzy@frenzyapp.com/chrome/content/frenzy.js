// This extension writes the URLs/titles for all open Firefox windows to ~/Library/Application Support/Firefox/.current-urls
// as there is no way to grab the browser URL using AppleScript thanks to Firefoxes stupid b0rkenness.
// Bug filed here https://bugzilla.mozilla.org/show_bug.cgi?id=516502

var Frenzy = new Object();

var savefile = ".current-urls";

const DIR_SERVICE = new Components.Constructor("@mozilla.org/file/directory_service;1","nsIProperties");
home_path = (new DIR_SERVICE()).get("Home", Components.interfaces.nsIFile).path; 

if (home_path.search(/\\/) != -1) {
	home_path = home_path + "\\";
} else {
	home_path = home_path + "/";
}
frenzy_save_file = home_path + "Library/Application Support/Firefox/" + savefile;

window.addEventListener(
  "load",
  function () {	
	if(gBrowser) {
		gBrowser.addEventListener("DOMTitleChanged", Frenzy.UpdateURLFile, false);
		gBrowser.tabContainer.addEventListener("TabSelect", Frenzy.UpdateURLFile, false);
		gBrowser.tabContainer.addEventListener("TabClose", Frenzy.UpdateURLFile, false);
	}
	myExtension.init()
  },
  false
);
window.addEventListener(
  "unload",
  function () {	
	if(gBrowser) {
		gBrowser.removeEventListener("DOMTitleChanged", Frenzy.UpdateURLFile, false);
		gBrowser.tabContainer.removeEventListener("TabClose", Frenzy.UpdateURLFile, false);
		gBrowser.tabContainer.removeEventListener("TabSelect", Frenzy.UpdateURLFile, false);
	}
	myExtension.uninit()
  },
  false
);

var myExt_urlBarListener = {
  QueryInterface: function(aIID)
  {
   if (aIID.equals(Components.interfaces.nsIWebProgressListener) ||
       aIID.equals(Components.interfaces.nsISupportsWeakReference) ||
       aIID.equals(Components.interfaces.nsISupports))
     return this;
   throw Components.results.NS_NOINTERFACE;
  },

  onLocationChange: function(aProgress, aRequest, aURI)
  {
    myExtension.processNewURL(aProgress, aURI);
  },

  onStateChange: function(a, b, c, d) {},
  onProgressChange: function(a, b, c, d, e, f) {},
  onStatusChange: function(a, b, c, d) {},
  onSecurityChange: function(a, b, c) {}
};

var myExtension = {
  oldURL: null,
  
  init: function() {
    // Listen for webpage loads
    gBrowser.addProgressListener(myExt_urlBarListener,
        Components.interfaces.nsIWebProgress.NOTIFY_LOCATION);
  },
  
  uninit: function() {
    gBrowser.removeProgressListener(myExt_urlBarListener);
  },

  processNewURL: function(aProgress, aURI) {
    if (aURI.spec == null || aURI.spec == this.oldURL)
    	return;
		if (aURI.spec != null && aProgress.DOMWindow.document.title != null) {
			var consoleService = Components.classes["@mozilla.org/consoleservice;1"]
		                                 .getService(Components.interfaces.nsIConsoleService);
			Frenzy.UpdateURLFile(true);
		}

    this.oldURL = aURI.spec;
  }
};

Frenzy.UpdateURLFile = function(e) {
	var output = "";
	var wm = Components.classes["@mozilla.org/appshell/window-mediator;1"]
	                   .getService(Components.interfaces.nsIWindowMediator);
	var enumerator = wm.getEnumerator("navigator:browser");
	if (enumerator != null) {
		while(enumerator.hasMoreElements()) {
			var win = enumerator.getNext();
			output = output + win.document.title + "\n" + win.gBrowser.currentURI.spec + "\n\n";
		}
	}
	Frenzy.writeFile(output);
}

Frenzy.writeFile = function(url) {
	// Write out current url to file
	var file = Components.classes["@mozilla.org/file/local;1"]
		.createInstance(Components.interfaces.nsILocalFile);
	file.initWithPath(frenzy_save_file);
	if (file.exists() == false) {
		file.create(Components.interfaces.nsIFile.NORMAL_FILE_TYPE, 420);
	}
	var outputStream = Components.classes["@mozilla.org/network/file-output-stream;1"]
		.createInstance(Components.interfaces.nsIFileOutputStream);
	outputStream.init(file, 0x04 | 0x08 | 0x20, 420, 0);
	var converter = Components.classes["@mozilla.org/intl/converter-output-stream;1"].  
	                           createInstance(Components.interfaces.nsIConverterOutputStream);  
	converter.init(outputStream, "UTF-8", 0, 0);  
	converter.writeString(url);
	converter.close();
}