//
//  OBServerCommunicator.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNServerCommunicator.h"

@implementation OBNServerCommunicator

+(instancetype) sharedInstance
{
    static OBNServerCommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[OBNServerCommunicator alloc] init];
            sharedInstance.uploadListeners = [[NSMutableArray alloc]init];
            sharedInstance.loginListeners = [[NSMutableArray alloc]init];
        }
    });
    return sharedInstance;
}

@end
