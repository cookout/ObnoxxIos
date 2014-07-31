//
//  OBNServerCommunicator.h
//  Obnoxx
//
//  Singleton that manages interactions with the Obnoxx server
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "OBNSound.h"

@interface OBNServerCommunicator : NSObject
@property (nonatomic, strong) NSMutableArray *loginListeners;
@property (nonatomic, strong) NSMutableArray *uploadListeners;
@end
