//
//  SignaturePlugin.h
//  Forms
//
//  Created by Vincent Rifa on 12/04/2019.
//  Copyright © 2019 Kristal. All rights reserved.
//

#import <Cobalt/CobaltAbstractPlugin.h>
#import "SignatureViewController.h"


@interface SignaturePlugin : CobaltAbstractPlugin <SignatureDelegate> {
    CobaltViewController * _viewController;
    NSString *_callback;
}


@end

