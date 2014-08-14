//
//  OBNDelivery.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/8/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNDelivery.h"

@implementation OBNDelivery

-(instancetype) initWithDictionary: (NSDictionary *) delivery
{
    self = [super init];
    
    if(self)
    {
        _id = [delivery valueForKey:@"id"];
        _soundId = [delivery valueForKey:@"soundId"];
        _userId = [delivery valueForKey:@"userId"];
        _phoneNumber = [delivery valueForKey:@"phoneNumber"];
        
        if([delivery objectForKey:@"recipientUserId"])
            _recipientUserId = [delivery valueForKey:@"recipientUserId"];
        else _recipientUserId = nil;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter  setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"PST"]];
        _deliveryDateTime = [formatter dateFromString:[delivery valueForKey:@"deliveryDateTime"]];
    }
    return self;
}
@end
