//
//  OBNState.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/31/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBNUser.h"

@interface OBNState : NSObject <NSCoding>
@property (nonatomic, strong) NSString *temporaryToken;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, retain) OBNUser *currentUser;
@property (nonatomic, retain) NSData *deviceToken;
@property (nonatomic, retain) NSNumber *isRegistered;
@property (nonatomic, retain) NSMutableArray *deliveries;
@property (nonatomic, retain) NSMutableArray *sounds;
@property (nonatomic, retain) NSMutableArray *users;

+(instancetype) sharedInstance;
-(BOOL) saveToDisk;
@end
