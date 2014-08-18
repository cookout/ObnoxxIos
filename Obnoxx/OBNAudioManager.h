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
#import "OBNAutoTuneFilter.h"

typedef enum {
    kCuji,
    kKaraka,
    kPopHero,
    kTippy,
    kEqo
} OBFilter;

typedef enum {
    kLasers,
    kBubbles,
    kFart
} OBEffect;

@interface OBNAudioManager : NSObject
@property (nonatomic, strong) AEAudioController *playbackController;
@property (nonatomic, strong) AEAudioController *recordingController;

@property (nonatomic, strong) AERecorder *audioRecorder;
@property (nonatomic, strong) AEAudioFilePlayer *audioPlayer;
+(instancetype)sharedInstance;
-(void) play: (NSString *) sourceFilePath isRecording: (BOOL) isRecording filter:(id)filter;
-(OBNSound *) record: (NSString *)filePath;
-(void) stop;
-(void) addFilter: (OBFilter) filter  path:(NSString *) filePath;
-(void) addEffect: (OBEffect) effect;
-(void) saveTo: (NSString *) path;
-(void) playNotification:(NSString *) sourceFilePath;
@end
