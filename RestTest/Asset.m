//
//  Asset.m
//  ScanMe
//
//  Created by Rob McMorran on 03/04/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Asset.h"

@implementation Asset

@synthesize Asset_cost,Asset_ID,Asset_name,Asset_stock,Asset_type,Asset_serial;

- (id) initWithName: (NSString *) asset_name asset_type: (NSString *) asset_type
         asset_cost: (NSString *) asset_cost asset_ID: (NSInteger) asset_ID
        asset_stock: (NSInteger ) asset_stock asset_serial: (NSString *) asset_serial;
{
    self = [super init];
    if (self)
    {
        Asset_cost = asset_cost;
        Asset_ID = asset_ID;
        Asset_name = asset_name;
        Asset_stock = asset_stock;
        Asset_type = asset_type;
        Asset_serial = asset_serial;
        
    }
    return self;
}

@end