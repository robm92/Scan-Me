//
//  EmployeeDetails.h
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@interface EmployeeDetails : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *deptPicker;
@property (weak, nonatomic) IBOutlet UITableView *lstEmployeeDetails;
- (void) passEmp:(Employee*)emp;
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtSecondName;

- (void)hideDeleteButton:(id)obj;

@end
