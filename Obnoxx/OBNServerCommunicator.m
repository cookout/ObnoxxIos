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
                      NSString  *documentsDirectory = [paths objectAtIndex:0];
                  
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
            self.soundsResponse = responseObject;
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Sound send failed, handle it here
            NSLog(@"Get all sounds failed %@", operation);
            self.soundsResponse = operation.responseObject;
        }];
}

@end
