//
//  InventoryScanner.h
//  RestTest
//
//  Created by Rob McMorran on 30/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Asset.h"

@interface InventoryScanner : UIViewController

@property NSMutableArray *scanResult;
- (void) passAsset:(Asset*)asset;

@end
