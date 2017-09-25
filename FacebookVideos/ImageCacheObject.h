//
//  ImageCacheObject.h
//  YellowJackets
//
//  Created by Wayne Cochran on 3/5/12.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCacheObject : NSObject

@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, strong, readonly) NSDate *timeStamp;
@property (nonatomic, strong, readonly) UIImage *image;

-(id)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage;
-(void)resetTimeStamp;


@end
