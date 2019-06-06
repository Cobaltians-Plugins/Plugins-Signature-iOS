//
//  SignaturePlugin.m
//  Forms
//
//  Created by Vincent Rifa on 12/04/2019.
//  Copyright © 2019 Kristal. All rights reserved.
//

#import "SignaturePlugin.h"
#import "SignatureViewController.h"
#import <Cobalt/PubSub.h>

@implementation SignaturePlugin

- (void)onMessageFromWebView:(WebViewType)webView
          inCobaltController:(nonnull CobaltViewController *)viewController
                  withAction:(nonnull NSString *)action
                        data:(nullable NSDictionary *)data
          andCallbackChannel:(nullable NSString *)callbackChannel
{
    NSLog(@"SignaturePlugin - onMessageFromCobaltController: Entering...");
    _viewController = viewController;
    _callback = callbackChannel;
    
    UIStoryboard *signatureStoryboard = [UIStoryboard storyboardWithName:@"SignatureStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController = [signatureStoryboard instantiateInitialViewController];
    SignatureViewController *signatureviewController = navigationController.viewControllers[0];
    signatureviewController.delegate = self;
    
    if (action != nil && [action isEqualToString:@"sign"]) {
        if (data != nil) {
            id size = data[@"size"];
            if (size != nil && [size isKindOfClass:[NSNumber class]]) {
                signatureviewController.requestedSize = [data[@"size"] floatValue];
            }
        }
        [_viewController.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Location
////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didSignatureId:(NSString *)id base64:(NSString *)base64 {
    NSLog(@"SignaturePlugin - didSignatureId: Back from Signature with picture: %@",id);
    
    NSDictionary *data = (id != nil) ? @{@"id": id,@"picture": base64} : @{};
    
    [[PubSub sharedInstance] publishMessage:data
                                  toChannel:_callback];
    
    [_viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
