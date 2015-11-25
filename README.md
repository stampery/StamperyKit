# StamperyKit

[![CI Status](http://img.shields.io/travis/stampery/StamperyKit.svg?style=flat)](https://travis-ci.org/stampery/StamperyKit)
[![Version](https://img.shields.io/cocoapods/v/StamperyKit.svg?style=flat)](http://cocoapods.org/pods/StamperyKit)
[![License](https://img.shields.io/cocoapods/l/StamperyKit.svg?style=flat)](http://cocoapods.org/pods/StamperyKit)
[![Platform](https://img.shields.io/cocoapods/p/StamperyKit.svg?style=flat)](http://cocoapods.org/pods/StamperyKit)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## TODO

- Tests. Tests. Tests!!
- Caching
- Persistence


## Installation

StamperyKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "StamperyKit"
```

## Usage

First, import the library:
	
	#import <StamperyKit/StamperyKit.h>

Then, calling to the `+sharedInstance` method will initialize the library.

### Examples

**Login**

```objc
NSString *emailString = @"test@email.com"
NSString *passwordString = @"some-p@ssw0rd"
	
[[StamperyKit sharedInstance] loginWithEmail:emailString andPassword:passwordString completion:^(id response) {
	// Response contains the HTTP body
	// Once logged in, [[StamperyKit sharedInstance] userProfile] will contain the user profile
} errorBlock:^(NSError *error) {
	// error contains a NSError instance with the given error
}];
```

**Sign up**

```objc
NSString *emailString = @"test@email.com";
NSString *passwordString = @"some-p@ssw0rd";
NSString *nameString = @"John Doe";
	
[[StamperyKit sharedInstance] registerWithEmail:emailString password:passwordString name:nameString completion:^(id response) {
	// Response contains the HTTP body
	// Once logged in, [[StamperyKit sharedInstance] userProfile] will contain the user profile
} errorBlock:^(NSError *error) {
	// error contains a NSError instance with the given error
}];
```

**List stamps [needs login]**

```objc
[[StamperyKit sharedInstance] listStampsWithCompletion:^(id response) {
	// Response will contain a NSArray containing 'Stamp' elements
} errorBlock:^(NSError * error) {
	// error contains a NSError instance with the given error
}];
```

**Get stamp details**

```objc
NSString *stampHash = @"xxx-xxx-xxx";

[[StamperyKit sharedInstance] detailsForStampHash:stampHash completion:^(id response) {
	// response has an nsa
} errorBlock:^(NSError *error) {

}];
```
## Author

Pablo Merino, pablo@stampery.co

## License

StamperyKit is available under the MIT license. See the LICENSE file for more info.
