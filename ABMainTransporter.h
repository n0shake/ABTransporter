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

/*The following two methods are created as class methods because:
 
 1. We don't access any iVars in these methods
 2. WSs are called frequently. So, we don't have to alloc->init everytime
 
 */

/*Designated singleton*/

+ (instancetype)sharedTransporter;

+ (void)dataWebServicewithWebServicePath:(NSString *)path withCompletionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionBlock;

+ (void)uploadDataWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path withCompletionBlock:(void(^)(NSData *data, NSError *error, NSURLResponse *response))completionBlock;

/*For GET Requests*/
- (void)GETWebServiceWithInputDictionary:(NSDictionary *)inputDictionary andWebServicePath:(NSString *)path withCompletionBlock:(void(^)(NSData *data, NSError *error, NSURLResponse *response))completionBlock;

+ (void)setLogger;

@end
