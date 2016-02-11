//
//  User.m
//  Testing
//
//  Created by Zan on 2/11/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDescriptor:(NSDictionary *)descriptor
{
    if((self = [super init]))
    {
        self.profileName = descriptor[@"name"];
        self.imageURL = descriptor[@"profileImageUrl"];
        self.location = descriptor[@"country"];
        self.numberOfCasts = [descriptor[@"cast_count"] integerValue];
        self.numberOfChannels = [descriptor[@"joined_channel_count"] integerValue];
        
    }
    return self;
}
@end
