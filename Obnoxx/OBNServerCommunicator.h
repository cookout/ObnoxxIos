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
@property (nonatomic, retain) NSObject *verifyResponse;
@property (nonatomic, retain) NSObject *uploadResponse;
@property (nonatomic, retain) NSObject *loginResponse;

+(instancetype) sharedInstance;
-(void) phoneVerifyListener:(id) listener;
-(void) verifyPhoneNumber:(NSString *) phoneNumber;
-(void) verifyCode: (NSString *) verificationCode;
-(void) sendSound:(NSString *)filePath fileName:(NSString *)fileName recipientPhone:(NSString *) recipientPhone;
-(void) registerToken;
-(void) getSoundDelivery:(NSString *)deliveryId;
@end
