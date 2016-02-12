//
//  OUTAWSHandler.m
//  Outcast
//
//  Created by Matic Oblak on 9/3/15.
//  Copyright (c) 2015 D·Labs. All rights reserved.
//

#import "OUTAWSHandler.h"
#import <AWSCore/AWSCore.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSSQS/AWSSQS.h>
#import <AWSSNS/AWSSNS.h>
#import <AWSCognito/AWSCognito.h>

@interface OUTAWSHandler ()

@property (nonatomic, strong) AWSStaticCredentialsProvider *credentialsProvider;
@property (nonatomic, strong) AWSServiceConfiguration *configuration;

@end

@implementation OUTAWSHandler

- (void)initialize
{
    self.credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAJTGIMN7S2MM23LPQ" secretKey:@"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"];
    self.configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1
                                                                         credentialsProvider:self.credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = self.configuration;
}

- (AWSS3TransferManagerUploadRequest *)generateDefaultUploadRequest
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"outc-transcode-source";
    return uploadRequest;
}

- (AWSS3TransferManagerUploadRequest *)generateImageUploadRequest
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"outc-data";
    return uploadRequest;
}


- (void)uploadVideo:(NSString *)path withUUID:(NSString *)uuid name:(NSString *)name progressCallback:(void (^)(CGFloat progress, BOOL finished, NSError *error, BOOL *cancel))callback
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    AWSS3TransferManagerUploadRequest *request = [self generateDefaultUploadRequest];
    request.body = fileURL;
    request.key = [NSString stringWithFormat:@"%@/%@", uuid, name];
    request.contentType = @"video/mp4";
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if(error)
    {
        if(callback)
        {
            BOOL cancel = NO;
            callback(.0f, NO, error, &cancel);
        }
    }
    unsigned long long fileSize = fileAttributes.fileSize;
    
    request.contentLength = @(fileSize);
    if(callback)
    {
        __block __weak AWSS3TransferManagerUploadRequest *blockRequest = request;
        [request setUploadProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten;
            progress /= totalBytesExpectedToWrite;
            
            BOOL cancel = NO;
            
            callback(progress, NO, nil, &cancel);
            if(cancel)
            {
                [blockRequest cancel];
            }
        }];
    }
    
    [[[AWSS3TransferManager defaultS3TransferManager] upload:request] continueWithBlock:^id(AWSTask *task) {
        if(callback)
        {
            BOOL cancel = NO;
            callback(1.0f, YES, task.error, &cancel);
        }
        return nil;
    }];
}

- (NSString *)uploadAvatar:(UIImage *)image withUUID:(NSString *)uuid progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *fileName, NSError *error, BOOL *cancel))callback
{
    if(uuid == nil)
    {
        uuid = [[NSUUID UUID] UUIDString];
    }
    NSString *fileName = [NSString stringWithFormat:@"avatar_%@.jpeg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManagerUploadRequest *request = [self generateImageUploadRequest];
    request.body = fileURL;
    request.key = [NSString stringWithFormat:@"%@/%@", uuid, fileName];
    request.contentType = @"image/jpeg";
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if(error)
    {
        if(callback)
        {
            BOOL cancel = NO;
            callback(.0f, NO, fileName, error, &cancel);
        }
    }
    unsigned long long fileSize = fileAttributes.fileSize;
    
    request.contentLength = @(fileSize);
    if(callback)
    {
        __block __weak AWSS3TransferManagerUploadRequest *blockRequest = request;
        [request setUploadProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten;
            progress /= totalBytesExpectedToWrite;
            
            BOOL cancel = NO;
            
            callback(progress, NO, fileName, nil, &cancel);
            if(cancel)
            {
                [blockRequest cancel];
            }
        }];
    }
    
    [[[AWSS3TransferManager defaultS3TransferManager] upload:request] continueWithBlock:^id(AWSTask *task) {
        if(callback)
        {
            BOOL cancel = NO;
            callback(1.0f, YES, fileName, task.error, &cancel);
        }
        return nil;
    }];
    
    return fileName;

}

- (void)uploadChannelLogo:(UIImage *)image withChannelId:(NSString *)chanelID progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *fileName, NSError *error, BOOL *cancel))callback
{
    if (!chanelID.length && !image) {
        NSError *anError = [NSError errorWithDomain:@"Outcast" code:9999 userInfo:@{@"error" : @"Channel ID missing."}];
        BOOL cancel = NO;
        callback(0.0f, NO, nil, anError, &cancel);
        return;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"logo_%@.jpeg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *anError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&anError];
        BOOL cancel = NO;
        callback(0.0f, NO, nil, anError, &cancel);
        return;
    }
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    AWSS3TransferManagerUploadRequest *request = [self generateImageUploadRequest];
    
    request.body = fileURL;
    request.key = [NSString stringWithFormat:@"channels/%@/%@", chanelID, fileName];
    request.contentType = @"image/jpeg";
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if(error)
    {
        if(callback)
        {
            BOOL cancel = NO;
            callback(.0f, NO, fileName, error, &cancel);
        }
    }
    unsigned long long fileSize = fileAttributes.fileSize;
    
    request.contentLength = @(fileSize);
    if(callback)
    {
        __block __weak AWSS3TransferManagerUploadRequest *blockRequest = request;
        [request setUploadProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten;
            progress /= totalBytesExpectedToWrite;
            
            BOOL cancel = NO;
            
            callback(progress, NO, fileName, nil, &cancel);
            if(cancel)
            {
                [blockRequest cancel];
            }
        }];
    }
    
    [[[AWSS3TransferManager defaultS3TransferManager] upload:request] continueWithBlock:^id(AWSTask *task) {
        if(callback)
        {
            BOOL cancel = NO;
            callback(1.0f, YES, fileName, task.error, &cancel);
        }
        
        return nil;
    }];
    
}

- (void)uploadImage:(UIImage *)image withUUID:(NSString *)uuid name:(NSString *)name progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *filePath, NSError *error, BOOL *cancel))callback
{
    if (!image) {
        NSError *anError = [NSError errorWithDomain:@"Outcast" code:9999 userInfo:@{@"error" : @"Image is missing."}];
        BOOL cancel = NO;
        callback(0.0f, NO, nil, anError, &cancel);
        return;
    }
    
    NSURL *fileURL;
    NSString *filePath;
    {
        NSString *fileName = [NSString stringWithFormat:@"logo_%@.jpeg", [[NSUUID UUID] UUIDString]];
        filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *anError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&anError];
            BOOL cancel = NO;
            callback(0.0f, NO, nil, anError, &cancel);
            return;
        }
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
        
        fileURL = [NSURL fileURLWithPath:filePath];
    }
    
    AWSS3TransferManagerUploadRequest *request = [self generateDefaultUploadRequest];
    request.body = fileURL;
    request.key = [NSString stringWithFormat:@"%@/%@", uuid, name];
    request.contentType = @"image/jpeg";
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if(error)
    {
        if(callback)
        {
            BOOL cancel = NO;
            callback(.0f, NO, filePath, error, &cancel);
        }
    }
    unsigned long long fileSize = fileAttributes.fileSize;
    
    request.contentLength = @(fileSize);
    if(callback)
    {
        __block __weak AWSS3TransferManagerUploadRequest *blockRequest = request;
        [request setUploadProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten;
            progress /= totalBytesExpectedToWrite;
            
            BOOL cancel = NO;
            
            callback(progress, NO, filePath, nil, &cancel);
            if(cancel)
            {
                [blockRequest cancel];
            }
        }];
    }
    
    [[[AWSS3TransferManager defaultS3TransferManager] upload:request] continueWithBlock:^id(AWSTask *task) {
        if(callback)
        {
            BOOL cancel = NO;
            callback(1.0f, YES, filePath, task.error, &cancel);
        }
        return nil;
    }];
    
}


- (NSString *)fileNameForEmailAvatarWithBaseName:(NSString *)name
{
    return [[[name stringByDeletingPathExtension] stringByAppendingString:@"-emailThumbnail"] stringByAppendingPathExtension:@"png"];
}

- (NSString *)emailURLFromBaseURLPath:(NSString *)path {
    NSString *extension = path.pathExtension;
    if(extension)
    {
        return [[[path substringToIndex:path.length-(extension.length+1)] stringByAppendingString:@"-emailThumbnail"] stringByAppendingString:@".png"];
    }
    else
    {
        return nil;
    }
}

- (NSString *)uploadEmailAvatar:(UIImage *)image withUUID:(NSString *)uuid fileName:(NSString *)fileName progressCallback:(void (^)(CGFloat progress, BOOL finished, NSString *fileName, NSError *error, BOOL *cancel))callback
{
    if(uuid == nil)
    {
        uuid = [[NSUUID UUID] UUIDString];
    }
    fileName = [self fileNameForEmailAvatarWithBaseName:fileName];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManagerUploadRequest *request = [self generateImageUploadRequest];
    request.body = fileURL;
    request.key = [NSString stringWithFormat:@"%@/%@", uuid, fileName];
    request.contentType = @"image/png";
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if(error)
    {
        if(callback)
        {
            BOOL cancel = NO;
            callback(.0f, NO, fileName, error, &cancel);
        }
    }
    unsigned long long fileSize = fileAttributes.fileSize;
    
    request.contentLength = @(fileSize);
    if(callback)
    {
        __block __weak AWSS3TransferManagerUploadRequest *blockRequest = request;
        [request setUploadProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten;
            progress /= totalBytesExpectedToWrite;
            
            BOOL cancel = NO;
            
            callback(progress, NO, fileName, nil, &cancel);
            if(cancel)
            {
                [blockRequest cancel];
            }
        }];
    }
    
    [[[AWSS3TransferManager defaultS3TransferManager] upload:request] continueWithBlock:^id(AWSTask *task) {
        if(callback)
        {
            BOOL cancel = NO;
            callback(1.0f, YES, fileName, task.error, &cancel);
        }
        return nil;
    }];
    return fileName;
}


@end
