//
//  OBNAudioManager.h
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/5/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"
#import "AERecorder.h"
#import "AEAudioFilePlayer.h"
#import "OBNSound.h"

typedef enum {
    kReverb,
    kAutoTune,
    kBasic,
    kHelium,
    kSuperBass
} OBFilter;

typedef enum {
    kLasers,
    kBubbles,
    kFart
} OBEffect;

@interface OBNAudioManager : NSObject
@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AERecorder *audioRecorder;
@property (nonatomic, strong) AEAudioFilePlayer *audioPlayer;
+(instancetype)sharedInstance;
-(void) play: (NSString *) fileURL;
-(OBNSound *) record: (NSString *)filePath;
-(void) stop;
-(void) addFilter: (OBFilter) filter  path:(NSString *) filePath;
-(void) addEffect: (OBEffect) effect;
-(void) saveTo: (NSString *) path;
@end
