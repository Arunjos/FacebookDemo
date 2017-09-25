//
//  ImageCacheObject.m
//  YellowJackets
//
//  Created by Wayne Cochran on 3/5/12.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheObject.h"

@implementation ImageCacheObject

@synthesize size, timeStamp, image;

-(id)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage {
    if (self = [super init]) {
        size = sz;
        timeStamp = [NSDate date];
        image = anImage;
    }
    return self;
    
}

-(void)resetTimeStamp {
    timeStamp = [NSDate date];
}


@end
