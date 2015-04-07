//
//  BarcodeViewController.h
//  RestTest
//
//  Created by Rob McMorran on 30/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@interface BarcodeViewController : UIViewController

@property NSMutableArray *scanResult;
- (void) passEmp:(Employee*)emp;

@end
