//
//  EmployeeDetails.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "EmployeeDetails.h"
#import "Department.h"
#define departmentGET @"http://77.100.69.163:8888/ords/rob/hr/Department"
#define employeePOST @"http://77.100.69.163:8888/ords/rob/hr/employees/"

@interface EmployeeDetails ()
{
    NSMutableArray *_pickerData;
    NSArray *_listData;
    NSInteger selectedEmployee;
    Employee *passedEmp;
}
@end
@implementation EmployeeDetails

@synthesize lstEmployeeDetails,txtSecondName,txtFirstName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = [[NSMutableArray alloc] init];
    _listData = @[@"Blackberry", @"Laptop"];
    
    // Connect data
    self.deptPicker.dataSource = self;
    self.deptPicker.delegate = self;
    self.lstEmployeeDetails.dataSource = self;
    self.lstEmployeeDetails.delegate = self;
    [self retrieveData];
    
    txtFirstName.text = passedEmp.FirstName;
    txtSecondName.text = passedEmp.SecondName;
    
    
    
}
//number rows in list
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_listData objectAtIndex:indexPath.row];
    return cell;
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Department * dept = [[Department alloc] init];
    dept = [_pickerData objectAtIndex:(row)];
    return dept.Name;
}

- (void) passEmp:(Employee*)emp{
    passedEmp = [[Employee alloc] init];
    passedEmp = emp;
    
}

- (void) retrieveData
{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:departmentGET]];
    
    __block NSMutableDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);//output the json dictionary raw
                               //make two arrays to hold the json instances sequentialy
                               
                               
                               
                               NSArray * responseArr = json[@"items"];//make an array which holds each json 'user'
                               
                               for(NSDictionary * dict in responseArr)//for every department in the responseArr, add their respective details to the arrays
                               {
                                   Department * dept = [[Department alloc] init];
                                   dept.Name = [dict valueForKey:@"dept_name"];
                                   dept.DeptID = [dict valueForKey:@"dept_id"];
                                   dept.CostCentre = [dict valueForKey:@"cost_centre"];
                                   [_pickerData addObject: dept];
                                   
                               }
                               
                               
                               [self.deptPicker reloadAllComponents];
                               [_deptPicker selectRow:passedEmp.DepartmentID inComponent:0 animated:YES];
                               
                           }];
    //release spinner animation
    //[[self.view viewWithTag:12] removeFromSuperview];
}
- (IBAction)unwindToEmployeeDetails:(UIStoryboardSegue *)unwindSegue
{
}

@end
