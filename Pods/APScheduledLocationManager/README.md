# APScheduledLocationManager
 [![license MIT](https://img.shields.io/cocoapods/l/JSQCoreDataKit.svg)][mitLink]
 
Location manager that allows to get background location updates every *n* seconds with desired location accuracy.
 
*n* - range is between 2 - 170 seconds (limited by max allowed background task time)

## Requirements
* Xcode 8
* Swift 3.0
* iOS 9.0+

## Installation

##### [CocoaPods](http://cocoapods.org). Please use the latest CocoaPods as this framework is using Swift 3  

````ruby
use_frameworks!

pod 'APScheduledLocationManager'

````
 
## Usage 
##### 1. Configure Xcode project

In target ````Capabilities```` enable ````Background Modes```` and check ````Location updates````

In ````Info.plist```` add ````NSLocationAlwaysUsageDescription```` key and value that will specify the reason for your app to access the user’s location information at all times.

##### 2. Create instance of `APScheduledLocationManager`

````swift
let manager = APScheduledLocationManager(delegate: self)
````
##### 3. Confirm to ````APScheduledLocationManagerDelegate```` 

````swift
func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error){

}

func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation]) {

}

func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

}
````
##### 4. Request authorized always permission

You can use ````requestAlwaysAuthorization```` helper method of ````APScheduledLocationManager```` or your own implementation. 



##### 4. Start location manager when permission is granted

````swift
manager.startUpdatingLocation(interval: 170, acceptableLocationAccuracy: 100)
````
There are 2 options to adjust the location manager: 

- ````interval: TimeInterval```` - interval with which the location will be gathered. The range is between 2 - 170 seconds, lower or higher values will be overwritten
- ````acceptableLocationAccuracy: CLLocationAccuracy```` - the location manager will wait till locations with desired accuracy are retrieved. 


##### 5. To stop location manager call ````stopLocationManager````

## Example 

See an example app ````ScheduledLocationExample```` in the repository 

## License

`APScheduledLocationManager` is released under an [MIT License][mitLink]. See `LICENSE` for details.

[mitLink]:http://opensource.org/licenses/MIT