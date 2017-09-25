//
//  ImageCache.m
//  YellowJackets
//
//  Created by Wayne Cochran on 3/5/12.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import "ImageCacheObject.h"

@implementation ImageCache

@synthesize maxSize, totalSize, imageDictionary;

-(id)initWithMaxSize:(NSUInteger) max {
    if (self = [super init]) {
        totalSize = 0;
        maxSize = max;
        imageDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;    
}

-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key {
    ImageCacheObject *object = [[ImageCacheObject alloc] initWithSize:sz Image:image];
    while (totalSize + sz > maxSize) {
        NSDate *oldestTime;
        NSString *oldestKey;
        for (NSString *key in [imageDictionary allKeys]) {
            ImageCacheObject *obj = [imageDictionary objectForKey:key];
            if (oldestTime == nil || [obj.timeStamp compare:oldestTime] == NSOrderedAscending) {
                oldestTime = obj.timeStamp;
                oldestKey = key;
            }
        }
        if (oldestKey == nil) 
            break; // shoudn't happen
        ImageCacheObject *obj = [imageDictionary objectForKey:oldestKey];
        totalSize -= obj.size;
        [imageDictionary removeObjectForKey:oldestKey];
    }
    [imageDictionary setObject:object forKey:key];    
}

-(UIImage*)imageForKey:(NSString*)key {
    ImageCacheObject *object = [imageDictionary objectForKey:key];
    if (object == nil)
        return nil;
    [object resetTimeStamp];
    return object.image;    
}


@end
