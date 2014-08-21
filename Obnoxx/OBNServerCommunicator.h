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

// TODO (CRA): Change this to make observers watch the OBNState instead of
// the server   communicator.

@property (nonatomic, retain) NSDictionary *verifyResponse;
@property (nonatomic, retain) NSDictionary *uploadResponse;
@property (nonatomic, retain) NSDictionary *loginResponse;
@property (nonatomic, retain) NSDictionary *soundsResponse;

+ (instancetype)sharedInstance;
- (void)verifyPhoneNumber:(NSString *)phoneNumber;
- (void)verifyCode:(NSString *)verificationCode;
- (void)sendSound:(NSString *)filePath
         fileName:(NSString *)fileName
   recipientPhone:(NSString *)recipientPhone;
- (void)registerToken;
- (void)getSoundDelivery:(NSString *)deliveryId;
- (void)getSounds;

@end
