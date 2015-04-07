//
//  Assets.h
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Assets : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *lstAssets;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) NSMutableArray *_assetList;
-(void) getAssets;

@end
