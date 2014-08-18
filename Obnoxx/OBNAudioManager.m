//
//  OBNAudioManager.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/5/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNAudioManager.h"

@implementation OBNAudioManager

+ (instancetype)sharedInstance
{
    static OBNAudioManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[OBNAudioManager alloc] init];
        }
    });
    return sharedInstance;
}
-(instancetype) init
{
    self = [super init];
    if(self)
    {
        _recordingController = nil;
        _audioRecorder = nil;
        _audioPlayer = nil;
        _playbackController =[[AEAudioController alloc]
                              initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                              inputEnabled:NO];
        [_playbackController start:nil];
    }
    return self;
}

-(void) playNotification:(NSString *) sourceFilePath
{
    NSURL *file = [NSURL fileURLWithPath:sourceFilePath];
    AEAudioFilePlayer *notificationPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:file
                                                 audioController:_playbackController
                                                           error:NULL];
    notificationPlayer.completionBlock = ^{
        // Remove self from channel list after playback is complete
        [_playbackController removeChannels:[NSArray arrayWithObjects:notificationPlayer,nil]] ;
        
    };
    
    [_playbackController addChannels:[NSArray arrayWithObjects:notificationPlayer,nil]];
}

-(void) play: (NSString *) sourceFilePath isRecording: (BOOL) isRecording filter:(id) filter
{
    if(!_playbackController)
    {
        _playbackController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:NO];
        
        NSError *err = [[NSError alloc] init];
        [_playbackController start:&err];
    }

    NSRange fileName = [sourceFilePath rangeOfString:[sourceFilePath lastPathComponent]];
    NSRange path = NSMakeRange(0, sourceFilePath.length-fileName.length);
    NSMutableString *newName = [[NSMutableString alloc] initWithString:[sourceFilePath substringWithRange:path]];
    [newName appendString:@"proc.m4a"];

    NSURL *file = [NSURL fileURLWithPath:sourceFilePath];
    self.audioPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:file
                                            audioController:_playbackController
                                             error:NULL];
    if(isRecording)
    {
        // Add a completion handler that completes the recording and removes
        // the recorder from the graph
        self.audioPlayer.completionBlock = ^{
            // Stop recording and remove audio recorder from the audiograph
            [self.audioRecorder finishRecording];
            [_playbackController removeOutputReceiver:self.audioRecorder];
            self.audioRecorder = nil;
            
            // If there's a filter in the audiograph, remove it
            if(filter)
            {
                [_playbackController removeFilter:filter];
            }
            
            // Remove self from channel list after playback is complete
            [_playbackController removeChannels:[NSArray arrayWithObjects:self.audioPlayer,nil]] ;
        };
    }
    [_playbackController addChannels:[NSArray arrayWithObjects:self.audioPlayer,nil]];
 }


-(void) addFilter: (OBFilter) filter  path:(NSString *) filePath
{
    if(!_playbackController)
    {
        _playbackController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:NO];
        [_playbackController start:nil];
    }
    switch(filter)
    {
        case kCuji:
        {
            AudioComponentDescription cuji = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_FormatConverter, kAudioUnitSubType_NewTimePitch);
            
            AEAudioUnitFilter *cujiUnit = [[AEAudioUnitFilter alloc] initWithComponentDescription:cuji
                                                                                    audioController:_playbackController error:nil];
            
            if(!cujiUnit) NSLog(@"Trouble creating Cuji unit");
            AudioUnitSetParameter(cujiUnit.audioUnit, kNewTimePitchParam_Pitch,
                                  kAudioUnitScope_Global,0,
                                  1800.f, 0);
            [_playbackController addFilter:cujiUnit];
            
            // Path to store processed file
            NSRange fileName = [filePath rangeOfString:[filePath lastPathComponent]];
            NSRange path = NSMakeRange(0, filePath.length-fileName.length);
            NSMutableString *newName = [[NSMutableString alloc] initWithString:[filePath substringWithRange:path]];
            [newName appendString:@"proc.m4a"];
            
            // Add the audio recorder to the audio graph
            self.audioRecorder = [[AERecorder alloc] initWithAudioController:_playbackController];
            [self.audioRecorder beginRecordingToFileAtPath:newName fileType:kAudioFileM4AType error:nil];
            [_playbackController addOutputReceiver:self.audioRecorder];
            
            // Run the graph
            [self play:filePath isRecording:YES filter:cujiUnit];
            break;
        }
        case kKaraka:
        {
            AudioComponentDescription karaka = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_FormatConverter, kAudioUnitSubType_NewTimePitch);
            
            AEAudioUnitFilter *karakaUnit = [[AEAudioUnitFilter alloc] initWithComponentDescription:karaka
                                                                                    audioController:_playbackController error:nil];
            
            if(!karakaUnit) NSLog(@"Trouble creating Karaka unit");
            AudioUnitSetParameter(karakaUnit.audioUnit, kNewTimePitchParam_Pitch,
                                  kAudioUnitScope_Global,0,
                                  -700.f, 0);
            [_playbackController addFilter:karakaUnit];
            
            NSRange fileName = [filePath rangeOfString:[filePath lastPathComponent]];
            NSRange path = NSMakeRange(0, filePath.length-fileName.length);
            NSMutableString *newName = [[NSMutableString alloc] initWithString:[filePath substringWithRange:path]];
            [newName appendString:@"proc.m4a"];
            
            self.audioRecorder = [[AERecorder alloc] initWithAudioController:_playbackController];
            [self.audioRecorder beginRecordingToFileAtPath:newName fileType:kAudioFileM4AType error:nil];
            [_playbackController addOutputReceiver:self.audioRecorder];
            [self play:filePath isRecording:YES filter:karakaUnit];
            break;
        }
        case kPopHero:
        {
            //AudioComponentDescription popHero = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_FormatConverter, kAudioUnitSubType_NewTimePitch);
            
            AEAudioUnitFilter *popHeroUnit = [[OBNAutoTuneFilter alloc] init];
            [_playbackController addFilter:popHeroUnit];
            
            NSRange fileName = [filePath rangeOfString:[filePath lastPathComponent]];
            NSRange path = NSMakeRange(0, filePath.length-fileName.length);
            NSMutableString *newName = [[NSMutableString alloc] initWithString:[filePath substringWithRange:path]];
            [newName appendString:@"proc.m4a"];
            
            self.audioRecorder = [[AERecorder alloc] initWithAudioController:_playbackController];
            [self.audioRecorder beginRecordingToFileAtPath:newName fileType:kAudioFileM4AType error:nil];
            [_playbackController addOutputReceiver:self.audioRecorder];
            
            [self play:filePath isRecording:YES filter:popHeroUnit];
            break;
        }
        case kTippy:
        {
            break;
        }
        case kEqo:
        {
            break;
        }
        default:
        {
            
        }
    }
}

-(void) addEffect: (OBEffect) effect
{
    
}

-(OBNSound *) record: (NSString *)filePath
{
    if(!_recordingController)
    {
        _recordingController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:YES];
        [_recordingController start:nil];
    }
    self.audioRecorder = [[AERecorder alloc] initWithAudioController:_recordingController];
    OBNSound *recording = [[OBNSound alloc] init];
    recording.localUrl = filePath;
    
    
    NSError *error = NULL;
    
    // Receive both audio input and audio output. Note that if you're using
    // AEPlaythroughChannel, mentioned above, you may not need to receive the input again.
    
    if ( ![self.audioRecorder beginRecordingToFileAtPath:filePath
                                                fileType:kAudioFileM4AType
                                                   error:&error] ) {
        // Report error
        NSLog(@"Error initializing audio recorder");
        return nil;
    }
    
    [_recordingController addInputReceiver:self.audioRecorder];
    return recording;
}

-(void) stop
{
    [self.recordingController removeInputReceiver:self.audioRecorder];
    [self.audioRecorder finishRecording];
    self.audioRecorder = nil;
    [_recordingController stop];
    _recordingController = nil;
}

@end
