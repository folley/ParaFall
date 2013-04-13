//
//  LHPlayer.h
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import <Foundation/Foundation.h>
#import "LHNode.h"

@interface LHPlayer : LHNode

+ (id)mainPlayer;

- (void)highlightFor:(float)time;
- (void)flashingFor:(float)time;

@end

