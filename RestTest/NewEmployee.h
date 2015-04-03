//
//  NewEmployee.h
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>
#define departmentGET @"http://77.100.69.163:8888/ords/rob/hr/Department"
#define employeePOST @"http://77.100.69.163:8888/ords/rob/hr/employees/"

@interface NewEmployee : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerDept;
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtSecondName;
- (IBAction)btnAddEmployee:(id)sender;


@end
