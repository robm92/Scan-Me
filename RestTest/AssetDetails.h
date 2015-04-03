//
//  AssetDetails.h
//  ScanMe
//
//  Created by Rob McMorran on 29/01/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "ViewController.h"

@interface AssetDetails : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UITableView *lstAssetDetails;

@end
