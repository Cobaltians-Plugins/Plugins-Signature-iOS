//
//  SignaturePlugin.m
//  Forms
//
//  Created by Vincent Rifa on 12/04/2019.
//  Copyright © 2019 Kristal. All rights reserved.
//

#import "SignaturePlugin.h"
#import "SignatureViewController.h"
#import "Image.h"

@implementation SignaturePlugin

- (void)onMessageFromCobaltController:(CobaltViewController *)viewController andData: (NSDictionary *)message {
    NSLog(@"SignaturePlugin - onMessageFromCobaltController: Entering...");
    _viewController = viewController;
    _callback = [message objectForKey:kJSCallback];
    
    UIStoryboard *signatureStoryboard = [UIStoryboard storyboardWithName:@"SignatureStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController = [signatureStoryboard instantiateInitialViewController];
    SignatureViewController *signatureviewController = navigationController.viewControllers[0];
    signatureviewController.delegate = self;
    
    NSString *action = [message objectForKey:kJSAction];
    if (action != nil && [action isEqualToString:@"sign"]) {
        [_viewController.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Location
////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didSignatureId:(NSString *)id base64:(NSString *)base64 {
    NSLog(@"SignaturePlugin - didSignatureId: Back from Signature with picture: %@",id);
    
    NSDictionary *data = (id != nil) ? @{@"id": id,@"picture": base64} : @{};
    
    [_viewController sendCallback:_callback withData:data];
    
    [_viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
