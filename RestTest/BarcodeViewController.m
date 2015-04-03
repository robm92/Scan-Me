

#import <AVFoundation/AVFoundation.h>
#import "BarcodeViewController.h"
#define employeePOST @"http://77.100.69.163:8888/ords/rob/hr/employees/addasset"
#import "Assets.h"

@interface BarcodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
    NSMutableArray *scanResult;
    BOOL scanComplete;
    AVAudioPlayer *_audioPlayer;
    BOOL result;
}
@end

@implementation BarcodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scanComplete = NO;
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/beep.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    CGFloat tabBarTop = [[[self tabBarController] tabBar] frame].origin.y;
    _label.frame = CGRectMake(0, tabBarTop - 40 , self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(no barcode found)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil && scanComplete == NO)
        {
            _label.text = detectionString;
             [scanResult addObject:detectionString];
            [_audioPlayer play];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            scanComplete = YES;
            
            //if the serial exists
            if([self checkIfCreated:detectionString])
            {
                //if serial is assigned to someone already
                if([self checkIfAlreadyAssigned:detectionString])
                {
                    NSArray *stack = self.tabBarController.viewControllers;
                    Assets *assets = stack[stack.count-1];
                    
                    //unwind segue before changing tab - tidy up
                    [self performSegueWithIdentifier:@"UnwindToEmployeeDetails" sender:self];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset already assigned"
                                                                    message:@"This asset already belongs to someone. Unassign it before assigning it to another user"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                else
                //if it exists but has not been assigned to someone
                [self assignAsset:detectionString];
            }
            
            else{
                //serial does not exist so must be added first.
                NSArray *stack = self.tabBarController.viewControllers;
                Assets *assets = stack[stack.count-1];
                
                //unwind segue before changing tab - tidy up
                [self performSegueWithIdentifier:@"UnwindToEmployeeDetails" sender:self];
                
                [self.tabBarController setSelectedIndex:1];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset not found"
                                                                message:@"Asset must be added before being assigned"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }
        else if (detectionString == nil)
            _label.text = @"(Barcode not yet found)";
    }
    
    _highlightView.frame = highlightViewRect;
}
-(BOOL) checkIfCreated:(NSString*) detectionString
{

    //checks if the serial number exists already

    result = NO;
    
    NSMutableDictionary *json;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:employeePOST]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    //getting the data
    NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //json parse
    NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    json = [NSJSONSerialization JSONObjectWithData:newData
                                           options:0
                                             error:nil];
    NSLog(@"Async JSON: %@", json);//output the json dictionary raw
    
    NSArray * responseArr = json[@"items"];
    
    for(NSDictionary * dict in responseArr)//check serial against existing serials
    {
        NSString * serial = [dict valueForKey:@"serial"];
        
        if([detectionString isEqualToString:serial])
        {
            result = YES;
        }
    }
    
    return result;
}

-(BOOL) checkIfAlreadyAssigned:(NSString*) detectionString
{
    
    //checks if the item has already been assigned to someone
    
    result = NO;
    
    NSMutableDictionary *json;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://77.100.69.163:8888/ords/rob/hr/employees/SerialCheck"]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    //getting the data
    NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //json parse
    NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    json = [NSJSONSerialization JSONObjectWithData:newData
                                           options:0
                                             error:nil];
    NSLog(@"Async JSON: %@", json);//output the json dictionary raw
    
    NSArray * responseArr = json[@"items"];
    
    for(NSDictionary * dict in responseArr)//check serial against existing serials
    {
        NSString * serial = [dict valueForKey:@"serial"];
        
        if([detectionString isEqualToString:serial])
        {
            result = YES;
        }
    }
    
    return result;
}

- (void) assignAsset:(NSString*) detectionString
{
    //debug only - change to selected employee!
    NSInteger selectedEmployee = 71;
    
    //create a dictionary with employee ID and the serial obtained from scan.
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:selectedEmployee],@"EMP_ID",detectionString,@"SERIAL",[NSNumber numberWithInteger:1],@"QUANTITY", nil];
    
    NSError *error;
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    //URL for the request
    NSURL *url = [NSURL URLWithString:employeePOST];
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
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"The Json post result: %@", response);

    //when done, go back to employee details
    [self performSegueWithIdentifier:@"UnwindToEmployeeDetails" sender:self];
}

@end