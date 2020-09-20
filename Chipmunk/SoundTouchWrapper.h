//
//  SoundTouchWrapper.h
//  Chipmunk
//
//  Created by Yogesh Padekar on 16/08/20.
//  Copyright © 2020 MusicMuni. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface SoundTouchWrapper: NSObject
- (NSURL *)base:(NSURL *)input output:(NSURL *)output effects:(NSArray *)effects;
@end
