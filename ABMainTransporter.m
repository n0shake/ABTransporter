//
//  ABMainTransporter.m
//  ABTransporter
//
//  Created by Abhishek Banthia on 27/04/15.
//  Copyright (c) 2015 Abhishek Banthia. All rights reserved.
//

#import "ABMainTransporter.h"

@implementation ABMainTransporter

@synthesize executionSelector;
@synthesize interfaceSelector;
@synthesize errorSelector;

static  BOOL setResponseLogger = NO;
static BOOL setTimeInfoLogger = NO;
static BOOL setLogger = NO;

/*Commonly used strings for URL Requests*/
NSString *const ContentTypeHeaderFieldKey = @"Content-Type";
NSString *const AcceptTypHeaderFieldKey = @"Accept";
NSString *const ValueForHTTPHeaders = @"application/json";
NSString *const HTTPMethod = @"POST";


+ (void)dataWebServicewithWebServicePath:(NSString *)path bySender:(id)sender withCompletionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionBlock;
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setTimeInfoLogger || setLogger)
    {
        methodStart = [NSDate date];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", path]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setTimeoutInterval:20];
    
    if (setLogger)
    {
        NSLog(@"Web Service Path:\n%@", [NSString stringWithFormat:@"%@",path]);
    }
    
    [request setHTTPMethod:HTTPMethod];
    [request setValue:ValueForHTTPHeaders forHTTPHeaderField:ContentTypeHeaderFieldKey];
    [request setValue:ValueForHTTPHeaders forHTTPHeaderField:AcceptTypHeaderFieldKey];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          completionBlock(data, response, error);
                                          
                                          if (setTimeInfoLogger || setLogger)
                                          {
                                              methodFinish = [NSDate date];
                                              NSLog(@"Completion block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                          }

                                      }];
    
    [dataTask resume];
}


+ (void)uploadDataWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path bySender:(id)sender withCompletionBlock:(void(^)(NSData *data, NSError *error, NSURLResponse *response))completionBlock
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setTimeInfoLogger || setLogger)
    {
        methodStart = [NSDate date];
    }
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 20;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:inputDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", path]];
    
    if (setLogger)
    {
        NSLog(@"Input Dictionary:\n%@", inputDictionary);
        NSLog(@"Web Service Path:\n%@", [NSString stringWithFormat:@"%@", path]);
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:HTTPMethod];
    
    [request setValue:ValueForHTTPHeaders forHTTPHeaderField:ContentTypeHeaderFieldKey];
    [request setValue:ValueForHTTPHeaders forHTTPHeaderField:AcceptTypHeaderFieldKey];
    
    NSURLSessionUploadTask *uploadTask = [session
                                          uploadTaskWithRequest:request
                                          fromData:jsonData
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error)
                                          {
                                              
                                              /* Completely removing unneccesary logic. Sending block with all the information*/
                                              
                                              completionBlock(data, error, response);
                                              
                                                  if (setTimeInfoLogger || setLogger)
                                                  {
                                                      methodFinish = [NSDate date];
                                                      NSLog(@"Completion block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                  }
                                                  
                                                  
                                          }];
                                          
    
    [uploadTask resume];

}


+ (void)setTimeLogger
{
    setTimeInfoLogger = YES;
}

+ (void)setResponseLogger
{
    setResponseLogger = YES;
}

+ (void)setLogger
{
    setLogger = YES;
}

@end
