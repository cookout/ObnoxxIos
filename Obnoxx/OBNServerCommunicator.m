//
//  OBServerCommunicator.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNServerCommunicator.h"
#import "OBNJSONResponseSerializer.h"
#import "OBNState.h"
#import "OBNAudioManager.h"

@implementation OBNServerCommunicator

+ (instancetype)sharedInstance {
    static OBNServerCommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[OBNServerCommunicator alloc] init];
        }
    });
    return sharedInstance;
}

- (void)verifyPhoneNumber:(NSString *)phoneNumber {
    NSDictionary *parameters=@{@"phoneNumber":phoneNumber};
    
    AFHTTPRequestOperationManager *manager =
            [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/verifyPhoneNumber" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             self.verifyResponse = (NSDictionary *)responseObject;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             self.verifyResponse = (NSDictionary *)operation.responseObject;
         }];
}

- (void)verifyCode:(NSString *)verificationCode {
    
    OBNState *appState = [OBNState sharedInstance];
    
    NSDictionary *parameters = @{
        @"verificationCode" : verificationCode,
        @"temporaryUserCode" : appState.temporaryToken
    };
    AFHTTPRequestOperationManager *manager =
            [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/verifyPhoneNumber" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             self.verifyResponse = (NSDictionary *)responseObject;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             self.verifyResponse = (NSDictionary *)operation.responseObject;
         }];
}

- (void)sendSound:(NSString *)filePath
         fileName:(NSString *)fileName
   recipientPhone:(NSString *)recipientPhone {
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *parameters = @{
        @"sessionId" : appState.sessionId,
        @"phoneNumber" : recipientPhone
    };
    AFHTTPRequestOperationManager *manager =
            [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    [manager POST:@"http://obnoxx.co/addSound"
                       parameters:parameters
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data
                                        name:@"soundFile"
                                    fileName:fileName mimeType:@"audio/aac"];
        }
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Sucessfully sent sound to intended recipient, handle it here
            NSLog(@"Send success %@", responseObject);
            self.uploadResponse = (NSDictionary *)responseObject;
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Sound send failed, handle it here
            NSLog(@"Send failed %@", operation);
            self.uploadResponse = (NSDictionary *)operation.responseObject;
        }];
}

- (void)registerToken {
    OBNState *appState = [OBNState sharedInstance];
    NSData *token = appState.deviceToken;
    
    // Convert the token to Hex so that the server understands it
    const unsigned char *dataBuffer = (const unsigned char *)[token bytes];
    NSUInteger dataLength = [token length];
    NSMutableString *hexString =
            [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx",
                                         (unsigned long)dataBuffer[i]]];
    
    NSDictionary *parameters = @{
        @"sessionId" : appState.sessionId,
        @"registrationId" : hexString,
        @"type" : @"ios"
    };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager POST:@"http://obnoxx.co/addDeviceRegistrationId" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             NSLog(@"Registered successfully %@", responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             NSLog(@"Register failed %@", operation.responseObject);
         }];
}

- (void)getSoundDelivery:(NSString *)deliveryId {
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *parameters = @{
        @"sessionId" : appState.sessionId,
        @"soundDeliveryId" : deliveryId
    };
    
    AFHTTPRequestOperationManager *manager =
            [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/getSoundDelivery" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             NSLog(@"Get sound delivery successfully %@",responseObject);
             OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];
              
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSURL *url = [NSURL URLWithString:[[responseObject valueForKey:@"sound"]
                                                                    valueForKey:@"soundFileUrl"]];
                 NSData *urlData = [NSData dataWithContentsOfURL:url];
                 NSString  *filePath;
                 if (urlData) {
                     NSArray *paths = NSSearchPathForDirectoriesInDomains(
                             NSDocumentDirectory, NSUserDomainMask, YES);
                     NSString *documentsDirectory = [paths objectAtIndex:0];
                  
                     filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"sound.m4a"];
                     [urlData writeToFile:filePath atomically:YES];
                 }
                 [audioManager playNotification:filePath];
             });
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             NSLog(@"Get sound delivery failed %@", operation);
         }];
}

- (void)getSounds {
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *parameters = @{ @"sessionId" : appState.sessionId };

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/getSounds"
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Sucessfully sent sound to intended recipient, handle it here
            NSLog(@"Get all sounds succeeded %@", responseObject);

            // Populate the local data model with results
            appState.deliveries = [responseObject valueForKey:@"soundDeliveries"];
            appState.users = [responseObject valueForKey:@"users"];
            appState.sounds = [responseObject valueForKey:@"sounds"];

            [appState setupUniqueSenderList];
            [appState saveToDisk];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Sound send failed, handle it here
            NSLog(@"Get all sounds failed %@", operation);
        }];
}


- (void)logPlayback:(NSString *) soundId delivery:(NSString *)deliveryId
{
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *parameters = @{ @"sessionId" : appState.sessionId,
                                  @"soundId":soundId,
                                  @"soundDeliveryId":deliveryId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/logSoundPlay"
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Successfully logged a sound playback
             // TODO: Something
             NSLog(@"Playback logging success %@", responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Playback logging failed
             // TODO: Something
             NSLog(@"Playback logging fail %@ %@", operation.responseObject, error);
         }];
}

-(void) heart: (NSString *) soundId hearted: (BOOL) hearted
{
    OBNState *appState = [OBNState sharedInstance];
    NSNumber *heart = [NSNumber numberWithBool:hearted];
    NSDictionary *parameters;
    
    if(hearted)
    {
        parameters = @{ @"sessionId" : appState.sessionId,
                                  @"soundId":soundId,
                                  @"hearted":@"true"};
    }
    else
    {
        parameters = @{ @"sessionId" : appState.sessionId,
                                      @"soundId":soundId,
                                      @"hearted":@"false"};
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/setSoundHearted"
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Successfully logged a sound playback
             // TODO: Something
             NSLog(@"Hearting success %@", responseObject);
             /*OBNState *appState = [OBNState sharedInstance];
             for(int i=0;i<appState.sounds.count;i++)
             {
                 if([[appState.sounds[i] valueForKey:@"id"] isEqualToString:soundId])
                 {
                     [appState.sounds[i] setValue:heart forKey:@"hearted"];
                     int numHearts = [appState.sounds[i] valueForKey:@"numHearts"];
                     if(hearted)
                         numHearts++;
                     else numHearts--;
                     [appState.sounds[i] setValue:[NSNumber numberWithInt:numHearts] forKey:@"numHearts"];
                     break;
                 }
             }
             [appState saveToDisk];*/
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Playback logging failed
             // TODO: Something
             NSLog(@"Hearting fail %@ %@", operation.responseObject, error);
         }];
}


@end
