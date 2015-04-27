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
NSString *const BDAContentTypeHeaderFieldKey = @"Content-Type";
NSString *const BDAAcceptTypHeaderFieldKey = @"Accept";
NSString *const BDAValueForHTTPHeaders = @"application/json";
NSString *const BDAHTTPMethod = @"POST";

/*Web Service common response keys*/
NSString *const BDAWebServiceResponseStatus = @"status";
NSString *const BDAWebServiceResponse = @"response";
NSString *const BDAWebServiceResponseMessage = @"message";

/*The reason for this warning is that with ARC, the runtime needs to know what to do with the result of the method you're calling.*/

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


+ (void)uploadDataWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path bySender:(id)sender withUICompletionMethodName:(NSString *)selector andExecutionMethodCompletionName:(NSString *)executionSelector
{
    
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setTimeInfoLogger || setLogger)
    {
        methodStart = [NSDate date];
    }
    
    __block NSDictionary *responseDictionary = [NSDictionary dictionary];
    
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
        NSLog(@"UI Completion Method:\n%@", selector);
        NSLog(@"Web Service Completion Method:\n%@", executionSelector);
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:BDAHTTPMethod];
    
    [request setValue:BDAValueForHTTPHeaders forHTTPHeaderField:BDAContentTypeHeaderFieldKey];
    [request setValue:BDAValueForHTTPHeaders forHTTPHeaderField:BDAAcceptTypHeaderFieldKey];
    
    NSURLSessionUploadTask *uploadTask = [session
                                          uploadTaskWithRequest:request
                                          fromData:jsonData
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error)
                                          {
                                              
                                              /*Check if any error. If nil then proceed*/
                                              if (error == nil)
                                              {
                                                  responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                  NSString *message = [[responseDictionary objectForKey:BDAWebServiceResponse] objectForKey:BDAWebServiceResponseMessage];
                                                  NSNumber *status = [[responseDictionary objectForKey:BDAWebServiceResponse] objectForKey:BDAWebServiceResponseStatus];
                                                  
                                                  if (setResponseLogger || setLogger)
                                                  {
                                                      NSLog(@"WS method response:%@", responseDictionary);
                                                  }
                                                  
                                                  if (responseDictionary == nil)
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          NSLog(@"No Response Received");
                                                      });
                                                      
                                                      
                                                      return;
                                                  }
                                                  
                                                  /*Check if status is BDAWebServiceSucess. If success, then proceed*/
                                                  if (status.integerValue == WebServiceSuccess)
                                                  {
                                                      
                                                      if([sender respondsToSelector:NSSelectorFromString(executionSelector)] &&
                                                         [executionSelector length] > 0)
                                                      {
                                                          SuppressPerformSelectorLeakWarning
                                                          (
                                                           [sender performSelector: NSSelectorFromString(executionSelector) withObject:responseDictionary];
                                                           );
                                                          
                                                          if (setTimeInfoLogger || setLogger)
                                                          {
                                                              methodFinish = [NSDate date];
                                                              NSLog(@"WS method completed in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                          }
                                                          
                                                      }
                                                      else if([executionSelector length] > 0 && ![sender respondsToSelector:NSSelectorFromString(executionSelector)])
                                                      {
                                                          [NSException raise:[NSString stringWithFormat:@"%@ must implement the specified:%@", sender, executionSelector]format:@"Web Service Completion method not implemented"];
                                                      }
                                                      
                                                      if([selector length] > 0 && [sender respondsToSelector:NSSelectorFromString(selector)])
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              
                                                              SuppressPerformSelectorLeakWarning
                                                              (
                                                               [sender performSelector: NSSelectorFromString(selector) withObject:message];
                                                               );
                                                              
                                                              if (setTimeInfoLogger || setLogger)
                                                              {
                                                                  methodFinish = [NSDate date];
                                                                  NSLog(@"UI method completed in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                              }
                                                          });
                                                      
                                                      else if([selector length] > 0 && ![sender respondsToSelector:NSSelectorFromString(selector)])
                                                      {
                                                          [NSException raise:[NSString stringWithFormat:@"%@ must implement the specified:%@", sender, selector]format:@"UI Completion method not implemented"];
                                                      }
                                                      
                                                  }
                                                  /*WebService has returned BDAWebServiceFailed. Show message.*/
                                                  else if (status.integerValue == WebServiceFailed)
                                                  {
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          NSLog(@"%@", message);
                                                      });
                                                      
                                                      if (setLogger || setTimeInfoLogger)
                                                      {
                                                          methodFinish = [NSDate date];
                                                          NSLog(@"Web Service error block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                      }
                                                      
                                                  }
                                              }
                                              /*Error is not nil. Show error*/
                                              else
                                              {
                                                  NSInteger errorCode = [[[error userInfo] objectForKey:@"NSUnderlyingError"] code];
                                                  
                                                  NSString *errorString;
                                                  
                                                  switch (errorCode)
                                                  {
                                                      case NSURLErrorCannotFindHost:
                                                          errorString = @"Cannot Find Host!";
                                                          break;
                                                          
                                                      case NSURLErrorNotConnectedToInternet:
                                                          errorString = @"No Internet!";
                                                          break;
                                                          
                                                      case NSURLErrorTimedOut:
                                                          errorString = @"Request Timed Out!";
                                                          break;
                                                          
                                                      default:
                                                          errorString = @"Other error";
                                                          break;
                                                  }
                                                  
                                                  [uploadTask cancel];
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if (errorCode == NSURLErrorTimedOut ||
                                                          errorCode == NSURLErrorNotConnectedToInternet ||
                                                          errorCode == NSURLErrorCannotFindHost)
                                                      {
                                                          
                                                          if (NSClassFromString(@"UIAlertController"))
                                                          {
                                                              UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:errorString
                                                                                                                                  message:nil
                                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                                              
                                                              UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                                                  [self uploadDataWebServiceWithInputDictionary:inputDictionary
                                                                                              andWebServicePath:path
                                                                                                       bySender:sender
                                                                                     withUICompletionMethodName:selector
                                                                               andExecutionMethodCompletionName:executionSelector];
                                                                  
                                                              }];
                                                              
                                                              UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                                                              
                                                              [errorAlert addAction:cancelAction];
                                                              [errorAlert addAction:retryAction];
                                                              
                                                              [sender presentViewController:errorAlert animated:YES completion:nil];
                                                          }
                                                          else
                                                          {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Timed Out"
                                                                                                              message:nil
                                                                                                             delegate:self
                                                                                                    cancelButtonTitle:@"Cancel"
                                                                                                    otherButtonTitles:@"Retry", nil];
                                                              alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                                                              
                                                              [alert show];
                                                          }
                                                      }
                                                      else
                                                      {
                                                          NSLog(@"Error:%@", error);
                                                      }
                                                      
                                                  });
                                                  
                                                  if (setTimeInfoLogger || setLogger)
                                                  {
                                                      methodFinish = [NSDate date];
                                                      NSLog(@"NSError block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                  }
                                                  
                                                  
                                              }
                                          }];
    
    [uploadTask resume];
}

+ (void)dataWebServicewithWebServicePath:(NSString *)path bySender:(id)sender withUICompletionMethodName:(NSString *)selector andExecutionMethodCompletionName:(NSString *)executionSelector
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setTimeInfoLogger || setLogger)
    {
        methodStart = [NSDate date];
    }
    
    __block NSDictionary *responseDictionary = [NSDictionary dictionary];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", path]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setTimeoutInterval:20];
    
    if (setLogger)
    {
        NSLog(@"Web Service Path:\n%@", [NSString stringWithFormat:@"%@",path]);
        NSLog(@"UI Completion Method:\n%@", selector);
        NSLog(@"Web Service Completion Method:\n%@", executionSelector);
    }
    
    [request setHTTPMethod:BDAHTTPMethod];
    [request setValue:BDAValueForHTTPHeaders forHTTPHeaderField:BDAContentTypeHeaderFieldKey];
    [request setValue:BDAValueForHTTPHeaders forHTTPHeaderField:BDAAcceptTypHeaderFieldKey];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          /*Check if any error. If nil then proceed*/
                                          if (error == nil)
                                          {
                                              responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSString *message = [[responseDictionary objectForKey:BDAWebServiceResponse] objectForKey:BDAWebServiceResponseMessage];
                                              NSNumber *status = [[responseDictionary objectForKey:BDAWebServiceResponse] objectForKey:BDAWebServiceResponseStatus];
                                              
                                              if (setResponseLogger || setLogger)
                                              {
                                                  NSLog(@"WS method response:%@", responseDictionary);
                                              }
                                              
                                              if (responseDictionary == nil)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      NSLog(@"No Response Recieved");
                                                  });
                                                  
                                                  return;
                                              }
                                              
                                              /*Check if status is BDAWebServiceSucess. If success, then proceed*/
                                              if (status.integerValue == WebServiceSuccess)
                                              {
                                                  if([sender respondsToSelector:NSSelectorFromString(executionSelector)] &&
                                                     [executionSelector length] > 1)
                                                  {
                                                      SuppressPerformSelectorLeakWarning
                                                      (
                                                       [sender performSelector: NSSelectorFromString(executionSelector) withObject:responseDictionary];
                                                       );
                                                      
                                                      if (setTimeInfoLogger || setLogger)
                                                      {
                                                          methodFinish = [NSDate date];
                                                          NSLog(@"WS method completed in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                      }
                                                  }
                                                  else if([executionSelector length] > 0 && ![sender respondsToSelector:NSSelectorFromString(executionSelector)])
                                                  {
                                                      [NSException raise:[NSString stringWithFormat:@"%@ must implement the specified:%@", sender, executionSelector]format:@"Web Service Completion method not implemented"];
                                                  }
                                                  
                                                  if([selector length] > 0 && [sender respondsToSelector:NSSelectorFromString(selector)])
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          SuppressPerformSelectorLeakWarning
                                                          (
                                                           [sender performSelector: NSSelectorFromString(selector) withObject:message];
                                                           );
                                                          
                                                          if (setTimeInfoLogger || setLogger)
                                                          {
                                                              methodFinish = [NSDate date];
                                                              NSLog(@"UI method completed in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                          }
                                                          
                                                      });
                                                  
                                                  else if([selector length] > 0 && ![sender respondsToSelector:NSSelectorFromString(selector)])
                                                  {
                                                      [NSException raise:[NSString stringWithFormat:@"%@ must implement the specified:%@", sender, selector]format:@"UI Completion method not implemented"];
                                                  }
                                                  
                                              }
                                              /*WebService has returned BDAWebServiceFailed. Show message.*/
                                              else if (status.integerValue == WebServiceFailed)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      NSLog(@"Message:%@", message);
                                                  });
                                                  
                                                  if (setLogger || setTimeInfoLogger)
                                                  {
                                                      methodFinish = [NSDate date];
                                                      NSLog(@"Web Service error block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                  }
                                              }
                                          }
                                          /*Error is not nil. Show error*/
                                          else
                                          {
                                              NSInteger errorCode = [[[error userInfo] objectForKey:@"NSUnderlyingError"] code];
                                              NSString *errorString;
                                              
                                              switch (errorCode)
                                              {
                                                  case NSURLErrorCannotFindHost:
                                                      errorString = @"Cannot Find Host!";
                                                      break;
                                                      
                                                  case NSURLErrorNotConnectedToInternet:
                                                      errorString = @"No Internet!";
                                                      break;
                                                      
                                                  case NSURLErrorTimedOut:
                                                      errorString = @"Request Timed Out!";
                                                      break;
                                                      
                                                  default:
                                                      errorString = @"Other error";
                                                      break;
                                              }
                                              
                                              [dataTask cancel];
                                              
                                              dispatch_async(dispatch_get_main_queue(),
                                                             ^{
                                                                 
                                                                 if (errorCode == NSURLErrorTimedOut ||
                                                                     errorCode == NSURLErrorNotConnectedToInternet ||
                                                                     errorCode == NSURLErrorCannotFindHost)
                                                                 {
                                                                     if (NSClassFromString(@"UIAlertController"))
                                                                     {
                                                                         UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:errorString
                                                                                                                                             message:nil
                                                                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                                                         
                                                                         UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry"
                                                                                                                               style:UIAlertActionStyleDefault
                                                                                                                             handler:^(UIAlertAction *action)
                                                                                                       {
                                                                                                           [self dataWebServicewithWebServicePath:path
                                                                                                                                         bySender:sender
                                                                                                                       withUICompletionMethodName:selector
                                                                                                                 andExecutionMethodCompletionName:executionSelector];
                                                                                                           
                                                                                                       }];
                                                                         
                                                                         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                                                                         
                                                                         [errorAlert addAction:cancelAction];
                                                                         [errorAlert addAction:retryAction];
                                                                         
                                                                         [sender presentViewController:errorAlert animated:YES completion:nil];
                                                                     }
                                                                     else
                                                                     {
                                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Timed Out"
                                                                                                                         message:nil
                                                                                                                        delegate:self
                                                                                                               cancelButtonTitle:@"Cancel"
                                                                                                               otherButtonTitles:@"Retry", nil];
                                                                         alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                                                                         
                                                                         [alert show];
                                                                     }
                                                                     
                                                                 }
                                                                 else
                                                                 {
                                                                     NSLog(@"Error:%@", error);
                                                                 }
                                                                 
                                                             });
                                              
                                              if (setTimeInfoLogger || setLogger)
                                              {
                                                  methodFinish = [NSDate date];
                                                  NSLog(@"NSError block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                              }
                                          }
                                      }];
    
    [dataTask resume];
}

- (void)errorHandlingUploadWebServicewithInput:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path bySender:(id)sender;
{
    __block NSDate *methodStart;
    __block NSDate *methodFinish;
    
    if (setTimeInfoLogger || setLogger)
    {
        methodStart = [NSDate date];
    }
    
    __block NSDictionary *responseDictionary = [NSDictionary dictionary];
    
    NSMutableDictionary *errorDictionary = [[NSMutableDictionary alloc] init];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:inputDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", path]];
    
    if (setLogger)
    {
        NSLog(@"Web Service Path:\n%@", [NSString stringWithFormat:@"%@",path]);
        NSLog(@"UI Completion Method:\n%@", self.interfaceSelector);
        NSLog(@"Web Service Completion Method:\n%@", executionSelector);
    }
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:BDAHTTPMethod];
    [request setTimeoutInterval:20];
    
    [request setValue:BDAValueForHTTPHeaders forHTTPHeaderField:BDAContentTypeHeaderFieldKey];
    [request setValue:BDAValueForHTTPHeaders forHTTPHeaderField:BDAAcceptTypHeaderFieldKey];
    
    NSURLSessionUploadTask *uploadTask = [session
                                          uploadTaskWithRequest:request
                                          fromData:jsonData
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error)
                                          {
                                              /*Check if any error. If nil then proceed*/
                                              if (error == nil)
                                              {
                                                  responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                  NSString *message = [[responseDictionary objectForKey:BDAWebServiceResponse] objectForKey:BDAWebServiceResponseMessage];
                                                  NSNumber *status = [[responseDictionary objectForKey:BDAWebServiceResponse] objectForKey:BDAWebServiceResponseStatus];
                                                  
                                                  if (setResponseLogger || setLogger)
                                                  {
                                                      NSLog(@"WS method response:%@", responseDictionary);
                                                  }
                                                  
                                                  if (responseDictionary == nil)
                                                  {
                                                     NSLog(@"No response recieved");
                                                     return;
                                                  }
                                                  
                                                  /*Check if status is BDAWebServiceSucess. If success, then proceed*/
                                                  if (status.integerValue == WebServiceSuccess)
                                                  {
                                                      
                                                      if([sender respondsToSelector:NSSelectorFromString(self.executionSelector)] &&
                                                         [self.executionSelector length] > 1)
                                                      {
                                                          SuppressPerformSelectorLeakWarning
                                                          (
                                                           [sender performSelector:NSSelectorFromString(self.executionSelector) withObject:responseDictionary];
                                                           );
                                                          
                                                          if (setTimeInfoLogger || setLogger)
                                                          {
                                                              methodFinish = [NSDate date];
                                                              NSLog(@"WS method completed in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                          }
                                                          
                                                      }
                                                      else if([self.executionSelector length] > 0 && ![sender respondsToSelector:NSSelectorFromString(self.executionSelector)])
                                                      {
                                                          [NSException raise:[NSString stringWithFormat:@"%@ must implement the specified:%@", sender, executionSelector]format:@"Web Service Completion method not implemented"];
                                                      }
                                                      
                                                      if([self.interfaceSelector length] > 0 && [sender respondsToSelector:NSSelectorFromString(self.interfaceSelector)])
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              
                                                              SuppressPerformSelectorLeakWarning
                                                              (
                                                               [sender performSelector: NSSelectorFromString(self.interfaceSelector) withObject:message];
                                                               );
                                                              
                                                              if (setTimeInfoLogger || setLogger)
                                                              {
                                                                  methodFinish = [NSDate date];
                                                                  NSLog(@"UI method completed in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                              }
                                                          });
                                                      
                                                      else if([self.interfaceSelector length] > 0 && ![sender respondsToSelector:NSSelectorFromString(self.interfaceSelector)])
                                                      {
                                                          
                                                          [NSException raise:[NSString stringWithFormat:@"%@ must implement the specified:%@", sender, self.interfaceSelector]format:@"UI Completion method not implemented"];
                                                      }
                                                      
                                                  }
                                                  /*WebService has returned BDAWebServiceFailed. Show message.*/
                                                  else if (status.integerValue == WebServiceFailed)
                                                  {
                                                      
                                                      error == nil ? [errorDictionary setObject:@"" forKey:@"NSURLSessionError"]
                                                      : [errorDictionary setObject:error forKey:@"NSURLSessionError"];
                                                      [errorDictionary setObject:message forKey:@"WebServiceError"];
                                                      
                                                      SuppressPerformSelectorLeakWarning
                                                      (
                                                       [sender performSelector:NSSelectorFromString(self.errorSelector) withObject:errorDictionary];
                                                       
                                                       );
                                                      
                                                      if (setLogger || setTimeInfoLogger)
                                                      {
                                                          methodFinish = [NSDate date];
                                                          NSLog(@"Web Service error block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                      }
                                                  }
                                              }
                                              /*Error is not nil. Show error*/
                                              else
                                              {
                                                  
                                                  [errorDictionary setObject:error forKey:@"NSURLSessionError"];
                                                  
                                                  NSInteger errorCode = [[[error userInfo] objectForKey:@"NSUnderlyingError"] code];
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                      if (errorCode == NSURLErrorTimedOut ||
                                                          errorCode == NSURLErrorNotConnectedToInternet ||
                                                          errorCode == NSURLErrorCannotFindHost)
                                                      {
                                                          
                                                          NSString *errorString;
                                                          
                                                          switch (errorCode)
                                                          {
                                                              case NSURLErrorCannotFindHost:
                                                                  errorString = @"Cannot Find Host!";
                                                                  break;
                                                                  
                                                              case NSURLErrorNotConnectedToInternet:
                                                                  errorString = @"No Internet!";
                                                                  break;
                                                                  
                                                              case NSURLErrorTimedOut:
                                                                  errorString = @"Request Timed Out!";
                                                                  break;
                                                                  
                                                              default:
                                                                  errorString = @"Other error";
                                                                  break;
                                                          }
                                                          
                                                          [uploadTask cancel];
                                                          
                                                          if (NSClassFromString(@"UIAlertController"))
                                                          {
                                                              UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:errorString
                                                                                                                                  message:nil
                                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                                              
                                                              UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                                                  [self errorHandlingUploadWebServicewithInput:inputDictionary
                                                                                             andWebServicePath:path
                                                                                                      bySender:sender];
                                                                  
                                                              }];
                                                              
                                                              UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                                                              
                                                              [errorAlert addAction:cancelAction];
                                                              [errorAlert addAction:retryAction];
                                                              
                                                              [sender presentViewController:errorAlert animated:YES completion:nil];
                                                          }
                                                          else
                                                          {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Timed Out"
                                                                                                              message:nil
                                                                                                             delegate:self
                                                                                                    cancelButtonTitle:@"Cancel"
                                                                                                    otherButtonTitles:@"Retry", nil];
                                                              alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                                                              
                                                              [alert show];
                                                          }
                                                      }
                                                      else
                                                      {

                                                          NSLog(@"Error:%@", error);
                                                      }
                                                      
                                                  });
                                                  
                                                  
                                                  SuppressPerformSelectorLeakWarning
                                                  (
                                                   [sender performSelector:NSSelectorFromString(self.errorSelector) withObject:errorDictionary];
                                                   
                                                   );
                                                  
                                                  if (setTimeInfoLogger || setLogger)
                                                  {
                                                      methodFinish = [NSDate date];
                                                      NSLog(@"NSError block reached in:%f second(s)", [methodFinish timeIntervalSinceDate:methodStart]);
                                                  }
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
