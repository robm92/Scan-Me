//
//  Dashboard.m
//  ScanMe
//
//  Created by Rob McMorran on 29/01/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Dashboard.h"
#import "Department.h"
#import "Asset.h"
#import <QuartzCore/QuartzCore.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface Dashboard ()
{
    NSArray *_listData;
    NSArray *_reportData;
    NSMutableArray *tempDepartments;
    NSMutableArray *stockData;
    NSMutableArray *departments;
}
@end

@implementation Dashboard

@synthesize pieChartRight = _pieChart;
@synthesize pieChartLeft = _pieChartCopy;
@synthesize percentageLabel = _percentageLabel;
@synthesize selectedSliceLabel = _selectedSlice;
@synthesize numOfSlices = _numOfSlices;
@synthesize indexOfSlices = _indexOfSlices;
@synthesize downArrow = _downArrow;
@synthesize slices = _slices;
@synthesize sliceColors = _sliceColors;
@synthesize lblInfo,stockView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //hide other views
    stockView.hidden = YES;
    
    //initialise data
    _reportData = @[@"Spending per Department", @"Low Stock Items"];
    tempDepartments = [[NSMutableArray alloc] init];
    departments = [[NSMutableArray alloc] init];
    stockData = [[NSMutableArray alloc] init];
    //[self getDepartmentSpend];
    
    _listData = @[@"SS", @"Fin", @"Infra", @"AS", @"Sec"];
    
    // Connect data
    self.stockTable.dataSource = self;
    self.stockTable.delegate = self;
    self.dashTable.dataSource = self;
    self.dashTable.delegate = self;
    self.pieChartLeft.delegate = self;
    self.pieChartLeft.dataSource = self;
    
    self.slices = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < 5; i ++)
    {
        NSNumber *one = [NSNumber numberWithInt:rand()%600+400];
        [_slices addObject:one];
    }
    
    [self.pieChartLeft setDataSource:self];
    [self.pieChartLeft setStartPieAngle:M_PI_2];
    [self.pieChartLeft setAnimationSpeed:1.0];
    [self.pieChartLeft setLabelFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    [self.pieChartLeft setLabelRadius:80];
    [self.pieChartLeft setShowPercentage:NO];
    [self.pieChartLeft setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.3]];
    [self.pieChartLeft setPieCenter:CGPointMake(self.view.bounds.size.width/2,
                                                self.view.bounds.size.height/3)];
    [self.pieChartLeft setUserInteractionEnabled:YES];
    [self.percentageLabel.layer setCornerRadius:90];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       UIColorFromRGB(0xed5252),
                       UIColorFromRGB(0xF04141),
                       UIColorFromRGB(0xF01D1D),
                       UIColorFromRGB(0xF5C4C4),
                       UIColorFromRGB(0xF58E8E),nil];
    
    //rotate up arrow
    self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);
    
    
}

- (void)viewDidUnload
{
    [self setPieChartLeft:nil];
    [self setPieChartRight:nil];
    [self setPercentageLabel:nil];
    [self setSelectedSliceLabel:nil];
    [self setIndexOfSlices:nil];
    [self setNumOfSlices:nil];
    [self setDownArrow:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [tempDepartments removeAllObjects];
    [super viewDidAppear:animated];
    [departments removeAllObjects];
    [self getDepartmentSpend];
    [self.pieChartLeft reloadData];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int i = 0; i < 4; i++)
            [_slices addObject:@(rand()%60+20)];
        [self updateSlices];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    Department *dept = [[Department alloc] init];
    dept = [departments objectAtIndex:index];
    
    NSString *pieText = dept.CostCentre;
    NSInteger pieVal = dept.Spend;
    
    return [NSString stringWithFormat:@"%@: $%ld",pieText,pieVal];
}

- (IBAction)SliceNumChanged:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger num = self.numOfSlices.text.intValue;
    if(btn.tag == 100 && num > -10)
        num = num - ((num == 1)?2:1);
    if(btn.tag == 101 && num < 10)
        num = num + ((num == -1)?2:1);
    
    self.numOfSlices.text = [NSString stringWithFormat:@"%ld",(long)num];
}

- (IBAction)clearSlices {
    [departments removeAllObjects];
    [self getDepartmentSpend];
    [self.pieChartLeft reloadData];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int i = 0; i < 4; i++)
            [_slices addObject:@(rand()%60+20)];
        [self updateSlices];
    });
}


- (IBAction)updateSlices
{
    for(int i = 0; i < _slices.count; i ++)
    {
        [_slices replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:rand()%60+20]];
    }
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}

- (IBAction)showSlicePercentage:(id)sender {
    UISwitch *perSwitch = (UISwitch *)sender;
    [self.pieChartRight setShowPercentage:perSwitch.isOn];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return departments.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    Department *dept = [[Department alloc] init];
    dept = [departments objectAtIndex:index];
    return dept.Spend;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if(pieChart == self.pieChartRight) return nil;
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    Department *dept = [[Department alloc] init];
    dept = [departments objectAtIndex:index];
    lblInfo.text = [NSString stringWithFormat:@"%@ current spend = $%ld",dept.CostCentre,dept.Spend];
}

//number rows in list
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.dashTable)
    {
        return [_reportData count];
    }
    else if (tableView == self.stockTable)
    {
        return [stockData count];
    }
    else
        
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.dashTable)
    {
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        cell.textLabel.text = [_reportData objectAtIndex:indexPath.row];
        return cell;
    }
    else if (tableView == self.stockTable)
    {
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        Asset *asset = [[Asset alloc] init];
        asset = [stockData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %ld items in stock", asset.Asset_name,(long)asset.Asset_stock ];
        return cell;
    }
    else
        return 0;
    
}

-(void) getLowStock
{
    
    NSString *assignedAsset = [NSString stringWithFormat:@"http://77.100.69.163:8888/ords/rob/hr/Dashboard/lowStock"];
    
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
                                   asset.Asset_name = [item valueForKey:@"asset_name"];
                                   asset.Asset_stock = [[item valueForKey:@"asset_stock"]integerValue];
                                   
                                   [stockData addObject:asset];
                               }
                               
                               NSLog(@"low stock get complete");
                               [self.stockTable reloadData];
                           }];
    //release spinner animation
    [[self.view viewWithTag:12] removeFromSuperview];
}

-(void) getDepartmentSpend
{
    
    NSString *assignedAsset = [NSString stringWithFormat:@"http://77.100.69.163:8888/ords/rob/hr/Dashboard/DepartmentSpend"];
    
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
                                   Department *dept = [[Department alloc] init];
                                   dept.CostCentre = [item valueForKey:@"cost_centre"];
                                   dept.Spend = [self turnIntoNumber:[item valueForKey:@"asset_cost"]];
                                   
                                   [tempDepartments addObject:dept];
                               }
                               [self sumOfCostCentres];
                               
                               NSLog(@"dept spend");
                               [self.pieChartLeft reloadData];
                           }];
    //release spinner animation
    [[self.view viewWithTag:12] removeFromSuperview];
}
-(void) sumOfCostCentres
{
    //consolidates each department spend into an array of singular departments with total spend.
    for(int i=0;i<tempDepartments.count; i++)
    {
        Department *dept = [tempDepartments objectAtIndex:i];
        NSInteger spend = dept.Spend;
        
        for(int j=i+1;j<tempDepartments.count;j++)
        {
            Department *dept2 = [tempDepartments objectAtIndex:j];
            
            if ([dept.CostCentre isEqualToString:dept2.CostCentre])
            {
                spend = spend + dept2.Spend;
                //remove so it doesnt get used again
                [tempDepartments removeObjectAtIndex:j];
                //j-1 in response to removing object (rectifies index values)
                j=j-1;
                
            }
        }
        
        //add the object after total spend has been calculated for that department.
        dept.Spend = spend;
        [departments addObject:dept];
    }
    
}

-(NSInteger) turnIntoNumber:(NSString*) inputString
{
    // Intermediate
    NSString *numberString;
    
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    // Result.
    NSInteger result = [numberString integerValue];
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.dashTable)
    {
        if([[_reportData objectAtIndex:indexPath.row] isEqualToString:@"Low Stock Items"])
        {
            [stockData removeAllObjects];
            [self getLowStock];
            self.pieChartLeft.hidden = YES;
            self.stockView.hidden = NO;
        }
        else if ([[_reportData objectAtIndex:indexPath.row] isEqualToString:@"Spending per Department"])
        {
            self.pieChartLeft.hidden = NO;
            self.stockView.hidden = YES;
            
        }
    }
    
    
}


@end

