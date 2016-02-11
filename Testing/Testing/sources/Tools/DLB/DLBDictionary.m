//
//  DLBDictionary.m
//  Outcast
//
//  Created by Crt Gregoric on 7. 09. 15.
//  Copyright (c) 2015 D·Labs. All rights reserved.
//

#import "DLBDictionary.h"

@interface DLBDictionary()

@property (nonatomic, strong) NSMutableDictionary *internalDictionary;

@end

@implementation DLBDictionary

#pragma mark - Initialization

- (instancetype)initWithMode:(DLBDictionaryMode)mode
{
    self = [super init];
    
    if (self)
    {
        self.mode = mode;
    }
    
    return self;
}

- (instancetype)initWithMode:(DLBDictionaryMode)mode dictionary:(NSDictionary *)dictionary
{
    self = [self initWithMode:mode];
    
    if (self)
    {
        dictionary = [self resampleDictionary:dictionary];
        self.internalDictionary = [dictionary mutableCopy];
    }
    
    return self;
}

#pragma mark - Overridden methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> %@", [[self class] description], self, self.internalDictionary.description];
}

#pragma mark - Setters and getters

- (NSMutableDictionary *)internalDictionary
{
    if (_internalDictionary == nil)
    {
        _internalDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return _internalDictionary;
}

- (NSDictionary *)dictionary
{
    return [self.internalDictionary copy];
}

#pragma mark - Public methods

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    if (key == nil)
    {
        return;
    }
    
    object = [self resampleObjectIfNeeded:object];

    if (self.mode == DLBDictionaryNoNSNull && [object isKindOfClass:[NSNull class]])
    {
        [self.internalDictionary removeObjectForKey:key];
        return;
    }
    else if (self.mode == DLBDictionaryForceNSNull && object == nil)
    {
        self.internalDictionary[key] = [NSNull null];
        return;
    }
    
    if (object)
    {
        self.internalDictionary[key] = object;
    }
    else
    {
        [self.internalDictionary removeObjectForKey:key];
    }
}

- (id)objectForKey:(id<NSCopying>)key
{
    if (key == nil)
    {
        return nil;
    }

    if (self.mode == DLBDictionaryNoNSNull)
    {
        id value = [self.internalDictionary objectForKey:key];
        
        if ([value isKindOfClass:[NSNull class]])
        {
            return nil;
        }
        else
        {
            return value;
        }
    }
    
    return [self.internalDictionary objectForKey:key];
}

#pragma mark - Subscript methods

- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key
{
    [self setObject:object forKey:key];
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    return [self objectForKey:key];
}

#pragma mark - Data resampling

- (id)resampleObjectIfNeeded:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        return [self resampleDictionary:((NSDictionary *)object)];
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return [self resampleArray:((NSArray *)object)];
    }
    
    return object;
}

- (NSDictionary *)resampleDictionary:(NSDictionary *)item
{
    NSMutableDictionary *toReturn = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in item.allKeys)
    {
        id component = item[key];
    
        if (component == [NSNull null] && self.mode == DLBDictionaryNoNSNull)
        {
            // Do not add
            continue;
        }
        else if (component == nil && self.mode == DLBDictionaryForceNSNull)
        {
            // Convert to NSNull
            component = [NSNull null];
        }
        else if ([component isKindOfClass:[NSDictionary class]])
        {
            component = [self resampleDictionary:component];
        }
        else if ([component isKindOfClass:[NSArray class]])
        {
            component = [self resampleArray:component];
        }
        else if (component == nil)
        {
            continue;
        }
        
        toReturn[key] = component;
    }
    
    return toReturn;
}

- (NSArray *)resampleArray:(NSArray *)array
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];

    for (id object in array)
    {
        id newItem = object;
        
        if (newItem == [NSNull null] && self.mode == DLBDictionaryNoNSNull)
        {
            // Do not add
            continue;
        }
        else if (newItem == nil && self.mode == DLBDictionaryForceNSNull)
        {
            // Convert to NSNull
            newItem = [NSNull null];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            newItem = [self resampleArray:object];
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            newItem = [self resampleDictionary:object];
        }
        
        [toReturn addObject:newItem];
    }
    
    return toReturn;
}

@end
