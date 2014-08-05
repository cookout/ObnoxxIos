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

@implementation OBNServerCommunicator

+(instancetype) sharedInstance
{
    static OBNServerCommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[OBNServerCommunicator alloc] init];
        }
    });
    return sharedInstance;
}


-(void) verifyPhoneNumber:(NSString *) phoneNumber
{
    NSDictionary *parameters=@{@"phoneNumber":phoneNumber};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/verifyPhoneNumber" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             self.verifyResponse = responseObject;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             self.verifyResponse = operation.responseObject;
         }];
}

-(void) verifyCode: (NSString *) verificationCode
{
    
    OBNState *appState = [OBNState sharedInstance];
    
    NSDictionary *parameters=@{@"verificationCode":verificationCode,
                               @"temporaryUserCode":appState.temporaryToken};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager GET:@"http://obnoxx.co/verifyPhoneNumber" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             self.verifyResponse = responseObject;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             self.verifyResponse = operation.responseObject;
         }];
}


-(void) sendSound:(NSString *)filePath fileName:(NSString *)fileName recipientPhone:(NSString *) recipientPhone
{
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *parameters = @{@"sessionId":appState.sessionId,
                                 @"phoneNumber":recipientPhone};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    

    [manager POST:@"http://obnoxx.co/addSound" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"soundFile" fileName:fileName mimeType:@"audio/aac"];
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             NSLog(@"Send success %@", responseObject);
             self.uploadResponse = responseObject;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here
             NSLog(@"Send failed %@", operation);
             self.uploadResponse = operation.responseObject;
         }];
}

-(void) registerToken:(NSData *) token
{
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *parameters = @{@"sessionId":appState.sessionId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    [manager POST:@"http://obnoxx.co/addDeviceRegistrationId" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:token name:@"registrationId" fileName:@"token" mimeType:@"application/octet-stream"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Sucessfully sent sound to intended recipient, handle it here
        NSLog(@"Registration success %@", responseObject);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Sound send failed, handle it here
        NSLog(@"Registration failed %@", operation);
    
    }];
}




@end
