//
//  Image.h
//  Kiomda
//
//  Created by Sébastien Vitard on 20/04/2018.
//  Copyright (c) 2018 Kiomda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageDelegate <NSObject>

@required

- (void)onImage:(UIImage* __nullable)image
 withIdentifier:(NSString* __nonnull)identifier;
- (void)onBase64Image:(NSString* __nullable)image
       withIdentifier:(NSString* __nonnull)identifier;

@end

@interface Image : NSObject

@property(nonatomic, strong, readonly) NSString* localId;

- (instancetype)initWithId:(nonnull NSString*)localId;
- (UIImage* __nullable)image:(CGFloat)requestedSize
                withDelegate:(__nullable id<ImageDelegate>)delegate;
- (void)base64Image:(CGFloat)requestedSize
       withDelegate:(__nonnull id<ImageDelegate>)delegate;
@end
