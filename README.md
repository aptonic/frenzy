# Frenzy

A Dropbox powered social networking tool for the Mac.

See the [project website](http://aptonic.github.io/frenzy) for a demo and more info.
You can get a compiled version of the app from there also.

Developed by [John Winter](http://www.aptonic.com) (john@aptonic.com)

## Backstory


I originally did this project as a Mac app that I was intending to sell but unfortunately it didn't take off the way I'd hoped. When Apple rejected it from the Mac App Store for depending on  Dropbox that was the final nail in the coffin and I had to abandon it and move onto other projects. I'm now open sourcing it and making it free - mostly because I'm still using it and don't want it to die. Others have emailed me and asked if I would consider open sourcing it. So here we are. 

This code was mostly written in 2010. Both Cocoa and my skills have evolved greatly since then.
There's a whole lot in here that should really be rewritten, but I'm putting it up here in the hopes that you can help with that rather than see it die altogether.

I've done some testing on 10.9 and 10.8 and fixed the most pressing bugs and also made it (mostly) support retina displays.

## Building

It builds fine under Mavericks and Xcode 5. With no warnings amazingly.	

## Contributing

File github issues or send pull requests, it's all good. Here are a few ideas:

* Conversion to ARC and Obj-C properties without introducing a whole bunch of memory leaks and crashes (I suspect the latter will be the tricky part)
* Conversion to modern Obj-C syntax (literals, subscripting, blocks, ponies)
* Growl support
* Replace outdated UKKQueue with shiny [VDKQueue](https://github.com/bdkjones/vdkqueue) without breaking file monitoring
* Improved display of shared files in the feed i.e. if you share an image it shows a thumbnail rather than just linking straight to the file
* Finish Retinafying the interface images
* Improve the UI design
* Add a way to view old (archived) feed items
* Optional encryption of feed files
* iPhone version
* Windows version

## License

Released under the MIT License. Share and enjoy.