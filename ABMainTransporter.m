//
//  ABMainTransporter.m
//  ABTransporter
//
//  Created by Abhishek Banthia on 27/04/15.
//  Copyright (c) 2015 Abhishek Banthia. All rights reserved.
//

#import "ABMainTransporter.h"
#import "ABURLRequest.h"

@implementation ABMainTransporter

static BOOL setLogger = NO;
static ABMainTransporter *sharedTransporter = nil;

/*Commonly used strings for URL Requests*/
NSString *const ContentTypeHeaderFieldKey = @"Content-Type";
NSString *const AcceptTypHeaderFieldKey = @"Accept";
NSString *const ValueForHTTPHeaders = @"application/json";
NSString *const HTTPPOSTMethod = @"POST";
NSString *const HTTPGETMethod = @"GET";


+ (instancetype)sharedTransporter
{
    if (sharedTransporter == nil)
    {
        /*Using a thread safe pattern*/
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedTransporter = [[self alloc] init];
        });
        
    }
    
    return sharedTransporter;
}


+ (void)dataWebServicewithWebServicePath:(NSString *)path withCompletionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionBlock;
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setLogger)
    {
        methodStart = [NSDate date];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", path]];

    ABURLRequest *defaultRequest = [ABURLRequest defaultRequestWithURL:URL];
    
    if (setLogger)
    {
        NSLog(@"Web Service Path:\n%@", [NSString stringWithFormat:@"%@",path]);
    }
    
    [defaultRequest setHTTPMethod:HTTPPOSTMethod];
    [defaultRequest setValue:ValueForHTTPHeaders forHTTPHeaderField:ContentTypeHeaderFieldKey];
    [defaultRequest setValue:ValueForHTTPHeaders forHTTPHeaderField:AcceptTypHeaderFieldKey];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:defaultRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          completionBlock(data, response, error);
                                          
                                          if (setLogger)
                                          {
                                              methodFinish = [NSDate date];
                                              NSLog(@"Completion block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                          }

                                      }];
    
    [dataTask resume];
}


+ (void)uploadDataWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path withCompletionBlock:(void(^)(NSData *data, NSError *error, NSURLResponse *response))completionBlock
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setLogger)
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
    
    ABURLRequest *defaultRequest = [ABURLRequest requestWithURL:url];
    [defaultRequest setHTTPMethod:HTTPPOSTMethod];
    
    [defaultRequest setValue:ValueForHTTPHeaders forHTTPHeaderField:ContentTypeHeaderFieldKey];
    [defaultRequest setValue:ValueForHTTPHeaders forHTTPHeaderField:AcceptTypHeaderFieldKey];
    
    NSURLSessionUploadTask *uploadTask = [session
                                          uploadTaskWithRequest:defaultRequest
                                          fromData:jsonData
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error)
                                          {
                                              
                                              /* Completely removing unneccesary logic. Sending block with all the information*/
                                              
                                              completionBlock(data, error, response);
                                              
                                                  if (setLogger)
                                                  {
                                                      methodFinish = [NSDate date];
                                                      NSLog(@"Completion block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                  }
                                                  
                                                  
                                          }];
                                          
    
    [uploadTask resume];
    
}

- (void)GETWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path withCompletionBlock:(void (^)(NSData *, NSError *, NSURLResponse *))completionBlock
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setLogger)
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
    
    ABURLRequest *defaultRequest = [ABURLRequest defaultRequest];
    [defaultRequest setURL:url];
    [defaultRequest setHTTPMethod:HTTPGETMethod];
    
    [defaultRequest setValue:ValueForHTTPHeaders forHTTPHeaderField:ContentTypeHeaderFieldKey];
    [defaultRequest setValue:ValueForHTTPHeaders forHTTPHeaderField:AcceptTypHeaderFieldKey];
    
    NSURLSessionUploadTask *uploadTask = [session
                                          uploadTaskWithRequest:defaultRequest
                                          fromData:jsonData
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error)
                                          {
                                              
                                              /* Completely removing unneccesary logic. Sending block with all the information*/
                                              
                                              completionBlock(data, error, response);
                                              
                                              if (setLogger)
                                              {
                                                  methodFinish = [NSDate date];
                                                  NSLog(@"Completion block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                              }
                                              
                                              
                                          }];
    
    
    [uploadTask resume];
}

+ (void)setLogger
{
    setLogger = YES;
}




@end
