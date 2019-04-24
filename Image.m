//
//  Image.m
//  Kiomda
//
//  Created by Sébastien Vitard on 20/04/2018.
//  Copyright (c) 2018 Kiomda. All rights reserved.
//

#import "Image.h"
#import <Photos/Photos.h>

typedef enum
{
    AUTHORIZED = 1,
    DENIED,
    REQUESTED
} Status;

@implementation Image

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark LIFECYCLE

////////////////////////////////////////////////////////////////////////////////////////////////////

- (instancetype)initWithId:(NSString*)localId
{
    if (self = [super init])
    {
        _localId = localId;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark METHODS

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIImage* __nullable)image:(CGFloat)requestedSize
                withDelegate:(__nullable id<ImageDelegate>)delegate
{
    switch([self checkAuthorizationStatusForBase64:NO
                                 withRequestedSize:requestedSize
                                       andDelegate:delegate])
    {
        case REQUESTED:
            return nil;
        case DENIED:
            if (delegate != nil)
            {
                [delegate onImage:nil
                   withIdentifier:_localId];
            }
            return nil;
        case AUTHORIZED:
            break;
    }
    
    UIImage *image = [self getImage];
    if (image == nil)
    {
        NSLog(@"Image - image: could not create image from %@", _localId);
        if (delegate != nil)
        {
            [delegate onImage:nil
               withIdentifier:_localId];
        }
        return nil;
    }
    
    CGImageRef currentImageRef = image.CGImage;
    if (currentImageRef == NULL)
    {
        NSLog(@"Image - image: could not read CGImage property of image from %@", _localId);
        if (delegate != nil)
        {
            [delegate onImage:nil
               withIdentifier:_localId];
        }
        return nil;
    }
    
    // Size computing
    size_t resizedWidth = CGImageGetWidth(currentImageRef);
    size_t resizedHeight = CGImageGetHeight(currentImageRef);
    size_t longestDimension = MAX(resizedWidth, resizedHeight);
    if (longestDimension > requestedSize)
    {
        float ratio = (float) longestDimension / (float) requestedSize;
        resizedWidth = floor(resizedWidth / ratio);
        resizedHeight = floor(resizedHeight / ratio);
    }
    
    // Resize
    CGContextRef context = CGBitmapContextCreate(nil, resizedWidth, resizedHeight,
                                                 CGImageGetBitsPerComponent(currentImageRef),
                                                 CGImageGetBytesPerRow(currentImageRef),
                                                 CGImageGetColorSpace(currentImageRef),
                                                 CGImageGetBitmapInfo(currentImageRef));
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, resizedWidth, resizedHeight), currentImageRef);
    CGImageRef resizedImageRef = CGBitmapContextCreateImage(context);
    UIImage *resizedImage = [UIImage imageWithCGImage:resizedImageRef];
    CFRelease(resizedImageRef);
    CFRelease(context);
    
    if (delegate != nil)
    {
        [delegate onImage:resizedImage
           withIdentifier:_localId];
    }
    return resizedImage;
}

- (void)base64Image:(CGFloat)requestedSize
       withDelegate:(__nonnull id<ImageDelegate>)delegate
{
    switch([self checkAuthorizationStatusForBase64:YES
                                 withRequestedSize:requestedSize
                                       andDelegate:delegate])
    {
        case REQUESTED:
            return;
        case DENIED:
            [delegate onBase64Image:nil
                     withIdentifier:_localId];
            return;
        case AUTHORIZED:
            break;
    }
    
    UIImage *image = [self image:requestedSize
                    withDelegate:nil];
    if (image == nil)
    {
        [delegate onBase64Image:nil
                 withIdentifier:_localId];
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if (data == nil)
    {
        NSLog(@"Image - base64Image: error while generating data (no data or unsupported bitmap format)");
        [delegate onBase64Image:nil
                 withIdentifier:_localId];
    }
    
    [delegate onBase64Image:[data base64EncodedStringWithOptions:0]
             withIdentifier:_localId];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark HELPERS

////////////////////////////////////////////////////////////////////////////////////////////////////

- (Status)checkAuthorizationStatusForBase64:(BOOL)base64
                          withRequestedSize:(CGFloat)requestedSize
                                andDelegate:(__nullable id<ImageDelegate>)delegate
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            return AUTHORIZED;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            return DENIED;
        case PHAuthorizationStatusNotDetermined:
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (base64)
                {
                    [self base64Image:requestedSize withDelegate:delegate];
                }
                else
                {
                    [self image:requestedSize withDelegate:delegate];
                }
            }];
            return REQUESTED;
    }
}

- (UIImage *)getImage
{
    PHFetchResult* res = [PHAsset fetchAssetsWithLocalIdentifiers:@[_localId]
                                                          options:nil];
    if (res.count > 0)
    {
        __block UIImage *img;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        
        PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOptions.synchronous = YES;
        
        [manager requestImageForAsset:res[0]
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            img = image;
                        }];
        
        return img;
    }
    else
    {
        return nil;
    }
}

@end
