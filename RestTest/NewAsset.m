//
//  NewAsset.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "NewAsset.h"

@interface NewAsset ()
{
    NSArray *_pickerData;
}
@end

@implementation NewAsset

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = @[@"Monitor", @"Blackberry", @"Laptop", @"iPhone", @"Software"];
    
    // Connect data
    self.pickerAsset.dataSource = self;
    self.pickerAsset.delegate = self;
    
    [_pickerAsset selectRow:2 inComponent:0 animated:NO];
    
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
