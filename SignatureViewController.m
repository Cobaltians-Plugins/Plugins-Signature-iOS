//
//  SignatureViewController.m
//  Forms
//
//  Created by Vincent RIFA - Pro on 12/04/2019.
//  Copyright © 2018 Forms. All rights reserved.
//

#import "SignatureViewController.h"

#import <Cobalt/Image.h>
#import <Cobalt/Cobalt.h>

@interface SignatureViewController() {
    __weak IBOutlet UIImageView *SignatureImage;
}

@end

@implementation SignatureViewController

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark METHODS

////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 2.0;
    opacity = 1.0;
    
    draw = NO;
    [self refreshInfo];
    
    [super viewDidLoad];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark METHODS

////////////////////////////////////////////////////////////////////////////////////////////////

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //Starting drawing
    mouseSwiped = NO;
    draw = YES;
    [self refreshInfo];
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //Draw lines
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [SignatureImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    SignatureImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [SignatureImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //If mouse wasn't swiped, draw a dot.
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [SignatureImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        SignatureImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void)refreshInfo {
    //If there's a signature
    if (draw) {
        //Hide instructions
        [_Instructions setHidden:YES];
        [_lblInstructions setHidden:YES];
        //Display clear button
        [_btnClear setHidden:NO];
    }
    //If there's no signature
    else {
        //Hide clear button
        [_btnClear setHidden:YES];
        //Display instructions
        [_lblInstructions setHidden:NO];
        [_Instructions setHidden:NO];
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark BUTTONS DELEGATE

////////////////////////////////////////////////////////////////////////////////////////////////

//Click on Cancel
- (IBAction)onCancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// Click on Save
- (IBAction)onOK:(id)sender {
    if (_delegate != nil  && draw == YES) {
        UIGraphicsBeginImageContextWithOptions(SignatureImage.bounds.size, NO,0.0);
        [SignatureImage.image drawInRect:CGRectMake(0, 0, SignatureImage.frame.size.width, SignatureImage.frame.size.height)];
        UIImage *SavedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Defining directory and filepath
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        Image *image = [[Image alloc] initWithDirectory:documentsDirectory Extension:@".jpg"];
        
        //Resizing
        SavedImage = [image resizeImage:SavedImage atSize:_requestedSize withDelegate:nil];
        
        //Save Signature as file .jpg
        NSData *imageData = [image saveImage:SavedImage compressRate:100];
        
        
        //Save bitmap in base64
        NSString *base64 = [imageData base64EncodedStringWithOptions:0];
        
        //Sending back id and base64
        [_delegate didSignatureId:[image localId] base64:base64];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

//Click on Btn Clear, suppress current signature
- (IBAction)btnClear:(id)sender {
    SignatureImage.image = nil;
    draw = NO;
    [self refreshInfo];
}
@end

