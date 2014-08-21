//
//  OBNUser.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBNUser : NSObject <NSCoding>

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fbUserId;
@property (nonatomic, retain) NSString *imageFilename;
- (instancetype)initWithDictionary: (NSDictionary *) user;
- (instancetype)initWithUserId:userId
                          name:name
                      fbUserId:fbUserId
                     userPhoto:userPhoto;
@end
