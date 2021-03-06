<br>
<p align="center">
  <img src ="https://cloud.githubusercontent.com/assets/3276768/9226002/c10b71a6-410c-11e5-8672-a431f017dfe6.png"/>
</p>
</br>
![license MIT](http://img.shields.io/badge/license-MIT-orange.png) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

LocationKit is a wrapper of CoreLocation.
The point is to ease the API, and use of CoreLocation.
Written in swift.

**In development don't use it right now**

## Requirements

* iOS 8
* Swift 1.2

## Installation

#### [CocoaPods](http://cocoapods.org)

comming soon, if you ask for it.

#### [Carthage](https://github.com/Carthage/Carthage)

````bash
github "remirobert/LocationKit"
````
then
```bash
carthage bootstrap
```

## Usage

- Distance:
```Swift
let distanceLocation = LocationKit.distanceFromLocation(location, toLocation: location2)
let distanceLocation = LocationKit.distanceFromCurrentLocationToLocation(location)
```

- Location:
```Swift
//If you need to get the location juste one time, call this method
LocationKit.updateLocationOnce { (location, error) -> Void in
  if let location = location {
    self.currentLocation = location
  }
}

//Start tracking location :
//start update location and get notified, when it's updated
LocationKit.startUpdatingLocation { (location, error) -> Void in
  if let location = location {
    self.newLocation = location
  }
}

```


## Contributors

* [Rémi ROBERT](https://github.com/remirobert), creator. ( ﾟヮﾟ)

## License

`LocationKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

>**Copyright &copy; 2015 Rémi ROBERT.**

*Please provide attribution, it is greatly appreciated.*

[mitLink]:http://opensource.org/licenses/MIT
