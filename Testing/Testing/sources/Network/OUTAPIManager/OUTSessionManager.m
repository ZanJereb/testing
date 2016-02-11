//
//  OUTSessionManager.m
//  House of holland
//
//  Created by Matic Oblak on 8/10/15.
//  Copyright (c) 2015 D·Labs. All rights reserved.
//

#import "OUTSessionManager.h"

@implementation OUTSessionManager

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if (self.credential)
    {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.credential);
    }
    else
    {
        [super URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    }
}

@end
