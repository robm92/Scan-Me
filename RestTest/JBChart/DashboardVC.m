//
//  DashboardVC.m
//  ScanMe
//
//  Created by Rob McMorran on 08/04/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "DashboardVC.h"
#import "Department.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DashboardVC ()
{
    NSMutableArray *tempDepartments;
    NSMutableArray *departments;
    
    JBChartHeaderView *headerView;
}


@end

@implementation DashboardVC

@synthesize barChart;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tempDepartments = [[NSMutableArray alloc] init];
    departments = [[NSMutableArray alloc] init];
    
    [self getDepartmentSpend];
    
    barChart.backgroundColor = UIColorFromRGB(0xFFFFFF);
    barChart.delegate = self;
    barChart.dataSource = self;
    barChart.minimumValue = 0;
    barChart.maximumValue = 100;
    
    //add footer, header
    
    [barChart reloadData];
    [barChart setState:JBChartViewStateCollapsed animated:YES];
    
    headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(0,0,self.barChart.bounds.size.height *0.2,self.barChart.bounds.size.width * 0.2)];
    headerView.titleLabel.text = @"Spending per Department";
    headerView.subtitleLabel.text = @"";
    self.barChart.headerView = headerView;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [barChart reloadData];
    
    [barChart setState:JBChartViewStateExpanded animated:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    //hide chart?
}

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return departments.count;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    Department *dept = [[Department alloc] init];
    dept = [departments objectAtIndex:index];
    return (CGFloat)dept.Spend;
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return(index % 2 == 0) ? UIColorFromRGB(0xed5252) : UIColorFromRGB(0xE8A0A0);
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    Department *dept = [[Department alloc] init];
    dept = [departments objectAtIndex:index];
    
    //headerView.subtitleLabel.text = [NSString stringWithFormat:@"%@ - %ld",dept.CostCentre,dept.Spend];
    //self.barChart.headerView = headerView;
    
}

- (void)didDeselectBarChartView:(JBBarChartView *)barChartView
{
    // Update view
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
                               [barChart reloadData];
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
