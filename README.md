# BradColorPicker

[![Version](https://img.shields.io/cocoapods/v/BradColorPicker.svg?style=flat)](http://cocoapods.org/pods/BradColorPicker)
[![License](https://img.shields.io/cocoapods/l/BradColorPicker.svg?style=flat)](http://cocoapods.org/pods/BradColorPicker)
[![Platform](https://img.shields.io/cocoapods/p/BradColorPicker.svg?style=flat)](http://cocoapods.org/pods/BradColorPicker)

## Screenshots

![](https://raw.githubusercontent.com/bradkratky/BradColorPicker/master/Example/screenshot.png)

## Installation

BradColorPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BradColorPicker"
```

##Usage

Present the BradColorPicker view controller and set it's delegate.  The initial color can also be set:
```swift
let picker:BradColorPicker = BradColorPicker(delegate: self); // init with white
//let picker:BradColorPicker = BradColorPicker(delegate: self, r:0.5, g:0, b:0.5, a:1);
//let picker:BradColorPicker = BradColorPicker(delegate: self, color: UIColor.greenColor());
self.presentViewController(picker, animated: true, completion: {});
```

Implement the delegate, BradColorPickerDelegate:
```swift
// MARK: BradColorPickerDelegate
func bradColorPicked(color: UIColor) {
    // use color
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Brad Kratky, brad@bradkratky.ca

## License

BradColorPicker is available under the MIT license. See the LICENSE file for more info.
