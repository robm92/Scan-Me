//
//  Asset.h
//  ScanMe
//
//  Created by Rob McMorran on 03/04/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Asset : NSObject

@property (nonatomic, retain) NSNumber * Asset_ID;
@property (nonatomic, retain) NSString * Asset_name;
@property (nonatomic, retain) NSString * Asset_type;
@property (nonatomic, retain) NSString * Asset_cost;
@property (nonatomic, retain) NSString * Asset_serial;
@property (nonatomic, retain) NSNumber * Asset_stock;

- (id) initWithName: (NSString *) asset_name asset_type: (NSString *) asset_type
         asset_cost: (NSString *) asset_cost asset_ID: (NSNumber *) asset_ID
        asset_stock: (NSNumber *) asset_stock asset_serial: (NSString *) asset_serial;

@end
