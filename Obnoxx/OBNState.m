//
//  OBNState.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/31/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNState.h"

#define kTemporaryTokenKey @"Temporary Token"
#define kSessionId @"Session"
#define kCurrentUser @"Current User"
#define kDeviceToken @"Device Token"
#define kRegistrationStatus @"Device Registeration Status"
#define kDeliveries @"Sound deliveries"
#define kUsers @"Users"
#define kSounds @"Sounds"

#define kSavePath [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]stringByAppendingPathComponent:@"Private"]
#define kFileName @"obnoxx.1"

@implementation OBNState

+ (instancetype)sharedInstance {
    static OBNState *sharedInstance = nil;
    static dispatch_once_t onceToken;
    NSString *filePath = [kSavePath stringByAppendingPathComponent:kFileName];
    BOOL validPath =[[NSFileManager defaultManager] fileExistsAtPath:filePath];

    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            // Check if there's file that has saved state for user state
            if (!validPath) {
                // No save file found, create an empty state object & return in
                sharedInstance = [[OBNState alloc] init];
            } else {
                // Save file found - create shared instance from previous save state
                NSData *codedData = [[NSData alloc] initWithContentsOfFile:filePath];
                if (codedData == nil) {
                    // Bad data in file
                    sharedInstance = [[OBNState alloc] init];
                } else {
                    // Great - create and setup the shared instance with shared values
                    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
                    sharedInstance = [[OBNState alloc] init];
                    sharedInstance.temporaryToken = [decoder decodeObjectForKey:kTemporaryTokenKey];
                    sharedInstance.sessionId = [decoder decodeObjectForKey:kSessionId];
                    sharedInstance.currentUser = [decoder decodeObjectForKey:kCurrentUser];
                    sharedInstance.deviceToken = [decoder decodeObjectForKey:kDeviceToken];
                    sharedInstance.isRegistered = [decoder decodeObjectForKey:kRegistrationStatus];
                    sharedInstance.deliveries = [decoder decodeObjectForKey:kDeliveries];
                    sharedInstance.sounds = [decoder decodeObjectForKey:kSounds];
                    sharedInstance.users = [decoder decodeObjectForKey:kUsers];
                    
                    [decoder finishDecoding];
                }
            }
        }});
    return sharedInstance;
}

// Save current session snapshot to disk
- (BOOL)saveToDisk {
    NSString *filePath = [kSavePath stringByAppendingPathComponent:kFileName];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:kSavePath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:nil]) {
        return NO;
    }
    
    // Directory setup and ready - now save the file
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *encoder =
            [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

    [encoder encodeObject:self.temporaryToken  forKey:kTemporaryTokenKey];
    [encoder encodeObject:self.sessionId forKey:kSessionId];
    [encoder encodeObject:self.currentUser  forKey:kCurrentUser];
    [encoder encodeObject:self.deviceToken forKey:kDeviceToken];
    [encoder encodeObject:self.isRegistered forKey:kRegistrationStatus];
    [encoder encodeObject:self.deliveries forKey:kDeliveries];
    [encoder encodeObject:self.sounds forKey:kSounds];
    [encoder encodeObject:self.users forKey:kUsers];
        
    [encoder finishEncoding];
    return [data writeToFile:filePath atomically:YES];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _temporaryToken = nil;
        _sessionId = nil;
        _currentUser = nil;
        _deviceToken = nil;
        _isRegistered = [NSNumber numberWithBool:NO];
    }
    return self;
}

@end
