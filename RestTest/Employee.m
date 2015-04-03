//
//  Employee.m
//  ScanMe
//
//  Created by Rob McMorran on 11/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Employee.h"

@implementation Employee

@synthesize FirstName,SecondName,EmployeeID,DepartmentID;

- (id) initWithName: (NSString *) firstName secondName: (NSString *) secondName
             deptID: (NSInteger *) deptID empID: (NSInteger *) empID;
{
    self = [super init];
    if (self)
    {
        FirstName = firstName;
        SecondName = secondName;
        DepartmentID = *deptID;
        EmployeeID = *empID;
    }
    return self;
}

- (NSString *) getName :(Employee *) employee
{
    return [NSString stringWithFormat:@"%@ %@", employee.FirstName, employee.SecondName];
}

@end
