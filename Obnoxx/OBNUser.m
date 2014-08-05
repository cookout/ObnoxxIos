//
//  OBNUser.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNUser.h"

#define kUserId @"User Id"
#define kName @"Name"
#define kFacebookId @"Facebook Id"
#define kImageFilename @"User Photo"

@implementation OBNUser

-(instancetype) initWithUserId:userId name:name fbUserId:fbUserId userPhoto:userPhoto
{
    self = [super self];
    if(self) {
        _name = name;
        _id = userId;
        _fbUserId = fbUserId;
        _imageFilename = userPhoto;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_id forKey:kUserId];
    [encoder encodeObject:_name forKey:kName];
    [encoder encodeObject:_fbUserId  forKey:kFacebookId];
    [encoder encodeObject:_imageFilename  forKey:kImageFilename];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSString *userId = [decoder decodeObjectForKey:kUserId];
    NSString *name = [decoder decodeObjectForKey:kName];
    NSString *fbUserId = [decoder decodeObjectForKey:kFacebookId];
    NSString *userPhoto = [decoder decodeObjectForKey:kImageFilename];
    
    return [self initWithUserId:userId name:name fbUserId:fbUserId userPhoto:userPhoto];
}

@end
