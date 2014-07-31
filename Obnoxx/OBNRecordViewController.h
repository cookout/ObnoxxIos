//
//  OBNRecordViewController.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/31/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEAudioController.h"
#import "AERecorder.h"
#import "AEAudioFilePlayer.h"
#import "OBNSound.h"


@interface OBNRecordViewController : UIViewController
@property (nonatomic, strong) OBNSound *recording;
@end
