//
//  AssetDetails.h
//  ScanMe
//
//  Created by Rob McMorran on 29/01/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "ViewController.h"
#import "Asset.h"

@interface AssetDetails : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UITableView *lstAssetDetails;
- (IBAction)btnEdit:(id)sender;
- (void) passAsset:(Asset*)asset;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnScan;
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UILabel *lblStock;
@property (strong, nonatomic) IBOutlet UITextField *txtCost;

@end
