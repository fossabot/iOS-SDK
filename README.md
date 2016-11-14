# Pixpie iOS SDK

[![CI Status](http://img.shields.io/travis/PixpieCo/iOS-SDK.svg?style=flat)](https://travis-ci.org/Dmitry Osipa/Pixpie-iOS)
[![Version](https://img.shields.io/badge/pod-0.3.6-blue.svg)](http://cocoapods.org/pods/Pixpie-iOS)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](http://cocoapods.org/pods/Pixpie-iOS)

## What is it for?

Pixpie is a Platform as a Service for image optimization and manipulation.

iOS SDK provides API methods implementation to access Pixpie REST API with additional features: 
- automatic image adaptation for image view components based on current device parameters
- measuring of network quality
- usage of built-in cache

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8+
* Xcode 7+

## How to start?

Check [Getting started](https://pixpie.atlassian.net/wiki/display/DOC/Getting+started) guide and [register](https://cloud.pixpie.co/registration) your account

## Installation

Pixpie is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/PixpieCo/PixpieCocoapods.git'

pod "Pixpie"
```

## Architecture
##### Authentication
- `PXP`

##### Pixpie Cloud API
- `PXPAPIManager`
- `PXPAPITask`

##### Image Manipulation
- `PXPTransform`
- `PXPAutomaticTransform`

##### Image Downloading
- `PXPImageRequestWrapper`
- `PXPImageCache`

##### Monitoring
- `PXPTrafficMonitor`

##### UIKit Extensions
- `UIImageView+PXPExtensions`

## Usage

#### Authentication

After [creation of new application](https://pixpie.atlassian.net/wiki/display/DOC/Create+application),
use Secret key ("YOUR_APPLICATION_SECRET_KEY") in auth method.

Use created in [Pixpie cloud](https://cloud.pixpie.co) application Bundle ID (`com.example.AppName`) that matches application's Bundle ID in Xcode.

##### Obj-C, AppDelegate.m

```objective-c
  @import Pixpie;

  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
  {
  ...
    [[PXP sharedSDK] authWithApiKey:@"YOUR_APPLICATION_SECRET_KEY"]
  ...
  }

```

##### Swift, AppDelegate.swift

```swift
  import Pixpie
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
  ...
    PXP.sharedSDK.auth("YOUR_APPLICATION_SECRET_KEY")
  ...
  }

```

#### SDK status

If authentication or connection status is changed, `PXP` instance sends notification `PXPStateChangeNotification`.
PXP instance has property status (KVO), that can have a few values: `NotInitialized`, `Ready`, `Failed`.

#### Get remote (third party) and local (uploaded) images at Pixpie Cloud

##### With UIImageView
Pixpie SDK provides UIImageView expension to easily download images.

##### Requesting Image
```objective-c

  - (void)pxp_requestImage:(NSString*)url;
  
```
Method processes in 2 modes:
- if `url` is a valid HTTP(s) link, it requests the image by URL, that is located on remote (third party) server
- if `url` is not absolute URL to remote server, method will try to get image at Pixpie cloud by relative path

##### UIImageView+PXPExtensions.h
```objective-c

  - (void)pxp_requestImage:(NSString*)url headers:(NSDictionary * _Nullable )headers completion:(PXPImageRequestCompletionBlock _Nullable)completion;

```

Method is able to work with:
- additional request headers (the priority of passed headers is higher than of standart)
- callback that fires when loading process finish

##### UIImageView+PXPExtensions.h
```objective-c

  - (void)pxp_cancelLoad;

```

`pxp_cancelLoad` method is used to cancel image loading process.

#### Image Download via PXPImageDownloader

`PXPImageDownloader` class is responsible for image uploading to mobile device.

```objective-c

  - (instancetype)init;

```

Creates Image Downloader with `NSURLSession` with `defaultConfiguration`.

```objective-c

  - (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)config;

```

Creates wrapper with custom `NSURLSession`.

```objective-c

  - (AFHTTPSessionOperation *)imageDownloadTaskForUrl:(NSString *)urlString
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                            success:(PXPImageSuccessBlock)successBlock
                                           failure:(PXPImageFailureBlock)failureBlock;

```

Returns subclass with `NSOperation` with `NSURLSessionDataTask` inside. It is automatically added to Pixpie image downloading queue. Recieves `urlString` to image as parameter.

```objective-c

  - (AFHTTPSessionOperation *)imageDownloadTaskForRequest:(NSURLRequest *)request
                                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                                success:(PXPImageSuccessBlock)successBlock
                                               failure:(PXPImageFailureBlock)failureBlock;

```

Returns subclass with `NSOperation` with `NSURLSessionDataTask` inside. It is automatically added to Pixpie image downloading queue. Recieves request as parameter.

#### Image transformation

`PXPTransform` class is responsible for image transformation and URL generation that are mapped to Pixpie cloud.
Can be intialized with

```objective-c

  - (instancetype)init;
  - (instancetype)initWithOriginUrl:(NSString*)originUrl;

```


```objective-c

  @property (nonatomic, strong) NSString* originUrl;

```

Link to original image.

```objective-c

  @property (nonatomic, strong) NSNumber* imageQuality;

```

Image quality. Can be `Automatic`, then the quality is taken according to network quality and `Default`(80% of original image quality).


```objective-c

  @property (nonatomic, assign) PXPTransformFormat imageFormat;
  
```

Image format:
- `PXPTransformFormatDefault` (default)
- `PXPTransformFormatWebP` (recommended)

```objective-c

  @property (nonatomic, strong, nullable) NSNumber* width;
  @property (nonatomic, strong, nullable) NSNumber* height;

```

Desirable width and height.

```objective-c

  - (NSString * _Nullable)contentUrl;
  
```

Method returns link to image. Can be `NULL` only if originUrl value is not set.

#### Automatic image transformation

`PXPAutomaticTransform` is the subclass of `PXPTransform`, it automatically set the `size(width, height)`, quality and format of image.

```objective-c

  - (instancetype)initWithImageView:(UIImageView* _Nullable)contextView originUrl:(NSString* _Nullable)url;
  
```

Can be initialized with `UIImageView`, where the image should be located (it's needed to automatically set the image format) and with the link to original image.

```objective-c

  @property (nonatomic, weak, nullable) UIImageView* contextView;

```

`UIImageView` where the image will be shown.

```objective-c

  @property (nonatomic, strong) NSNumber* imageQuality;
  @property (nonatomic, assign) PXPTransformFormat imageFormat;
  @property (nonatomic, strong, nullable) NSNumber* width;
  @property (nonatomic, strong, nullable) NSNumber* height;
  
```

If the parameter is `NULL`(not set), then the instance will automatically define appropriate image format, width, height and quality.


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
