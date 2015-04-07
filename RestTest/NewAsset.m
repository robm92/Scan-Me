//
//  NewAsset.m
//  ScanMe
//
//  Created by Rob McMorran on 01/02/2015.
//  Copyright (c) 2015 Rob McMorran. All rights reserved.
//

#import "NewAsset.h"
#import "Asset.h"

@interface NewAsset ()
{
    NSMutableArray *_pickerData;
}
@end

@implementation NewAsset
@synthesize btnAdd,typePicker,txtCost,txtName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = [[NSMutableArray alloc] init];
    
    // Connect data
    self.pickerAsset.dataSource = self;
    self.pickerAsset.delegate = self;
    
    //round corners of button
    btnAdd.layer.cornerRadius = 10;
    btnAdd.clipsToBounds = YES;
    
    [self getAssetTypes];
    
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
                               
                           }];
    
}


- (IBAction)btnAdd:(id)sender {
    
    NSString *ASSET_NAME = txtName.text;
    NSString *ASSET_COST =  txtCost.text;
    
    NSString *ASSET_TYPE = [_pickerData objectAtIndex:[self.pickerAsset selectedRowInComponent:0]];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:ASSET_NAME,@"ASSET_NAME",ASSET_COST,@"ASSET_COST",ASSET_TYPE,@"ASSET_TYPE",0,@"ASSET_STOCK", nil];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [self jsonPostRequest:postData];
    
}

-(id)jsonPostRequest:(NSData *)jsonRequestData
{
    //URL for the request
    NSURL *url = [NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/Assets/"];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
