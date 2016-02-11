//
//  OUTSessionManager.h
//
//  Created by Matic Oblak on 8/10/15.
//  Copyright (c) 2015 D·Labs. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface OUTSessionManager : AFHTTPSessionManager

@property (nonatomic, strong) NSURLCredential *credential;

@end
