//
//  ImageCache.h
//  YellowJackets
//
//  Created by Wayne Cochran on 3/5/12.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCache : NSObject

@property (nonatomic, readonly) NSUInteger maxSize;
@property (nonatomic, readonly) NSUInteger totalSize;
@property (nonatomic, strong, readwrite) NSMutableDictionary *imageDictionary;

-(id)initWithMaxSize:(NSUInteger) max;
-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key;
-(UIImage*)imageForKey:(NSString*)key;

@end
