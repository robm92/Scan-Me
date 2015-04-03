//
//  Employees.h
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Employees : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *lstEmployees;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

- (void)hideDeleteButton:(id)obj;

@end
