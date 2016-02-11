//
//  OUTAPIRequest.m
//  Outcast
//
//  Created by Matic Oblak on 7/6/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import "OUTAPIRequest.h"
#import "OUTSessionManager.h"

@interface OUTAPIRequest ()

@property (nonatomic, strong) OUTSessionManager *operationManager;

@property (nonatomic, copy) void (^callbackBlock)(id responseObject, NSError *error, NSNumber *statusCode);
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSNumber *statusCode;

@end

@implementation OUTAPIRequest

- (DLBDictionary *)parameters
{
    if (_parameters == nil)
    {
        _parameters = [[DLBDictionary alloc] init];
    }
    
    return _parameters;
}

#pragma mark - URL
/*! Path for endpoint
 */
+ (NSString *)pathStringForEndpoint:(eEndpointPath)enpoint
{
    switch (enpoint) {
        case EndpointPathRefreshToken:
            return @"refresh_token";
            break;
        case EndpointPathLogin:
            return @"login";
            break;
        case EndpointPathFacebookLogin:
            return @"fb_login";
            break;
        case EndpointPathSignup:
            return @"api/users";
            break;
        case EndpointPathCasts:
            return @"api/casts"; // v01_topCastsAllTime.json
            break;
        case EndpointPathTopCastsToday:
            return nil;//@"v01_topCastsToday.json";
            break;
        case EndpointPathTopCasters:
            return nil;//@"v01_topCasters.json";
            break;
        case EndpointPathChannelPing:
            return nil;//@"v01_channel.json";
            break;
        case EndpointPathLiveAudience:
            return nil;//@"v02_liveAudience.json";
            break;
        case EndpointPathMyChannels:
            return @"api/me/channels";
            break;
        case EndpointPathChannels:
            return @"api/channels";
            break;
        case EndpointPathMyCasts:
            return @"api/me/casts";
            break;
        case EndpointPathMe:
            return @"api/me";
            break;
        case EndpointPathMyDevices:
            return @"api/me/devices";
            break;
        case EndpointPathChangePassword:
            return @"api/me/password";
            break;
        case EndpointPathSendPassword:
            return @"api/users/password";
            break;
        
        case EndpointPathConfiguration:
            return @"api/config";
            break;
            
        default:
            return nil;
            break;
    }
}
/*! Base path for endpoint
 @discussion Server path
 */
+ (NSString *)baseURLForEndpoint:(eEndpointPath)endpoint
{
    return @"https://api2.outcaster.net";
}
/*! Full endpoint path
 */
+ (NSString *)urlStringForEndpoint:(eEndpointPath)endpoint
{
    NSString *path = [self pathStringForEndpoint:endpoint];
    if(path)
    {
        return [NSString stringWithFormat:@"%@/%@", [self baseURLForEndpoint:endpoint], [self pathStringForEndpoint:endpoint]];
    }
    else
    {
        return nil;
    }
}

- (BOOL)useQueryParameters
{
    if(self.parametersType == ParametersTypeQuery)
    {
        return NO;
    }
    else if(self.parametersType == ParametersTypeForm)
    {
        return YES;
    }
    else
    {
        return (self.callType == APICallGet) || (self.callType == APICallDelete) || (self.callType == APICallList);
    }
}
- (NSString *)urlString
{
    NSString *basePath = [OUTAPIRequest urlStringForEndpoint:self.endpoint];
    
    if(basePath == nil)
    {
        return nil;
    }
    
    if(self.endpointSuffix)
    {
        basePath = [basePath stringByAppendingString:self.endpointSuffix];
    }
    if([self useQueryParameters])
    {
        NSString *query = nil;
        for (NSString *key in self.parameters.dictionary)
        {
            NSString *value = [NSString stringWithFormat:@"%@=%@", key, self.parameters[key]];
            if(query == nil)
            {
                query = value;
            }
            else
            {
                query = [query stringByAppendingFormat:@"&%@", value];
            }
        }
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:basePath];
        if(query)
        {
            components.query = query;
        }
        return components.string;
    }
    else
    {
        return basePath;
    }
}
#pragma mark - Operation manager

+ (OUTSessionManager *)makeOperationManager
{
    OUTSessionManager *manager = [OUTSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    
    manager.credential = [NSURLCredential credentialWithUser:@"yTgLO5x40GDtwRgzlzUEIqOlhLBYPypP3aZ4opn4" password:@"Tg7F51cEbZN7fR7MLsVojFLD4tvq7lgfhGx7CDEN" persistence:NSURLCredentialPersistencePermanent];
    
    return manager;
}

#pragma mark - Initialization

+ (OUTAPIRequest *)newInstance
{
    OUTAPIRequest *toReturn = [[OUTAPIRequest alloc] init];
    toReturn.needsAccessToken = YES;
    toReturn.operationManager = [self makeOperationManager];
    
    return toReturn;
}
+ (OUTAPIRequest *)newInstanceWithEndpoint:(eEndpointPath)endpoint
{
    OUTAPIRequest *toReturn = [self newInstance];
    toReturn.endpoint = endpoint;
    return toReturn;
}
+ (OUTAPIRequest *)forEndpoint:(eEndpointPath)endpoint ofType:(APICall)call
{
    OUTAPIRequest *request = [self newInstanceWithEndpoint:endpoint];
    request.callType = call;
    
    if (call == APICallList)
    {
        request.parameters[@"limit"] = @(200);
    }
    
    return request;
}

+ (OUTAPIRequest *)loginInstanceWithUserName:(NSString *)name andPassword:(NSString *)password
{
    OUTAPIRequest *toReturn = [OUTAPIRequest forEndpoint:EndpointPathLogin ofType:APICallPost];
    toReturn.needsAccessToken = NO;
    
    toReturn.parameters[@"username"] = name;
    toReturn.parameters[@"password"] = password;
    
    toReturn.operationManager = [self makeOperationManager];
    
    return toReturn;
}

+ (OUTAPIRequest *)loginInstanceWithFacebookIdentifier:(NSString *)identifier andToken:(NSString *)accessToken
{
    OUTAPIRequest *toReturn = [OUTAPIRequest forEndpoint:EndpointPathFacebookLogin ofType:APICallPost];
    toReturn.needsAccessToken = NO;
    
    toReturn.parameters[@"facebook_id"] = identifier;
    toReturn.parameters[@"access_token"] = accessToken;
    
    toReturn.operationManager = [self makeOperationManager];
    
    return toReturn;
}


+ (OUTAPIRequest *)signUpInstanceWithUserName:(NSString *)name andPassword:(NSString *)password
{
    OUTAPIRequest *toReturn = [OUTAPIRequest forEndpoint:EndpointPathSignup ofType:APICallPost];
    toReturn.needsAccessToken = NO;
    
    toReturn.parameters[@"email"] = name;
    toReturn.parameters[@"username"] = name;
    toReturn.parameters[@"plainPassword"] = password;
    toReturn.parameters[@"profile"] = [self putDescriptor];
    
    toReturn.operationManager = [self makeOperationManager];
    
    return toReturn;
}

+ (NSDictionary *)putDescriptor
{
    DLBDictionary *toReturn = [[DLBDictionary alloc] initWithMode:DLBDictionaryDefault];
    toReturn[@"name"] = @"Test user";
    toReturn[@"country"] = @"Ljubljana";
    return toReturn.dictionary;
}

/*
 {"username":"username", "plainPassword":"password", "email":"team.outcast+username@dlabs.si", "profile":{"name":"Full Name", "country":"Country", "birthDate":"2015-07-20T05:42:28+0000", "profileImage":"avatar.jpeg"}}
 */
/*
 POST /api/users, payload: {"username":"deviced8", "password":"password", "email":"team.outcast+deviced8@dlabs.si", "profile":{"name":"Post Man", "country":"Postland", "birthDate":"2015-07-20T05:42:28+0000", "profileImage":"avatar.jpeg"}}
 */

#pragma mark - Requests

- (void)perform
{
    if([self urlString] == nil)
    {
        return;
    }
    
    if(self.needsAccessToken && self.token == nil)
    {
        [self.delegate APIRequestHasInvalidAccessToken:self];
    }
    else
    {
        switch (self.callType) {
            case APICallPost:
            {
                [self.operationManager POST:[self urlString] parameters:self.parameters.dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([task.response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        self.statusCode = @([((NSHTTPURLResponse *)task.response) statusCode]);
                    }
                    [self processCallback:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                    [self processCallback:task response:nil error:error];
                }];
                break;
            }
            case APICallGet:
            {
                [self.operationManager GET:[self urlString] parameters:self.parameters.dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([task.response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        self.statusCode = @([((NSHTTPURLResponse *)task.response) statusCode]);
                    }
                    [self processCallback:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self processCallback:task response:nil error:error];
                }];
                break;
            }
            case APICallPut:
            {
                [self.operationManager PUT:[self urlString] parameters:self.parameters.dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([task.response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        self.statusCode = @([((NSHTTPURLResponse *)task.response) statusCode]);
                    }
                    [self processCallback:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self processCallback:task response:nil error:error];
                }];
                break;
            }
            case APICallDelete:
            {
                [self.operationManager DELETE:[self urlString] parameters:self.parameters.dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([task.response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        self.statusCode = @([((NSHTTPURLResponse *)task.response) statusCode]);
                    }
                    [self processCallback:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self processCallback:task response:nil error:error];
                }];
                break;
            }
            case APICallList:
            {
                [self.operationManager GET:[self urlString] parameters:self.parameters.dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([task.response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        self.statusCode = @([((NSHTTPURLResponse *)task.response) statusCode]);
                    }
                    [self processCallback:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self processCallback:task response:nil error:error];
                }];
                break;
            }
        }
        
    }
}

- (void)performWithCallback:(void (^)(id responseObject, NSError *error, NSNumber *statusCode))callback
{
    self.callbackBlock = callback;
    [self perform];
}

- (void)processCallback:(NSURLSessionDataTask *)task response:(id)responseObject error:(NSError *)error
{
    if(error && error.code == 401)
    {
        [self.delegate APIRequestHasInvalidAccessToken:self];
    }
    if(self.callbackBlock)
    {
        if(responseObject)
        {
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                responseObject = [[DLBDictionary alloc] initWithMode:DLBDictionaryNoNSNull dictionary:responseObject].dictionary;
            }
            
            self.callbackBlock(responseObject, error, self.statusCode);
        }
        else
        {
            self.callbackBlock(nil, error, self.statusCode);
        }
    }
}

#pragma mark - Token 

- (void)insertToken:(NSString *)token
{
    self.token = token;
    NSString *tokenField = [NSString stringWithFormat:@"%@ %@", @"Bearer", token];
    [self.operationManager.requestSerializer setValue:tokenField forHTTPHeaderField:@"Authorization"];
}

#pragma mark - description

- (NSString *)description
{
    return [NSString stringWithFormat:@"Request %p\rURL: %@\r Type: %d\r Parameters: %@", self, [self urlString], (int)self.callType, self.parameters.dictionary];
}

@end
