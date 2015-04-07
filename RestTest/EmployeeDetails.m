//
//  EmployeeDetails.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "EmployeeDetails.h"
#import "Department.h"
#import "Asset.h"
#import "BarcodeViewController.h"
#define departmentGET @"http://77.100.69.163:8888/ords/rob/hr/Department"
#define employeePOST @"http://77.100.69.163:8888/ords/rob/hr/employees/"

@interface EmployeeDetails ()
{
    NSMutableArray *_pickerData;
    NSMutableArray *_listData;
    NSInteger selectedEmployee;
    Employee *passedEmp;
    NSIndexPath *selectedRow;
}
@end
@implementation EmployeeDetails

@synthesize lstEmployeeDetails,txtSecondName,txtFirstName,btnAssign,btnEdit;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = [[NSMutableArray alloc] init];
    _listData = [[NSMutableArray alloc] init];
    
    // Connect data
    self.deptPicker.dataSource = self;
    self.deptPicker.delegate = self;
    self.lstEmployeeDetails.dataSource = self;
    self.lstEmployeeDetails.delegate = self;
    [self retrieveData];
    
    txtFirstName.text = passedEmp.FirstName;
    txtSecondName.text = passedEmp.SecondName;
    
    //round corners of buttons
    btnEdit.layer.cornerRadius = 10;
    btnEdit.clipsToBounds = YES;
    btnAssign.layer.cornerRadius = 10;
    btnAssign.clipsToBounds = YES;
    
    [self getAssignedAssets];
    
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
    
    @try {
        Asset *asset = [[Asset alloc] init];
        asset = [_listData objectAtIndex:indexPath.row];
        cell.textLabel.text = asset.Asset_name;
    }
    @catch (NSException *exception) {
        NSLog(@"Failed trying to add Assets to listView - %@", exception.reason);
    }
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
                               [_deptPicker selectRow:passedEmp.DepartmentID inComponent:0 animated:NO];
                               
                           }];
    //release spinner animation
    //[[self.view viewWithTag:12] removeFromSuperview];
}

-(void) getAssignedAssets
{
    //debug only - find the real one!
    NSInteger userID = passedEmp.EmployeeID;
    
    NSString *assignedAsset = [NSString stringWithFormat:@"http://77.100.69.163:8888/ords/rob/hr/employees/AssignedAsset/%ld",(long)userID];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:assignedAsset]];
    
    __block NSMutableDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);//output the json dictionary raw
                               
                               NSArray * responseArr = json[@"items"];
                               
                               for(NSDictionary *item in responseArr)//for every department in the responseArr, add their respective details to the arrays
                               {
                                   Asset *asset = [[Asset alloc] init];
                                   asset.Asset_serial = [item valueForKey:@"serial"];
                                   asset.Asset_name = [item valueForKey:@"asset_name"];
                                   [_listData addObject:asset];
                               }
                               [self.lstEmployeeDetails reloadData];
                               
                           }];
    //release spinner animation
    [[self.view viewWithTag:12] removeFromSuperview];
}


- (IBAction)unwindToEmployeeDetails:(UIStoryboardSegue *)unwindSegue
{
    //only reloads what's already stored, might need to reload from DB as well
    [_listData removeAllObjects];
    [self getAssignedAssets];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        selectedRow = indexPath;
        
        [self performSelector:@selector(hideDeleteButton:) withObject:nil afterDelay:0.1];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unassign Asset" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
        
    }
}

- (void)hideDeleteButton:(id)obj
{
    [self.lstEmployeeDetails setEditing:NO animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        
        [self unassignAsset];
        [_listData removeAllObjects];
        [self getAssignedAssets];
    }
}

-(void)unassignAsset
{
    Asset *asset = [[Asset alloc] init];
    asset = [_listData objectAtIndex:selectedRow.row];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:asset.Asset_serial,@"serial" ,nil];
    
    NSError *error;
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];

    NSURL *url = [NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/employees/UnassignAsset"];
    //the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    NSLog(@"The Json post request: %@", request);
    
    //bind request with jsonrequestdata
    [request setHTTPMethod:@"POST"]; //n.b its a post request, not get
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonRequestData];//set jsonRequestData into body
    
    //send sync request
    NSURLResponse *response = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"The Json post result: %@", result);

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ScanAssign"])
    {
        // Get reference to the destination view controller
        BarcodeViewController *bvc = [segue destinationViewController];

        // Pass any objects to the view controller here, like...
        [bvc passEmp:passedEmp];
        
        
    }
}
- (IBAction)btnEdit:(id)sender
{
    
    if([txtFirstName.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid input"
                                                        message:@"Please enter fields correctly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else if([txtSecondName.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid input"
                                                        message:@"Please enter fields correctly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        NSString *EMP_FN = txtFirstName.text;
        passedEmp.FirstName = txtFirstName.text;
        NSString *EMP_SN =  txtSecondName.text;
        passedEmp.SecondName = txtSecondName.text;
        NSInteger DEPT_ID = [self.deptPicker selectedRowInComponent:0];
        passedEmp.DepartmentID = DEPT_ID;
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:passedEmp.EmployeeID],@"EMP_ID",EMP_FN,@"EMP_FN",EMP_SN,@"EMP_SN",[NSNumber numberWithInteger:DEPT_ID],@"DEPT_ID", nil];
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        [self jsonPostRequest:postData];
        //refresh data
        [_listData removeAllObjects];
        [self retrieveData];
        [self.view endEditing:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit complete"
                                                        message:@"Employee details edited successfuly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }

    
}
-(id)jsonPostRequest:(NSData *)jsonRequestData
{
    //URL for the request
    NSURL *url = [NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/employees/EditEmployee"];
    //the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    NSLog(@"The Json post request: %@", request);
    
    //bind request with jsonrequestdata
    [request setHTTPMethod:@"POST"]; //n.b its a post request, not get
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonRequestData];//set jsonRequestData into body
    
    //send sync request
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"The Json post result: %@", result);
    if(error ==nil)
        return result;
    
    return nil;
    
}

@end
