//
//  DLBDictionary.h
//  Outcast
//
//  Created by Crt Gregoric on 7. 09. 15.
//  Copyright (c) 2015 D·Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DLBDictionaryMode)
{
    // Default handling, no checking for NSNull, when setting a nil object the key is removed
    DLBDictionaryDefault,
    
    // [NSNull null] is not allowed, nil is used instead
    DLBDictionaryNoNSNull,
    
    // All nil values are converted to [NSNull null]
    DLBDictionaryForceNSNull
};

@interface DLBDictionary : NSObject

// Mode by which this class operates
@property (nonatomic) DLBDictionaryMode mode;
// Immutable and readonly version of dictionary used internally
@property (nonatomic, readonly) NSDictionary *dictionary;

// Initialization methods
- (instancetype)initWithMode:(DLBDictionaryMode)mode;
// Provided dictionary is recursively processed according to provided mode rules
- (instancetype)initWithMode:(DLBDictionaryMode)mode dictionary:(NSDictionary *)dictionary;

// Methods for setting and getting objects, objects are recursively processed according to the current mode rule
- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (id)objectForKey:(id<NSCopying>)key;

// Methods that enable subscripting (overloading []), setObject:forKey: and objectForKey: are called internally
- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
