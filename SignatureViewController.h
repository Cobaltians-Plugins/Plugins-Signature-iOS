//
//  SignatureViewController.h
//  Forms
//
//  Created by Vincent RIFA - Pro on 12/04/2019.
//  Copyright © 2018 Forms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignatureDelegate

- (void)didSignatureId:(NSString *)id base64:(NSString *)base64;

@end

@interface SignatureViewController : UIViewController{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    BOOL draw;
}
@property (weak, nonatomic) IBOutlet UIView *Instructions;
@property (weak, nonatomic) IBOutlet UILabel *lblInstructions;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
- (IBAction)btnClear:(id)sender;

@property (assign, nonatomic) NSString *base64;
@property (assign, nonatomic) float requestedSize;
@property (weak, nonatomic) id<SignatureDelegate> delegate;

@end
