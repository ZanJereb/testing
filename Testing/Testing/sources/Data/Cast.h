//
//  Cast.h
//  Testing
//
//  Created by Zan on 2/10/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cast : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *location;
@property (nonatomic, readonly) NSString *timeStamp;

+ (void)fetchAllCasts:(void (^)(NSArray *casts))callBack;
- (instancetype)initWithDescriptor:(NSDictionary *)descriptor;

@end
