//
//  OBNAutoTuneFilter.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/14/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNAutoTuneFilter.h"

@implementation OBNAutoTuneFilter

static OSStatus filterCallback(__unsafe_unretained OBNAutoTuneFilter *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               AEAudioControllerFilterProducer producer,
                               void                     *producerToken,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio) {
    // Pull audio
    OSStatus status = producer(producerToken, audio, &frames);
    if ( status != noErr ) status;
    
    
    for(int i=audio->mNumberBuffers;i>0;i--)
    {
        for(int j=0;j<frames;j++)
        {
            *((SInt16 *)audio->mBuffers[i].mData + sizeof(SInt16)*j) = *((SInt16 *)audio->mBuffers[i].mData + sizeof(SInt16)*j) * 2;
        }
    }
    
    // Now filter audio in 'audio'
    
    return noErr;
}
-(AEAudioControllerFilterCallback)filterCallback {
    return filterCallback;
}
@end