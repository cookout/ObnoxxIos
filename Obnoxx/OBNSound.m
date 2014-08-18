//
//  OBNSound.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNSound.h"

@implementation OBNSound

- (instancetype)initWithDictionary:(NSDictionary *)sound {
    self = [super init];
    
    if (self) {
        _id = [sound valueForKey:@"id"];
        _userId = [sound valueForKey:@"userId"];
        _soundFileUrl = [sound valueForKey:@"soundFileUrl"];
        _localUrl = nil;
    }
    return self;
}

@end
