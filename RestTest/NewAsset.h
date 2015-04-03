//
//  NewAsset.h
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAsset : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerAsset;
@end
