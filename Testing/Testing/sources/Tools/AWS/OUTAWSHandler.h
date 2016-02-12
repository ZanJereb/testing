//
//  OUTAWSHandler.h
//  Outcast
//
//  Created by Matic Oblak on 9/3/15.
//  Copyright (c) 2015 D·Labs. All rights reserved.
//

#import "DOSingleton.h"
@import UIKit;

@interface OUTAWSHandler : DOSingleton

- (void)initialize;
- (void)uploadVideo:(NSString *)path withUUID:(NSString *)uuid name:(NSString *)name progressCallback:(void (^)(CGFloat progress, BOOL finished, NSError *error, BOOL *cancel))callback;
- (NSString *)uploadAvatar:(UIImage *)image withUUID:(NSString *)uuid progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *fileName, NSError *error, BOOL *cancel))callback;
- (void)uploadChannelLogo:(UIImage *)image withChannelId:(NSString *)chanelID progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *fileName, NSError *error, BOOL *cancel))callback;
- (NSString *)emailURLFromBaseURLPath:(NSString *)path;
- (NSString *)uploadEmailAvatar:(UIImage *)image withUUID:(NSString *)uuid fileName:(NSString *)fileName progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *fileName, NSError *error, BOOL *cancel))callback;
- (void)uploadImage:(UIImage *)image withUUID:(NSString *)uuid name:(NSString *)name progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *filePath, NSError *error, BOOL *cancel))callback;

@end
