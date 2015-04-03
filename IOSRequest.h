//
//  IOSRequest.h
//  RestTest
//
//  Created by Rob McMorran on 20/10/2014.
//  Copyright (c) 2014 Rob McMorran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestCompletionHandler)(NSString*,NSError*);

@interface IOSRequest : NSObject
+(void)RequestToPath:(NSString *)path onCompletion:(RequestCompletionHandler)complete;



@end
