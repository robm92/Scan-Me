//
//  NewEmployee.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "NewEmployee.h"
#import "Department.h"
#import "Employees.h"

@interface NewEmployee ()
{
    NSMutableArray *_pickerData;
    NSMutableArray *_deptList;
    
}
@end

@implementation NewEmployee
@synthesize txtFirstName,txtSecondName,pickerDept,btnAdd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = [[NSMutableArray alloc] init];
    
    //get request
    [self retrieveData];
    
    // Connect data
    self.pickerDept.dataSource = self;
    self.pickerDept.delegate = self;
    
    //round corners of button
    btnAdd.layer.cornerRadius = 10;
    btnAdd.clipsToBounds = YES;
    
    [pickerDept selectRow:2 inComponent:0 animated:NO];
    
}

-(id)jsonPostRequest:(NSData *)jsonRequestData
{
    //URL for the request
    NSURL *url = [NSURL URLWithString:employeePOST];
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
                               
                               
                               [self.pickerDept reloadAllComponents];
                               
                               
                           }];
    //release spinner animation
    //[[self.view viewWithTag:12] removeFromSuperview];
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

- (IBAction)btnAddEmployee:(id)sender {
    
    NSString *DEPT_ID = [NSString stringWithFormat:@"%ld",(long)[pickerDept selectedRowInComponent:0]];
    NSString *EMP_FN = txtFirstName.text;
    NSString *EMP_SN = txtSecondName.text;
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:DEPT_ID,@"DEPT_ID",EMP_FN,@"EMP_FN",EMP_SN,@"EMP_SN", nil];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [self jsonPostRequest:postData];
    
}

@end
