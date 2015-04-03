//
//  IOSRequest.m
//  RestTest
//
//  Created by Rob McMorran on 20/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import "IOSRequest.h"

@implementation IOSRequest

+(void)RequestToPath:(NSString *)path onCompletion:(RequestCompletionHandler)complete
{
    
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]
                                                  cachePolicy:NSURLCacheStorageAllowedInMemoryOnly
                                              timeoutInterval:20];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         if(complete)
         {
             complete(result,error);
         }
     }];
}

@end
