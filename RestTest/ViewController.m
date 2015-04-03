//
//  ViewController.m
//  RestTest
//
//  Created by Rob McMorran on 20/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import "ViewController.h"
#import "IOSRequest.h"

#define getDataURL @"http://192.168.0.7:8888/ords/rob/hr/employees/"

@interface ViewController ()


@end

@implementation ViewController
@synthesize userArray,jsonArray,btnSignIn,lblMainTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self retrieveData];
    
    //title shadow
    UIColor *color = [UIColor blackColor];
    lblMainTitle.layer.shadowColor = [color CGColor];
    lblMainTitle.layer.shadowRadius = 1.0f;
    lblMainTitle.layer.shadowOpacity = 0.5;
    lblMainTitle.layer.shadowOffset = CGSizeZero;
    lblMainTitle.layer.masksToBounds = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//textbox minimise on return key
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) retrieveData
{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:getDataURL]];
    
    __block NSMutableDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);//output the json dictionary raw
                               //make two arrays to hold the json instances sequentialy
                               userArray=[[NSMutableArray alloc]init];
                               
                               
                               NSArray * responseArr = json[@"items"];//make an array which holds each json 'user'
                               
                               for(NSDictionary * dict in responseArr)//for every user in the responseArr, add their respective details to the arrays
                               {
                                   //User * u = [[User alloc] init];
                                   //u.Name = [dict valueForKey:@"name"];
                                   //u.Age = [dict valueForKey:@"age"];
                                   //[userArray addObject: u];
                                   
                               }
                               
                               //User * user = [[User alloc] init];
                               //user = [userArray objectAtIndex:(0)];
                               
                               //txtName.text = user.Name;
                               //txtAge.text = user.Age;
                               
                               //[self jsonPostRequest:data];
                               
                            
                           }];

}
-(void)jsonSetup
{
//    NSString *ID = @"8";
//    NSString *NAME = txtPostName.text;
//    NSString *AGE = txtPostAge.text;
//    
//    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:ID,@"ID",NAME,@"NAME",AGE,@"AGE", nil];
//    
//    NSError *error;
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
//    [self jsonPostRequest:postData];
    
    
}

-(id)jsonPostRequest:(NSData *)jsonRequestData
{
    //URL for the request
    NSURL *url = [NSURL URLWithString:getDataURL];
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

- (IBAction)btnFetch:(id)sender {
    
   [self jsonSetup];
}
@end
