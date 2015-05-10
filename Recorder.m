//
//  RNFSManager.m
//  RNFSManager
//
//  Created by Johannes Lumpe on 08/05/15.
//  Copyright (c) 2015 Johannes Lumpe. All rights reserved.
//

#import "RCTConvert.h"
#import "RCTBridge.h"
#import "Recorder.h"

@implementation Recorder

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

- (id) setupSession {
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSError *setOverrideError;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setOverrideError];
    return session;
}

NSURL *outputFileURL;
- (id) setupRecorder:(NSString*)filename :(AVAudioSession*)session {
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               filename,
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt: 16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    [recordSetting setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Initiate and prepare the recorder
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    [recorder prepareToRecord];
    
    return recorder;
}


AVAudioSession *session;
AVAudioRecorder *recorder;

RCT_EXPORT_METHOD(startRecording:(NSString*)filename:(RCTResponseSenderBlock)callback) {
  session = [self setupSession];
  [session setActive:YES error:nil];
  
  recorder = [self setupRecorder: filename: session];
  [recorder record];
  callback(@[[NSNull null], [recorder.url path]]);
}

RCT_EXPORT_METHOD(stopRecording:(RCTResponseSenderBlock)callback) {
  [recorder stop];
  [session setActive:NO error:nil];

  NSData *content = [[NSFileManager defaultManager] contentsAtPath: [outputFileURL path]];
  NSString *base64Content = [content base64EncodedStringWithOptions:0];

  if (!base64Content) {
    return callback(@[[NSString stringWithFormat:@"Could not read file at path %@", outputFileURL]]);
  }

  callback(@[[NSNull null], base64Content]);
}

RCT_EXPORT_METHOD(playLastRecording:(RCTResponseSenderBlock)callback) {
  self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileURL error:nil];
  [self.player prepareToPlay];
  [self.player play];
  callback(@[[NSNull null], [outputFileURL path]]);
}

RCT_EXPORT_METHOD(playBase64Audio:(NSString*)base64Content) {
  NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64Content options:0];
  self.player = nil;
  self.player = [[AVAudioPlayer alloc] initWithData:decodedData error:nil];
  [self.player prepareToPlay];
  [self.player play];
}

@end
