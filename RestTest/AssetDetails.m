//
//  AssetDetails.m
//  ScanMe
//
//  Created by Rob McMorran on 29/01/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "AssetDetails.h"
#import "Assets.h"
#import "InventoryScanner.h"

@interface AssetDetails ()
{
    NSMutableArray *_pickerData;
    NSMutableArray *_listData;
    Asset *passedAsset;
}
@end

@implementation AssetDetails
@synthesize lstAssetDetails,btnEdit,btnScan,txtCost,txtName,lblStock,typePicker;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = [[NSMutableArray alloc] init];
    _listData = [[NSMutableArray alloc] init];
    
    // Connect data
    self.typePicker.dataSource = self;
    self.typePicker.delegate = self;
    self.lstAssetDetails.dataSource = self;
    self.lstAssetDetails.delegate = self;
    
    //round corners of button
    btnEdit.layer.cornerRadius = 10;
    btnEdit.clipsToBounds = YES;
    btnScan.layer.cornerRadius = 10;
    btnScan.clipsToBounds = YES;
    
    [self getAssetSerials];
    [self getAssetTypes];
    
    
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
    
    Asset *asset = [[Asset alloc] init];
    asset = [_listData objectAtIndex:indexPath.row];
    cell.textLabel.text = asset.Asset_serial;
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

- (IBAction)btnEdit:(id)sender {
    
    if([txtName.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid input"
                                                        message:@"Please enter fields correctly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else if([txtCost.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid input"
                                                        message:@"Please enter fields correctly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        NSString *ASSET_NAME = txtName.text;
        passedAsset.Asset_name = txtName.text;
        NSString *ASSET_COST =  txtCost.text;
        passedAsset.Asset_cost = txtCost.text;
        NSString *ASSET_TYPE = [_pickerData objectAtIndex:[self.typePicker selectedRowInComponent:0]];
        passedAsset.Asset_type = ASSET_TYPE;
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:passedAsset.Asset_ID],@"ASSET_ID",ASSET_NAME,@"ASSET_NAME",ASSET_COST,@"ASSET_COST",ASSET_TYPE,@"ASSET_TYPE",0,@"ASSET_STOCK", nil];
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        [self jsonPostRequest:postData];
        //refresh data
        [_listData removeAllObjects];
        [self getAssetSerials];
        [self.view endEditing:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit complete"
                                                        message:@"Asset details edited successfuly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
}

-(id)jsonPostRequest:(NSData *)jsonRequestData
{
    //URL for the request
    NSURL *url = [NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/Assets/EditAsset"];
    //the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    NSLog(@"The Json post request: %@", request);
    
    //bind request with jsonrequestdata
    [request setHTTPMethod:@"POST"]; //n.b its a post request, not get
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonRequestData];//set jsonRequestData into body
    
    //send sync request
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"The Json post result: %@", result);
    if(error ==nil)
        return result;
    
    return nil;
    
}

- (void) passAsset:(Asset*)asset{
    passedAsset = [[Asset alloc] init];
    passedAsset = asset;
    
}
-(void) getAssetSerials
{
    
    NSString *assignedAsset = [NSString stringWithFormat:@"http://77.100.69.163:8888/ords/rob/hr/Assets/AssetSerials/%ld",(long)passedAsset.Asset_ID];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:assignedAsset]];
    
    __block NSMutableDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);//output the json dictionary raw
                               
                               NSArray * responseArr = json[@"items"];
                               
                               for(NSDictionary *item in responseArr)//for every department in the responseArr, add their respective details to the arrays
                               {
                                   Asset *asset = [[Asset alloc] init];
                                   asset.Asset_serial = [item valueForKey:@"serial"];
                                   [_listData addObject:asset];
                               }
                               //put data into ui
                               [self.lstAssetDetails reloadData];
                               txtName.text = passedAsset.Asset_name;
                               txtCost.text = passedAsset.Asset_cost;
                               lblStock.text = [NSString stringWithFormat:@"%ld",(long)passedAsset.Asset_stock];
                               
                           }];
    //release spinner animation
    [[self.view viewWithTag:12] removeFromSuperview];
}

- (void) getAssetTypes
{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/Assets/"]];
    
    __block NSMutableDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);//output the json dictionary raw
                               //make two arrays to hold the json instances sequentialy
                               
                               
                               
                               NSArray * responseArr = json[@"items"];//make an array which holds each json 'user'
                               
                               for(NSDictionary * dict in responseArr)//for every department in the responseArr, add their respective details to the arrays
                               {
                                   
                                   NSString *asset_type = [dict valueForKey:@"asset_type"];
                                   
                                   if(![_pickerData containsObject:asset_type])
                                   {
                                       [_pickerData addObject:asset_type];
                                   }
                                   
                               }
                               //reload picker to fill new data
                               [self.typePicker reloadAllComponents];
                               
                               //set the selected index of picker to that of the asset on screen
                               for(int i; i < [_pickerData count];i++)
                               {
                                   if([[_pickerData objectAtIndex:i] isEqualToString:passedAsset.Asset_type])
                                   {
                                       [typePicker selectRow:i inComponent:0 animated:NO];
                                       
                                   }
                               }
                               
                               
                           }];
    //release spinner animation
    //[[self.view viewWithTag:12] removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"scanInventory"])
    {
        // Get reference to the destination view controller
        InventoryScanner *is = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [is passAsset:passedAsset];
        
        
    }
}

- (IBAction)unwindFromScan:(UIStoryboardSegue *)unwindSegue
{
    [_listData removeAllObjects];
    [self getAssetSerials];
    [lstAssetDetails reloadData];
}


@end

