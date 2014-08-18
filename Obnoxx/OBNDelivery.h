//
//  OBNDelivery.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/8/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBNDelivery : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *soundId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *recipientUserId;
@property (nonatomic, retain) NSDate *deliveryDateTime;

- (instancetype)initWithDictionary:(NSDictionary *)delivery;

@end
