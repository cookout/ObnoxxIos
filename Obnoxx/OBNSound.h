//
//  OBNSound.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface OBNSound : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *soundFileUrl;
@property (nonatomic, retain) NSString *localUrl;

- (instancetype)initWithDictionary:(NSDictionary *)sound;

@end
