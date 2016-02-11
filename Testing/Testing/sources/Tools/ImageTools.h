//
//  ImageTools.h
//  Testing
//
//  Created by Zan on 2/11/16.
//  Copyright © 2016 Zan. All rights reserved.
//

@import UIKit;

@interface ImageTools : NSObject

+(void)fetchImageWithURL:(NSString *)URL callback:(void (^)(UIImage *image))callback;

@end
