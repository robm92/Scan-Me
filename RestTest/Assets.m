//
//  Assets.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "Assets.h"
#import "Asset.h"
#import "AssetDetails.h"

@interface Assets()
{
    NSMutableArray *_assetTempList;
    NSIndexPath *selectedAsset;
}
@end

@implementation Assets
@synthesize btnAdd,_assetList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //round corners of button
    btnAdd.layer.cornerRadius = 10;
    btnAdd.clipsToBounds = YES;
    
    // Initialize Data
    _assetList = [[NSMutableArray alloc] init];
    
    // Connect data
    self.lstAssets.dataSource = self;
    self.lstAssets.delegate = self;
    [self getAssets];
    
    
    
}

- (IBAction)unwindToAssets:(UIStoryboardSegue *)unwindSegue
{
    [_assetList removeAllObjects];
    [self getAssets];
    [self.lstAssets reloadData];
}

-(void) getAssets
{
    
    //start spinner animation
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    NSString *assignedAsset = [NSString stringWithFormat:@"http://77.100.69.163:8888/ords/rob/hr/Assets/"];
    
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
                                   asset.Asset_name = [item valueForKey:@"asset_name"];
                                   asset.Asset_cost = [item valueForKey:@"asset_cost"];
                                   asset.Asset_ID = [[item valueForKey:@"asset_id"]integerValue];
                                   asset.Asset_stock = [[item valueForKey:@"asset_stock"]integerValue];
                                   asset.Asset_type = [item valueForKey:@"asset_type"];
                                   [_assetList addObject:asset];
                               }
                               //sort alphabeticaly
                               NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"Asset_name" ascending:YES];
                               [_assetList sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                               [self.lstAssets reloadData];
                               //release spinner animation
                               [[self.view viewWithTag:12] removeFromSuperview];
                           }];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedAsset = indexPath;
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
    
    Asset *asset = [[Asset alloc] init];
    asset = [_assetList objectAtIndex:indexPath.row];
    cell.textLabel.text = asset.Asset_name;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"AssetDetailsSegue"])
    {
        // Get reference to the destination view controller
        AssetDetails *ad = [segue destinationViewController];
        Asset *asset = [_assetList objectAtIndex:selectedAsset.row];
        // Pass any objects to the view controller here, like...
        [ad passAsset:asset];
        
        [self.view endEditing:YES];
        self.txtSearch.text = @"Search Assets";
        [_assetList removeAllObjects];
        [self getAssets];
        [self.lstAssets reloadData];
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //every time the search field is changed, the value is stored in searchStr
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //if string is empty, reload the list
    if([searchStr  isEqual: @""])
    {
        [_assetList removeAllObjects];
        [self getAssets];
        [self.lstAssets reloadData];
    }
    
    _assetTempList = [NSMutableArray arrayWithArray:_assetList];
    [_assetList removeAllObjects];
    
    //search the array with the string from text box
    for(Asset * asset in _assetTempList)
    {
        //allows substring search
        NSString *regEx = [NSString stringWithFormat:@".*%@.*", searchStr];
        NSRange rangeFirst = [[asset.Asset_name lowercaseString] rangeOfString:regEx options:NSRegularExpressionSearch];
        if (rangeFirst.location != NSNotFound) {
            [_assetList addObject:asset];
        }
    }
    
    //repopulate with search result
    [self.lstAssets reloadData];
    
    return YES;
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing: (UITextField *) textField {
    textField.text = @"";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        //get the Asset from list using indexpath
        
        selectedAsset = indexPath;
        
        [self performSelector:@selector(hideDeleteButton:) withObject:nil afterDelay:0.1];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Asset" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        
        Asset *asset = [_assetList objectAtIndex:selectedAsset.row];
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:asset.Asset_ID],@"ASSET_ID", nil];
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        
        //URL for the request
        NSURL *url = [NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/Assets/AssetRemove/"];
        //the request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
        NSLog(@"The Json post request: %@", request);
        
        //bind request with jsonrequestdata
        [request setHTTPMethod:@"POST"]; //n.b its a post request, not get
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];//set jsonRequestData into body
        
        //send sync request
        NSURLResponse *response = nil;
        
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"The Json post result: %@", result);
        
        [_assetList removeAllObjects];
        [self getAssets];
        [self.lstAssets reloadData];
    }
    
}

- (void)hideDeleteButton:(id)obj
{
    [self.lstAssets setEditing:NO animated:YES];
}





@end
