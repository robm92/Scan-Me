//
//  Department.h
//  ScanMe
//
//  Created by Rob McMorran on 17/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Department : NSObject

@property (nonatomic,strong) NSString * Name;
@property (nonatomic,assign) NSInteger DeptID;
@property (nonatomic,strong) NSString * CostCentre;
@property (nonatomic,assign) NSInteger Spend;


- (id) initWithName: (NSString *) name costCentre: (NSString *) costCentre
             deptID: (NSInteger *) deptID spend: (NSInteger *) spend;

@end
