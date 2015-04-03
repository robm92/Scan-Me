//
//  Assets.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Assets.h"

@interface Assets()
{
    NSArray *_assetList;
}
@end

@implementation Assets

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _assetList = @[@"Dell Monitor 24", @"Dell Monitor 22", @"Dell Laptop 13", @"Dell Laptop 15", @"Dell Laptop 17"
                      ,@"Blackberry 9900", @"Blackberry Z10", @"Blackberry Q10", @"iPhone 5s", @"iPhone 6", @"iPad Air 16gb"];
    _assetList = [_assetList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // Connect data
    self.lstAssets.dataSource = self;
    self.lstAssets.delegate = self;
    
    
}

- (IBAction)unwindToAssets:(UIStoryboardSegue *)unwindSegue
{
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIAlertView *messageAlert = [[UIAlertView alloc]
    //initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    //[messageAlert show];
    
    [self performSegueWithIdentifier:@"AssetDetailsSegue" sender:self];
    
    
}

//number rows in list
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_assetList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_assetList objectAtIndex:indexPath.row];
    return cell;
}


@end
