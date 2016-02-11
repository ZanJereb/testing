//
//  OUTAPIManager.h
//  Outcast
//
//  Created by Matic Oblak on 3/14/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OUTAPIRequest.h"
#import <DOSingleton/DOSingleton.h>
@class OUTUserModel;

@protocol OUTAPIManagerDelegate <NSObject>

@optional
- (void)APIManagerShouldRefreshAccessToken;
- (void)APIManagerShouldLogin;

@end

@interface OUTAPIManager : DOSingleton

/*! Delegate
 @discussion Set a delegate to get the information from the manager
 */
@property (nonatomic, weak) id<OUTAPIManagerDelegate> delegate;

@property (nonatomic, readonly) BOOL isLoggedIn;
/*! Perform a request
 @param request A request to be performed
 @param callback A callback invoked when request is done
 @discussion Will try creating a request. If the token needs refreshing this should be done automatically.
 */
- (void)performRequest:(OUTAPIRequest *)request withCallback:(void (^)(id responseObject, NSError *error, NSNumber *statusCode))callback;
/*! Perform a login request
 @param userName A user name set by the user
 @param password A password set by the user
 @param callback A callback invoked when request is done
 @discussion Will login user if credidentials are correct and save the tokens.
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password callback:(void (^)(BOOL didLogin, NSError *error))callback;
- (void)loginWithFacebookID:(NSString *)FBIdentifier token:(NSString *)FBToken callback:(void (^)(BOOL didLogin, NSError *error))callback;
- (void)signUpWithUserName:(NSString *)userName password:(NSString *)password user:(OUTUserModel *)user callback:(void (^)(BOOL didLogin, NSError *error, NSDictionary *response))callback;
// TODO:
- (void)logOut;
- (void)serializeRefreshToken:(NSString *)token;

@end
