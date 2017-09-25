//
//  AsynchImageView.m
//  YellowJackets
//
//  Created by Wayne Cochran on 3/5/12.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCacheObject.h"
#import "ImageCache.h"
#import "QuartzCore/QuartzCore.h"

//
// Key's are URL strings.
// Value's are ImageCacheObject's
//
static ImageCache *imageCache = nil;

@implementation AsyncImageView

@synthesize connection, data, urlString;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (ImageCache *)getImageCache
{
    return imageCache;
}

+(void)purgeCache {
    imageCache = nil;
}

-(void)loadImageFromURL:(NSURL*)url {
    
    //
    // Cancel any current connection.
    //
    [connection cancel];
    connection = nil;
    data = nil;
    
    //
    // Lazily create image cache.
    //
    if (imageCache == nil)
        imageCache = [[ImageCache alloc] initWithMaxSize:2*1024*1024];  // 2 MB Image cache
    
    //
    // Remove any subviews.
    //
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    //
    // Lookup image in cache.
    // If found, delete any subviews and add image as subview.
    //
    urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cachedImage];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        
        // for rounded corner.
        
//        CALayer * l = [imageView layer];
//        [l setMasksToBounds:YES];
//        [l setCornerRadius:10.0];
        
        [imageView setNeedsLayout]; // is this necessary if superview gets setNeedsLayout?
        [self setNeedsLayout];
        return;
    }
    
    //
    // If image not found in cache, we'll add a spinning activity indicator as
    // a subview and initial an URL connection to fetch the image.
    //
#define SPINNY_TAG 5555 
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
        UIImageView *placeHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        placeHolderView.backgroundColor = [UIColor clearColor];
//        placeHolderView.image = [UIImage imageNamed:@"placeHolder.png"];
        placeHolderView.tag = SPINNY_TAG;
        
        UIActivityIndicatorView *spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinny.center = placeHolderView.center;
        [spinny startAnimating];
        [placeHolderView addSubview:spinny];
        
        [self addSubview:placeHolderView];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                             timeoutInterval:60.0];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    connection = nil;
    
    UIView *placeHolderView = [self viewWithTag:SPINNY_TAG];
    [placeHolderView removeFromSuperview];
    
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    UIImage *image = [UIImage imageWithData:data];
    
    [imageCache insertImage:image withSize:[data length] forKey:urlString];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView setImage:image];
    
    if(image == NULL) {
        
        [imageView setImage:NULL];
    }
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    [imageView setNeedsLayout]; // is this necessary if superview gets setNeedsLayout?
    [self setNeedsLayout];
    data = nil;
}


@end
