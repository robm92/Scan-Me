//
//  AssetDetails.m
//  ScanMe
//
//  Created by Rob McMorran on 29/01/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "AssetDetails.h"

@interface AssetDetails ()
{
    NSArray *_pickerData;
    NSArray *_listData;
}
@end

@implementation AssetDetails
@synthesize lstAssetDetails;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = @[@"Monitor", @"Blackberry", @"Laptop", @"iPhone", @"Software"];
    _listData = @[@"SN654678", @"SN657453", @"SN887695", @"SN641089", @"SN667554"];
    
    // Connect data
    self.typePicker.dataSource = self;
    self.typePicker.delegate = self;
    self.lstAssetDetails.dataSource = self;
    self.lstAssetDetails.delegate = self;
    
   
}
//number rows in list
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_listData objectAtIndex:indexPath.row];
    return cell;
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}
@end

