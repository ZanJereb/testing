//
//  OUTAPIRequest.h
//  Outcast
//
//  Created by Matic Oblak on 7/6/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLBDictionary.h"

@class OUTAPIRequest;
@class OUTUserModel;

typedef enum : NSUInteger {
    EndpointPathRefreshToken,
    EndpointPathLogin,
    EndpointPathFacebookLogin,
    EndpointPathSignup,
    EndpointPathCasts,
    EndpointPathTopCasters,
    EndpointPathTopCastsToday,
    EndpointPathChannelPing,
    EndpointPathLiveAudience,
    EndpointPathMyChannels,
    EndpointPathChannels,
    EndpointPathMyCasts,
    EndpointPathMe,
    EndpointPathMyDevices,
    EndpointPathChangePassword,
    EndpointPathSendPassword,
    EndpointPathConfiguration
} eEndpointPath;

typedef enum : NSUInteger {
    APICallPost,
    APICallGet,
    APICallPut,
    APICallDelete,
    APICallList
} APICall;

typedef enum : NSUInteger {
    ParametersTypeAutomatic, // Use query for GET and DELETE, else is form
    ParametersTypeForm,
    ParametersTypeQuery
} ParametersType;

@protocol  OUTAPIRequestDelegate <NSObject>

- (void)APIRequestHasInvalidAccessToken:(OUTAPIRequest *)sender;

@end

@interface OUTAPIRequest : NSObject

@property (nonatomic, weak) id<OUTAPIRequestDelegate> delegate;

@property (nonatomic) APICall callType;
/*! Parameters to be used in the call.
 Either a JSON body or query parameters
 */
@property (nonatomic, strong) DLBDictionary *parameters;
/*! Indicates if the access token is needed for the call
 @discussion Default is YES
 */
@property (nonatomic) BOOL needsAccessToken;
/*! Controlls how parameters are used
 @discussion Default is automatic
 */
@property (nonatomic) ParametersType parametersType;
/*! Endpoint used for URL
 */
@property (nonatomic) eEndpointPath endpoint;
/*! Will append to endpoint URL
    Example @"/12"
 */
@property (nonatomic, strong) NSString *endpointSuffix;
@property (nonatomic, readonly) NSNumber *statusCode;

+ (OUTAPIRequest *)newInstance;
+ (OUTAPIRequest *)newInstanceWithEndpoint:(eEndpointPath)endpoint;
+ (OUTAPIRequest *)forEndpoint:(eEndpointPath)endpoint ofType:(APICall)call;

+ (OUTAPIRequest *)loginInstanceWithUserName:(NSString *)name andPassword:(NSString *)password;
+ (OUTAPIRequest *)loginInstanceWithFacebookIdentifier:(NSString *)identifier andToken:(NSString *)accessToken;
+ (OUTAPIRequest *)signUpInstanceWithUserName:(NSString *)name andPassword:(NSString *)password;

- (void)performWithCallback:(void (^)(id responseObject, NSError *error, NSNumber *statusCode))callback;
- (void)perform;

- (void)insertToken:(NSString *)token;

@end
