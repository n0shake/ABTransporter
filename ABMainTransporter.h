//
//  ABMainTransporter.h
//  ABTransporter
//
//  Created by Abhishek Banthia on 27/04/15.
//  Copyright (c) 2015 Abhishek Banthia. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ABMainTransporter : NSObject

typedef NS_ENUM(NSInteger, WebServiceResponseStatus)
{
    WebServiceFailed = 0,
    WebServiceSuccess
};

@property (strong, nonatomic) NSString* executionSelector;
@property (strong, nonatomic) NSString* interfaceSelector;
@property (strong, nonatomic) NSString* errorSelector;

/*If selectors are passed as arguments, make sure the sender has implemented them. Otherwise, even though WS will successfully complete, there will be an exception thrown.
 
 WebService response will be sent as dictionary to the execution selector
 
 The WS response message will be passed to the UICompletionMethod. Also, the UICompletionMethod will be executed on the main thread.
 
 Please double check selector names*/

/*The following two methods are created as class methods because:
 
 1. We don't access any iVars in these methods
 2. WSs are called frequently. So, we don't have to alloc->init everytime
 
 */

+ (void)dataWebServicewithWebServicePath:(NSString *)path bySender:(id)sender withUICompletionMethodName:(NSString *)selector andExecutionMethodCompletionName:(NSString *)executionSelector;

+ (void)uploadDataWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path bySender:(id)sender withUICompletionMethodName:(NSString *)selector andExecutionMethodCompletionName:(NSString *)executionSelector;

/*If sender wants to handle error*/
- (void)errorHandlingUploadWebServicewithInput:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path bySender:(id)sender;

+ (void)setTimeLogger;

+ (void)setResponseLogger;

+ (void)setLogger;

@end
