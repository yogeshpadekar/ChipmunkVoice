//
//  SoundTouchWrapper.m
//  Chipmunk
//
//  Created by Yogesh Padekar on 16/08/20.
//  Copyright © 2020 MusicMuni. All rights reserved.
//

#import "SoundTouch.h"
#import "SoundTouchWrapper.h"
#import "main.h"

@implementation SoundTouchWrapper

/// Function to take WAV file as an input, process it, and output a WAV file
/// @param input input WAV file URL
/// @param output destination WAV file URL
/// @param effects Effects to perform on input WAV file
- (NSURL *)base:(NSURL *)input output:(NSURL *)output effects:(NSArray *)effects {
    int _argc = 3 + (int)[effects count];
    
    const char *_argv[] = {
        "createWavWithEffect",
        [[input path] UTF8String],
        [[output path] UTF8String],
        [@"" UTF8String],
        [@"" UTF8String],
        [@"" UTF8String]
    };
    
    //Add effects as arguments, currently we are adding only one effect, more can be added
    for (int i=0; i<[effects count]; i++) {
        _argv[i+3] = [effects[i] UTF8String];
    }
    
    //Call function to create WAV file
    createWavWithEffect(_argc, _argv);
    return output;
}
@end
