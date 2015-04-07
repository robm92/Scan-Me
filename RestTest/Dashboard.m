//
//  Dashboard.m
//  ScanMe
//
//  Created by Rob McMorran on 29/01/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Dashboard.h"
#import "Department.h"
#import <QuartzCore/QuartzCore.h>

@interface Dashboard ()
{
    NSArray *_listData;
    NSArray *_reportData;
    NSMutableArray *tempDepartments;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialise data
    _listData = @[@"SS", @"Fin", @"Infra", @"AS", @"Sec"];
    _reportData = @[@"Spending per Department", @"Low Stock Items"];
    tempDepartments = [[NSMutableArray alloc] init];
    departments = [[NSMutableArray alloc] init];
    // Connect data
    self.dashTable.dataSource = self;
    self.dashTable.delegate = self;

    self.slices = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < 5; i ++)
    {
        NSNumber *one = [NSNumber numberWithInt:rand()%600+400];
        [_slices addObject:one];
    }
    
    [self.pieChartLeft setDataSource:self];
    [self.pieChartLeft setStartPieAngle:M_PI_2];
    [self.pieChartLeft setAnimationSpeed:1.0];
    [self.pieChartLeft setLabelFont:[UIFont fontWithName:@"Arial" size:14]];
    [self.pieChartLeft setLabelRadius:80];
    [self.pieChartLeft setShowPercentage:NO];
    [self.pieChartLeft setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.3]];
    [self.pieChartLeft setPieCenter:CGPointMake(self.view.bounds.size.width/2,
                                                self.view.bounds.size.height/3)];
    [self.pieChartLeft setUserInteractionEnabled:YES];
    [self.pieChartLeft setLabelShadowColor:[UIColor blackColor]];
    
    [self.percentageLabel.layer setCornerRadius:90];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:1],nil];
    
    //rotate up arrow
    self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);
    
    [self getDepartmentSpend];
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
    [super viewDidAppear:animated];
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
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
    NSString *pieText = [_listData objectAtIndex:index];
    int pieVal = [[self.slices objectAtIndex:index] intValue];
    
    return [NSString stringWithFormat:@"%@: $%d",pieText,pieVal];
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
    [_slices removeAllObjects];
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}

- (IBAction)addSliceBtnClicked:(id)sender
{
    NSInteger num = [self.numOfSlices.text intValue];
    if (num > 0) {
        for (int n=0; n < abs(num); n++)
        {
            NSNumber *one = [NSNumber numberWithInt:rand()%60+20];
            NSInteger index = 0;
            if(self.slices.count > 0)
            {
                switch (self.indexOfSlices.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.slices.count;
                        break;
                    case 2:
                        index = self.slices.count - 1;
                        break;
                }
            }
            [_slices insertObject:one atIndex:index];
        }
    }
    else if (num < 0)
    {
        if(self.slices.count <= 0) return;
        for (int n=0; n < abs(num); n++)
        {
            NSInteger index = 0;
            if(self.slices.count > 0)
            {
                switch (self.indexOfSlices.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.slices.count;
                        break;
                    case 2:
                        index = self.slices.count - 1;
                        break;
                }
                [_slices removeObjectAtIndex:index];
            }
        }
    }
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
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
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if(pieChart == self.pieChartRight) return nil;
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %d",index);
    self.selectedSliceLabel.text = [NSString stringWithFormat:@"$%@",[self.slices objectAtIndex:index]];
}

//number rows in list
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_reportData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_reportData objectAtIndex:indexPath.row];
    return cell;
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
                           }];
    //release spinner animation
    [[self.view viewWithTag:12] removeFromSuperview];
}
-(void) sumOfCostCentres
{
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
                [tempDepartments removeObjectAtIndex:j];
                
            }
        }
        
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


@end

