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

+ (void)fetchAllCasts:(void (^)(NSArray *casts))callBack;

@end
