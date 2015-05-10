//
//  Recorder.h
//  Recorder
//
//  Created by Johannes Lumpe on 08/05/15.
//  Copyright (c) 2015 Johannes Lumpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RCTBridgeModule.h"
#import "RCTLog.h"

@interface Recorder : NSObject <RCTBridgeModule>

  @property AVAudioPlayer *player;

@end
