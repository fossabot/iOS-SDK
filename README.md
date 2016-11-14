# Pixpie iOS SDK

[![CI Status](http://img.shields.io/travis/Dmitry Osipa/Pixpie-iOS.svg?style=flat)](https://travis-ci.org/Dmitry Osipa/Pixpie-iOS)
[![Version](https://img.shields.io/cocoapods/v/Pixpie-iOS.svg?style=flat)](http://cocoapods.org/pods/Pixpie-iOS)
[![License](https://img.shields.io/cocoapods/l/Pixpie-iOS.svg?style=flat)](http://cocoapods.org/pods/Pixpie-iOS)
[![Platform](https://img.shields.io/cocoapods/p/Pixpie-iOS.svg?style=flat)](http://cocoapods.org/pods/Pixpie-iOS)

## What is it for? ##

Pixpie is a Platform as a Service for image optimization and manipulation.

iOS SDK provides API methods implementation to access Pixpie REST API with additional features: 
- automatic image adaptation for image view components based on current device parameters
- measuring of network quality
- usage of built-in cache

## Usage ##

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8+

## How to start? ##

Check [Getting started](https://pixpie.atlassian.net/wiki/display/DOC/Getting+started) guide and [register](https://cloud.pixpie.co/registration) your account

## Installation

Pixpie is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Pixpie"
```

### Authentication ###

After [creation of new application](https://pixpie.atlassian.net/wiki/display/DOC/Create+application),
use Secret key ("YOUR_APPLICATION_SECRET_KEY") in auth method.

Use created in Pixpie cloud application Bundle ID (reverse url id) that matches application Bundle ID in Xcode.

##### Obj-C, AppDelegate.m #####

```objective-c

  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
  {
  …
    [[PXP sharedSDK] authWithApiKey:@"YOUR_APPLICATION_SECRET_KEY"]
  ...
  }

```

##### Swift, AppDelegate.swift #####

```objective-c

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
  ...
    PXP.sharedSDK.auth("YOUR_APPLICATION_SECRET_KEY")
  …
  }

```

### SDK status ###

If authentication or connection status is changed, PXP instance sends notification PXPStateChangeNotification.
PXP instance has property status (KVO), that can have a few values: NotInitialized, Ready, Failed.

### Get remote (third party) and local (uploaded) images ###

### Integration with UIImageView

UIImageView + PXPExtensions category

```objective-c

  - (void)pxp_requestImage:(NSString*)url;
  
```
Method processes in 2 modes:
- if passed url is a valid HTTP(s) link, it requests the image by URL, that is located on remote (third party) server
- if passed url is not absolute URL to remote server, method will try to get image at Pixpie cloud by relative path

```objective-c

  - (void)pxp_requestImage:(NSString*)url headers:(NSDictionary * _Nullable )headers completion:(PXPImageRequestCompletionBlock _Nullable)completion;

```

Method is able to work with:
- additional request headers (the priority of passed headers is higher than of standart)
- callback that fires when loading process finish

```objective-c

  - (void)pxp_cancelLoad;

```

pxp_cancelLoad method is used to cancel image loading process.


## License

Pixpie iOS SDK is available under the Apache 2.0 license.

    Copyright (C) 2015,2016 Pixpie

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
