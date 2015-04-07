//
//  Department.m
//  ScanMe
//
//  Created by Rob McMorran on 17/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Department.h"

@implementation Department

@synthesize Name,DeptID,CostCentre,Spend;

- (id) initWithName: (NSString *) name costCentre: (NSString *) costCentre
             deptID: (NSInteger *) deptID spend: (NSInteger *) spend;
{
    self = [super init];
    if (self)
    {
        Name = name;
        DeptID = *deptID;
        CostCentre = costCentre;
        Spend = *spend;
    }
    return self;
}

@end
