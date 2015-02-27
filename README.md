# CoreMotion Demos

This project contains demos of some of the Core Motion APIs available in iOS 8 which I created for a talk at PDX CocoaHeads:

* Real-time Motion Activity (this was introduced in iOS 7, but the `bicycling` property is new)
* Real-time pedometer 
* Historical pedometer
* Altimeter
* CLFloor (which is CoreLocation, but I added it here so I can check for defined floors while I'm wandering the world)

Some features will work on an iPhone 5s, but running the app on an iPhone 6 or 6 Plus is the best option. It won't do much on a simulator.

## Additional Resources

[Slides for the related talk](https://github.com/mattblair/CoreMotionDemos/blob/master/CoreMotion-CocoaHeads150225.pdf)

[CoreMotion Framework Reference](https://developer.apple.com/library/prerelease/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/index.html)

WWDC 2014 Session 612: Motion Tracking with the CoreMotion Framework [(AsciiWWDC)](http://asciiwwdc.com/2014/sessions/612)

Sample code from that session: [MotionActivityDemo](https://developer.apple.com/wwdc/resources/sample-code/)

[NSHipster on CMDeviceMotion](http://nshipster.com/cmdevicemotion)

[CoreMotion examples in Swift](http://www.shinobicontrols.com/blog/posts/2014/10/21/ios8-day-by-day-day-35-coremotion)

[UIRequiredDeviceCapabilities](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW3)

[A deeper exploration of ways to access magnetometer data](http://stackoverflow.com/a/15470571)

## License

MIT