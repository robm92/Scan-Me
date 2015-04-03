//
//  Employee.h
//  ScanMe
//
//  Created by Rob McMorran on 11/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employee : NSObject

@property (nonatomic,strong) NSString * FirstName;
@property (nonatomic,strong) NSString * SecondName;
@property (nonatomic,assign) NSInteger DepartmentID;
@property (nonatomic,assign) NSInteger EmployeeID;


- (id) initWithName: (NSString *) firstName secondName: (NSString *) secondName
             deptID: (NSInteger *) deptID empID: (NSInteger *) empID;

- (NSString *) getName :(Employee *) employee;

@end
