//
//  OBServerCommunicator.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNServerCommunicator.h"
#import "OBNJSONResponseSerializer.h"

@implementation OBNServerCommunicator

+(instancetype) sharedInstance
{
    static OBNServerCommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[OBNServerCommunicator alloc] init];
            sharedInstance.uploadListeners = [[NSMutableArray alloc]init];
            sharedInstance.loginListeners = [[NSMutableArray alloc]init];
        }
    });
    return sharedInstance;
}

-(void) sendSound:(OBNSound *) sound
{
    NSMutableDictionary *parameters;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[OBNJSONResponseSerializer alloc] init];
    
    /*"soundFile"
    "sessionId"
    "phoneNumber"*/
    
    [manager GET:@"http://obnoxx.co/addSound" parameters:@{}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Sucessfully sent sound to intended recipient, handle it here
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Sound send failed, handle it here

         }];
   
}


-(void) addSendSoundListener: (id) listener
{

}


@end
