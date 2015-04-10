//
//  DashboardVC.h
//  ScanMe
//
//  Created by Rob McMorran on 08/04/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBChartView.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"
#import "JBBarChartFooterView.h"
#import "JBChartHeaderView.h"

@interface DashboardVC : UIViewController <JBBarChartViewDelegate, JBBarChartViewDataSource>
@property (weak, nonatomic) IBOutlet JBBarChartView *barChart;

@end
