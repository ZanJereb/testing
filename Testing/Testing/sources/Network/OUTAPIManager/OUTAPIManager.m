//
//  OUTAPIManager.m
//  Outcast
//
//  Created by Matic Oblak on 3/14/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import "OUTAPIManager.h"
#import <AFNetworking.h>

static NSString *__refreshTokenKey = @"key_refresh_token_v2";


@interface OUTAPIManager()<OUTAPIRequestDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;

@property (nonatomic, strong) NSMutableArray *queuedRequests;

@property (nonatomic) BOOL refreshTokenLocked;

@end


@implementation OUTAPIManager

@synthesize refreshToken = _refreshToken;

#pragma mark - status

- (BOOL)isLoggedIn
{
    return self.refreshToken != nil;
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    _refreshToken = refreshToken;
}

#pragma mark - Queue

- (NSMutableArray *)queuedRequests
{
    if(_queuedRequests == nil)
    {
        _queuedRequests = [[NSMutableArray alloc] init];
    }
    return _queuedRequests;
}

- (void)releaseRequestQueue
{
    NSArray *pendingRequests = [self.queuedRequests copy];
    self.queuedRequests = nil;
    
    if(pendingRequests.count > 0)
    {
        [self showMessage:[NSString stringWithFormat:@"Flushing request queue (%d items)", (int)pendingRequests.count]];
        for(OUTAPIRequest *request in pendingRequests)
        {
            [self performRequest:request];
        }
    }
}

#pragma mark - Tokens

- (NSString *)refreshToken
{
    return _refreshToken;
}

/*! Saves the new refresh token
 @param token A token to be saved
 @discussion Will save the token into the keychain
 */
- (void)serializeRefreshToken:(NSString *)token
{
    [self showMessage:[NSString stringWithFormat:@"Serializing refresh token (%@)", token]];
    self.refreshToken = token;
}

#pragma mark - Requests

- (void)performRequest:(OUTAPIRequest *)request withCallback:(void (^)(id responseObject, NSError *error, NSNumber *statusCode))callback
{
    [request insertToken:self.accessToken];
    request.delegate = self;
    [self showMessage:[NSString stringWithFormat:@"Performing request with callback: %@", request.description]];
    [request performWithCallback:^(id responseObject, NSError *error, NSNumber *statusCode) {
        if(callback)
        {
            callback(responseObject, error, statusCode);
        }
    }];
}

- (void)performRequest:(OUTAPIRequest *)request
{
    [request insertToken:self.accessToken];
    request.delegate = self;
    [self showMessage:[NSString stringWithFormat:@"Performing request: %@", request.description]];
    [request perform];
}

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password callback:(void (^)(BOOL didLogin, NSError *error))callback
{
    [[OUTAPIRequest loginInstanceWithUserName:userName andPassword:password] performWithCallback:^(NSDictionary *responseObject, NSError *error, NSNumber *statusCode) {
        if(error == nil && [responseObject isKindOfClass:[NSDictionary class]])
        {
            NSString *refreshToken = responseObject[@"refresh_token"];
            self.refreshToken = refreshToken;
            NSString *accessToken = responseObject[@"token"];
            
            if(refreshToken)
            {
                [self serializeRefreshToken:refreshToken];
            }
            if(accessToken)
            {
                self.accessToken = accessToken;
            }
            if(callback)
            {
                callback(self.accessToken != nil, error);
            }
        }
        else if(callback)
        {
            callback(NO, error);
        }
    }];
}

- (void)loginWithFacebookID:(NSString *)FBIdentifier token:(NSString *)FBToken callback:(void (^)(BOOL didLogin, NSError *error))callback
{
    [[OUTAPIRequest loginInstanceWithFacebookIdentifier:FBIdentifier andToken:FBToken] performWithCallback:^(NSDictionary *responseObject, NSError *error, NSNumber *statusCode) {
        if(error == nil && [responseObject isKindOfClass:[NSDictionary class]])
        {
            NSString *refreshToken = responseObject[@"refresh_token"];
            self.refreshToken = refreshToken;
            NSString *accessToken = responseObject[@"token"];
            
            if(refreshToken)
            {
                [self serializeRefreshToken:refreshToken];
            }
            if(accessToken)
            {
                self.accessToken = accessToken;
            }
            if(callback)
            {
                callback(self.accessToken != nil, error);
            }
        }
        else if(callback)
        {
            callback(NO, error);
        }
    }];
}


- (void)signUpWithUserName:(NSString *)userName password:(NSString *)password user:(OUTUserModel *)user callback:(void (^)(BOOL didLogin, NSError *error, NSDictionary *response))callback
{
    [[OUTAPIRequest signUpInstanceWithUserName:userName andPassword:password] performWithCallback:^(NSDictionary *responseObject, NSError *error, NSNumber *statusCode) {
        if(error == nil && [responseObject isKindOfClass:[NSDictionary class]])
        {
            NSString *refreshToken = responseObject[@"refresh_token"];
            self.refreshToken = refreshToken;
            NSString *accessToken = responseObject[@"token"];
            
            if(refreshToken)
            {
                [self serializeRefreshToken:refreshToken];
            }
            if(accessToken)
            {
                self.accessToken = accessToken;
            }
            if(callback)
            {
                callback(self.accessToken != nil, error, responseObject);
            }
        }
        else if(callback)
        {
            callback(NO, error, nil);
        }
    }];
}

- (void)refreshToken:(void (^)(id responseObject, NSError *error))callback
{
    if(self.refreshTokenLocked == NO)
    {
        if(self.refreshToken)
        {
            self.refreshTokenLocked = YES;
            OUTAPIRequest *request = [OUTAPIRequest forEndpoint:EndpointPathRefreshToken ofType:APICallPost];
            request.needsAccessToken = NO;
            request.parameters[@"refresh_token"] = self.refreshToken;
            [self showMessage:@"Refreshing token..."];
            [request performWithCallback:^(NSDictionary *responseObject, NSError *error, NSNumber *statusCode) {
                if(error)
                {
                    // something went wrong. Notify to relog
                    [self showMessage:[NSString stringWithFormat:@"Failed refreshing token (%d)", (int)error.code]];
                    [self serializeRefreshToken:nil];
                    self.accessToken = nil;
                    if([self.delegate respondsToSelector:@selector(APIManagerShouldLogin)])
                    {
                        [self.delegate APIManagerShouldLogin];
                    }
                }
                else if([responseObject isKindOfClass:[NSDictionary class]])
                {
                    [self showMessage:@"Succeeded refreshing token"];
                    self.accessToken = responseObject[@"token"];
                }
                if(callback)
                {
                    callback(responseObject, error);
                }
                self.refreshTokenLocked = NO;
            }];
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(APIManagerShouldLogin)])
            {
                [self.delegate APIManagerShouldLogin];
            }
        }
    }
}

#pragma mark - Request delegate

- (void)APIRequestHasInvalidAccessToken:(OUTAPIRequest *)sender
{
    [self showMessage:[NSString stringWithFormat:@"Request reported invalid token: %@", sender.description]];
    [self.queuedRequests addObject:sender];
    [self refreshToken:^(id responseObject, NSError *error) {
        if(error == nil)
        {
            [self releaseRequestQueue];
        }
    }];
}

#pragma mark - Debug

- (void)showMessage:(NSString *)message
{
}

#pragma mark - log out

- (void)logOut
{
    self.refreshToken = nil;
    [self serializeRefreshToken:nil];
    self.accessToken = nil;
}

@end
