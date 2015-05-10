#EMTImageCacheManager
An image cache manager for WKInterfaceDevice of Apple WatchKit

##How it works
If you add a data to the cache via EMTImageCacheManager, the cache is automatically named its name as below.
```swift
cache<current date>_<image name>
```
Then, if WKInterfaceDevice's cachedImages is already full, EMTImageCacheManager removes cache files as much as necessary in ascending order by added date.


## Installation

Simply add EMTImageCacheManager.swift to your project, or use CocoaPods.

### Podfile

```ruby
platform :ios, "8.2"
use_frameworks!
target :'fotogramme WatchKit Extension', :exclusive => true do
    pod 'EMTImageCacheManager', '~> 1.0.0'
end
```

## Usage

### Initialization

EMTImageCacheManager is a singleton class. Get instance via the instance property.

All data named by EMTImageCacheManager will be extracted from caches automatically when you try to add/get/remove a cache via the class at first.
If you want to do that process in your timing, use a following method.

```swift
EMTImageCacheManager.instance.prepareOrderedCacheInformations();
```

### Add a image data to cache

```swift
if let imageName = EMTImageCacheManager.instance.addOrderedCachedImageWithData(data, name: "image01") {
    //Cache succeeded. You can handle a image with the returned imageName.
    self.thumbImage.setImageNamed(imageName)
}
else {
    //Cache is full with non-EMTImageCacheManager images.
    self.thumbImage.setImageData(data)
}
```

### Retrieve the imageName of cached image data

```swift
if let imageName = EMTImageCacheManager.instance.getOrderedCacheKeyForName("image01") {
    //Cache found
    self.thumbImage.setImageNamed(imageName)
}
```

### Remove cached images

```swift
//Remove a single file added via EMTImageCacheManager
EMTImageCacheManager.instance.removeOrderedCachedImageForName("image01")

//Remove all files added via EMTImageCacheManager
EMTImageCacheManager.instance.removeAllOrderedCachedImage()
```

## Requirements
- iOS 8.2+

## License
EMTImageCacheManager is available under the MIT license. See the LICENSE file for more info.
