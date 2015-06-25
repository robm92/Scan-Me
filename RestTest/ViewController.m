//
//  ViewController.m
//  RestTest
//
//  Created by Rob McMorran on 20/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import "ViewController.h"
#import "IOSRequest.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define getDataURL @"http://192.168.0.7:8888/ords/rob/hr/employees/"

@interface ViewController ()


@end

@implementation ViewController
@synthesize userArray,jsonArray,btnSignIn,lblMainTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self retrieveData];
    
    //title shadow
    UIColor *color = [UIColor blackColor];
    lblMainTitle.layer.shadowColor = [color CGColor];
    lblMainTitle.layer.shadowRadius = 1.0f;
    lblMainTitle.layer.shadowOpacity = 0.5;
    lblMainTitle.layer.shadowOffset = CGSizeZero;
    lblMainTitle.layer.masksToBounds = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//textbox minimise on return key
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)btnLogin:(id)sender {
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Use Touch ID to login"
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"There was a problem verifying your identity."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  return;
                              }
                              
                              if (success) {
                                 //authenticated
                                  [self performSegueWithIdentifier:@"loginSegue" sender:self];
                                  
                              } else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"Touch ID invalid, Please login using username and password."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                              }
                              
                          }];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot authenticate using TouchID."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    }

    
  
}
@end
