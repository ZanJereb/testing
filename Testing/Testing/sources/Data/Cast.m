//
//  Cast.m
//  Testing
//
//  Created by Zan on 2/10/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "Cast.h"
#import "OUTAPIManager.h"
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
    [[OUTAPIManager sharedInstance] performRequest:[OUTAPIRequest forEndpoint:EndpointPathMyCasts ofType:APICallGet] withCallback:^(id responseObject, NSError *error, NSNumber *statusCode) {
        
        NSMutableArray *casts = [[NSMutableArray alloc] init];
        for(NSDictionary *item in responseObject[@"items"])
        {
            [casts addObject:[[Cast alloc] initWithDescriptor:item]];
        }
        
        callBack(casts);
    }];
}

- (instancetype)initWithDescriptor:(NSDictionary *)descriptor
{
    if((self = [super init]))
    {
        self.title = descriptor[@"title"];
        self.imageURL = descriptor[@"movieThumbnailURL"];
        self.location = descriptor[@"city"];
        self.dateCreated = [[self apiDateFormatter] dateFromString:descriptor[@"created"]];
    }
    return self;
}

- (NSDateFormatter *)apiDateFormatter
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ"; // created = "2016-01-12T13:58:33+0000";
    return formatter;
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

