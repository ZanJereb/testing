//
//  Cast.m
//  Testing
//
//  Created by Zan on 2/10/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "Cast.h"

@interface Cast ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSDate *dateCreated;

@end

@implementation Cast

- (void)changeTitle
{
    self.title= [NSString stringWithFormat:@"ljubljana je lepa ker je lepa"];
}

+ (void)fetchAllCasts:(void (^)(NSArray *casts))callBack
{
    callBack([self getAllCasts]);
}

+ (NSArray *)getAllCasts
{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    for(int i=0;i<10;i++)
    {
        Cast *item = [[Cast alloc] init];
        [array addObject:item];
        [item changeTitle];
        item.location = @"ljubljana";
        
        
        
    }
    
    NSLog(@"Start");
    array = [[array sortedArrayUsingComparator:^NSComparisonResult(Cast *  _Nonnull obj1, Cast *  _Nonnull obj2) {
        NSLog(@"Point");
        return [obj1.dateCreated compare:obj2.dateCreated];
    }] mutableCopy];
    NSLog(@"Emd");
    
    return array;
}


@end

