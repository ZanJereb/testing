//
//  ImageTools.m
//  Testing
//
//  Created by Zan on 2/11/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "ImageTools.h"

@implementation ImageTools

+(void)fetchImageWithURL:(NSString *)URL callback:(void (^)(UIImage *image))callback
{
    NSURL *imageUrl = [NSURL URLWithString:URL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *thumbnailData = [NSData dataWithContentsOfURL:imageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *thumbnail = [UIImage imageWithData:thumbnailData];
            callback(thumbnail);
        });
    });
}
@end
