//
//  Employees.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Employees.h"
#import "Employee.h"
#import "EmployeeDetails.h"
#import <QuartzCore/QuartzCore.h>
#define employeeGET @"http://77.100.69.163:8888/ords/rob/hr/employees/"
#define employeeDELETE @"http://77.100.69.163:8888/ords/rob/hr/employees/delete/"


@interface Employees () <UIAlertViewDelegate>
{
    NSMutableArray *_employeeList;
    NSMutableArray *_employeeTempList;
    NSIndexPath * selectedRow;
}
@end

@implementation Employees
@synthesize lstEmployees,txtSearch,btnAddEmp;

- (void)viewDidLoad
{
    //start spinner animation
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    self.lstEmployees.allowsMultipleSelectionDuringEditing = NO;
    
    [self retrieveData];
    _employeeList = [[NSMutableArray alloc] init];
    self.lstEmployees.dataSource = self;
    self.lstEmployees.delegate = self;
    
    //round corners of button
    btnAddEmp.layer.cornerRadius = 10;
    btnAddEmp.clipsToBounds = YES;
    [self loadTabImages];
    
    [super viewDidLoad];
    
}

-(void) loadTabImages
{
    //solves odd issue where tab bar images aren't loaded until selected...
    UITabBar *tabBar = self.tabBarController.tabBar;
    //UITabBarItem *item0 = [tabBar.items objectAtIndex:0]; unused - already selected on load
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    
    [item1 setImage:[[UIImage imageNamed:@"package.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    
    [item1 setSelectedImage:[[UIImage imageNamed:@"package.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    [item2 setImage:[[UIImage imageNamed:@"pie_chart-36.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    
    [item2 setSelectedImage:[[UIImage imageNamed:@"pie_chart-36.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
}

- (void) retrieveData
{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:employeeGET]];
    
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
                               
                               for(NSDictionary * dict in responseArr)//for every user in the responseArr, add their respective details to the arrays
                               {
                                   Employee * emp = [[Employee alloc] init];
                                   emp.FirstName = [dict valueForKey:@"emp_fn"];
                                   emp.SecondName = [dict valueForKey:@"emp_sn"];
                                   emp.EmployeeID = [[dict valueForKey:@"emp_id"]intValue];
                                   emp.DepartmentID = [[dict valueForKey:@"dept_id"]intValue];
                                   [_employeeList addObject: emp];
                                   
                               }
                               
                               Employee * emp = [[Employee alloc] init];
                               emp = [_employeeList objectAtIndex:(0)];
                               NSArray *sortedArray = [_employeeList sortedArrayUsingComparator:^(Employee *a, Employee *b) {
                                   return [a.FirstName caseInsensitiveCompare:b.FirstName];
                               }];
                               _employeeList = [NSMutableArray arrayWithArray:sortedArray];
                               [self.lstEmployees reloadData];
                               
                               //release spinner animation
                               [[self.view viewWithTag:12] removeFromSuperview];
                           }];
    
}

-(id)jsonDeleteRequest:(NSData *)jsonRequestData
{
    //URL for the request
    NSURL *url = [NSURL URLWithString:employeeDELETE];
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

- (IBAction)unwindToEmployees:(UIStoryboardSegue *)unwindSegue
{
    [_employeeList removeAllObjects];
    [self retrieveData];
    [self.lstEmployees reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EmployeeDetailSegue" sender:self];
}

//number rows in list
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_employeeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Employee * emp = [_employeeList objectAtIndex:indexPath.row];
    cell.textLabel.text = [emp getName:emp];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        //get the Employee from _employeelist using indexpath

        selectedRow = indexPath;
        
        [self performSelector:@selector(hideDeleteButton:) withObject:nil afterDelay:0.1];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Employee" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
  
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        
        Employee *selectedEmp = [[Employee alloc] init];
        selectedEmp = [_employeeList objectAtIndex:selectedRow.row];
        
        NSString *EMP_ID = [NSString stringWithFormat:@"%ld",(long)selectedEmp.EmployeeID];
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:EMP_ID,@"EMP_ID", nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        [self jsonDeleteRequest:postData];
        [_employeeList removeAllObjects];
        [self retrieveData];
        [self.lstEmployees reloadData];
    }
}

- (void)hideDeleteButton:(id)obj
{
    [self.lstEmployees setEditing:NO animated:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //every time the search field is changed, the value is stored in searchStr
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([searchStr  isEqual: @""])
    {
        [_employeeList removeAllObjects];
        [self retrieveData];
        [self.lstEmployees reloadData];
    }
    
    _employeeTempList = [NSMutableArray arrayWithArray:_employeeList];
    [_employeeList removeAllObjects];
    
    //search the array with the string from text box
    for(Employee * emp in _employeeTempList)
    {
        //allows substring search
        NSString *regEx = [NSString stringWithFormat:@".*%@.*", searchStr];
        NSRange rangeFirst = [[emp.FirstName lowercaseString] rangeOfString:regEx options:NSRegularExpressionSearch];
        NSRange rangeSecond = [[emp.SecondName lowercaseString] rangeOfString:regEx options:NSRegularExpressionSearch];
        if (rangeFirst.location != NSNotFound | rangeSecond.location != NSNotFound) {
            [_employeeList addObject:emp];
        }
    }
    
    //repopulate with search result
    [self.lstEmployees reloadData];
    //[self retrieveData];
    
    return YES;
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing: (UITextField *) textField {
    textField.text = @"";
}

- (IBAction)txtSearch:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"EmployeeDetailSegue"])
    {
        // Get reference to the destination view controller
        EmployeeDetails *ed = [segue destinationViewController];
        Employee *emp = [[Employee alloc] init];
        emp = [_employeeList objectAtIndex:[lstEmployees indexPathForSelectedRow].row];
        
        // Pass any objects to the view controller here, like...
        [ed passEmp:emp];

        
    }
}


@end
