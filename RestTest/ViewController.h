//
//  ViewController.h
//  RestTest
//
//  Created by Rob McMorran on 20/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;


@property (nonatomic, strong) NSDictionary * jsonArray;
@property (nonatomic, strong) NSMutableArray * userArray;
@property (weak, nonatomic) IBOutlet UILabel *lblMainTitle;

- (IBAction)btnFetch:(id)sender;

-(id)jsonPostRequest:(NSData *)jsonRequestData;
-(void) jsonSetup;
-(void) retrieveData;


@end

