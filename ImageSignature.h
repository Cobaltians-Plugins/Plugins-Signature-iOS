//
//  ImageSignature.h
//  Kiomda
//
//  Created by Sébastien Vitard on 20/04/2018.
//  Copyright (c) 2018 Forms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageSignatureDelegate <NSObject>

@required

- (void)onImage:(UIImage* __nullable)image
 withIdentifier:(NSString* __nonnull)identifier;
- (void)onBase64Image:(NSString* __nullable)image
       withIdentifier:(NSString* __nonnull)identifier;

@end

@interface ImageSignature : NSObject

@property(nonatomic, strong, readonly) NSString* localId;

- (instancetype)initWithId:(nonnull NSString*)localId;
- (instancetype)initWithDirectory:(nonnull NSString*)localId Extension:(NSString*)extension;
- (UIImage* __nullable)image:(CGFloat)requestedSize
                withDelegate:(__nullable id<ImageSignatureDelegate>)delegate;
- (void)base64Image:(CGFloat)requestedSize
       withDelegate:(__nonnull id<ImageSignatureDelegate>)delegate;
- (NSData*)saveImage:(nonnull UIImage*)image compressRate:(int)compressRate;
- (UIImage*)resizeImage:(nonnull UIImage*)image atSize:(float)requestedSize withDelegate:(__nullable id<ImageSignatureDelegate>)delegate;
@end
