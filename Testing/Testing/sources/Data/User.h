//
//  User.h
//  Testing
//
//  Created by Zan on 2/11/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *location;
@property (nonatomic) NSInteger numberOfCasts;
@property (nonatomic) NSInteger numberOfChannels;

- (instancetype)initWithDescriptor:(NSDictionary *)descriptor;

@end
