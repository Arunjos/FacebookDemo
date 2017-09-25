//
//  AsynchImageView.h
//  YellowJackets
//
//  Created by Wayne Cochran on 3/5/12.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCache.h"

@interface AsyncImageView : UIImageView

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *data;
@property (copy, nonatomic) NSString *urlString; // key for image cache dictionary

-(void)loadImageFromURL:(NSURL*)url;

+(void)purgeCache;

+ (ImageCache *)getImageCache;

@end
