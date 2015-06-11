//
//  ABURLRequest.m
//  ABTransporter
//
//  Created by Abhishek Banthia on 11/06/15.
//  Copyright (c) 2015 Abhishek Banthia. All rights reserved.
//

#import "ABURLRequest.h"

static ABURLRequest *defaultRequest = nil;

@implementation ABURLRequest

+ (instancetype)defaultRequest
{
    if (defaultRequest == nil)
    {
        /*Using a thread safe pattern*/
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultRequest = [[self alloc] init];
        });
        
    }
    
    return defaultRequest;
}

+(instancetype)defaultRequestWithURL:(NSURL *)url
{
    defaultRequest = [self defaultRequest];
    
    [defaultRequest setURL:url];
    
    return defaultRequest;
}

@end
