//
//  OBNConversationViewController.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/19/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBNUser.h"
#import "OBNState.h"
#import "OBNAudioManager.h"

@interface OBNConversationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) OBNUser *sender;
@end
