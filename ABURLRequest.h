//
//  ABURLRequest.h
//  ABTransporter
//
//  Created by Abhishek Banthia on 11/06/15.
//  Copyright (c) 2015 Abhishek Banthia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABURLRequest : NSMutableURLRequest

+ (instancetype)defaultRequest;
+ (instancetype)defaultRequestWithURL:(NSURL*)url;

@end
