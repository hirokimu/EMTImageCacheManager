//
//  EMTImageCacheManager.swift
//
//  Created by Hironobu Kimura on 2015/05/01.
//  Copyright (c) 2015 emotionale. All rights reserved.
//

import WatchKit

public class EMTImageCacheManager: NSObject {

    typealias keyInformationDict = Dictionary<String, AnyObject>
    
    var keyInformations: [keyInformationDict]?
    
    public class var instance: EMTImageCacheManager {
        struct Singleton {
            static let instance = EMTImageCacheManager()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
    }
    
    public func prepareOrderedCacheInformations() {
        if (keyInformations != nil) {
            return
        }
        keyInformations = self.getOrderedKeyInformations()
    }
    
    private func getOrderedKeyInformations() -> [keyInformationDict] {
    
        let regularExpression = NSRegularExpression(pattern: "^cache([0-9.]+)_(.+)$", options: nil, error: nil)!
        
        var keyInfos = [keyInformationDict]()
        
        for (key, value) in WKInterfaceDevice.currentDevice().cachedImages {
            let keyString = key as! NSString
            let matches = regularExpression.matchesInString(keyString as String, options: nil, range: NSMakeRange(0, keyString.length))
            if (matches.count != 0) {
                let result = matches[0] as! NSTextCheckingResult
                let dateString = keyString.substringWithRange(result.rangeAtIndex(1)) as NSString
                let name = keyString.substringWithRange(result.rangeAtIndex(2))
                let dict = [ "date":NSDate(timeIntervalSince1970:dateString.doubleValue), "key":key, "name":name ]
                keyInfos.append(dict)
            }
        }

        let sortedKeyInfos = sorted(keyInfos) {
            (dict1 : keyInformationDict, dict2: keyInformationDict) in
            
            let date1 = dict1["date"] as! NSDate
            let date2 = dict2["date"] as! NSDate
            let result = date1.compare(date2)
            return (result == NSComparisonResult.OrderedDescending)
        }

        return sortedKeyInfos
    }
    
    public func addOrderedCachedImageWithData(data: NSData, name: String) -> String? {
    
        if (data.length == 0 || name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
            return nil
        }
    
        self.prepareOrderedCacheInformations()
        self.removeOrderedCachedImageForName(name)
        
        if let key = self.saveOrderedCachedImageWithData(data, name:name) {
            return key
        }
        
        var dataSize = data.length
        
        var indexes = NSMutableIndexSet()
        
        for (index, element) in enumerate(keyInformations!) {
            let dict = element as keyInformationDict

            let imageKeyToRemove = dict["key"] as! String
            if let num = WKInterfaceDevice.currentDevice().cachedImages[imageKeyToRemove] as? NSNumber {
                dataSize -= num.integerValue
                WKInterfaceDevice.currentDevice().removeCachedImageWithName(imageKeyToRemove)
                indexes.addIndex(index)
                if (dataSize <= 0) {
                    break
                }
            }
            else {
                continue
            }
            
        }
        if (indexes.count != 0) {
            keyInformations!.removeAtIndexes(indexes)
        }
        
        return self.saveOrderedCachedImageWithData(data, name:name)
    }
    
    private func saveOrderedCachedImageWithData(data: NSData, name: String) -> String? {
        let date = NSDate()
        let key = NSString(format: "cache%f_%@", date.timeIntervalSince1970, name as NSString) as String
        if (WKInterfaceDevice.currentDevice().addCachedImageWithData(data, name:key)) {
            let dict = [ "date":date, "key":key, "name":name ] as keyInformationDict
            keyInformations!.append(dict)
            return key
        }
        return nil
    }

    public func getOrderedCacheKeyForName(name: String) -> String? {
        self.prepareOrderedCacheInformations()
        let index = self.indexOfOrderdKeyForName(name)
        if (index != -1) {
            return keyInformations![index]["key"] as? String
        }
        return nil
    }
    
    public func removeOrderedCachedImageForName(name: String) {
        self.prepareOrderedCacheInformations()
        let removeIndex = self.indexOfOrderdKeyForName(name)
        if (removeIndex != -1) {
            let key = keyInformations![removeIndex]["key"] as! String
            WKInterfaceDevice.currentDevice().removeCachedImageWithName(key)
            keyInformations!.removeAtIndex(removeIndex)
        }
    }
    
    public func removeAllOrderedCachedImage() {
        self.prepareOrderedCacheInformations()
        for (index, element) in enumerate(keyInformations!) {
            let dict = element as keyInformationDict
            let imageKeyToRemove = dict["key"] as! String
            WKInterfaceDevice.currentDevice().removeCachedImageWithName(imageKeyToRemove)
        }
        keyInformations!.removeAll(keepCapacity: false)
    }
    
    private func indexOfOrderdKeyForName(name: String) -> Int {
        for (index, element) in enumerate(keyInformations!) {
            let dict = element as keyInformationDict
            if (dict["name"] as! String == name) {
                return index
            }
        }
        return -1
    }
    
}

extension Array {
    mutating func removeAtIndexes(indexes: NSIndexSet) {
        for var i = indexes.lastIndex; i != NSNotFound; i = indexes.indexLessThanIndex(i) {
            self.removeAtIndex(i)
        }
    }
}


