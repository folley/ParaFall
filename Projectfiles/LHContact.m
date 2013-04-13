//
//  LHContact.m
//  Test
//
//  Created by Maciej Lobodzinski on 13.04.2013.
//
//

#import "LHContact.h"

@implementation LHContact

- (void)crash:(LHPlayer *)player andObstacle:(LHObstacle *)obstacle
{
    [player flashingFor:(float)seconds];
    [obstacle explode];
    
//    punkty--;
}

- (void)player:(LHPlayer *)player hasCollected:(LHRaspberry)raspberry
{
    [player highlightFor:(float)time];
    [raspberry releaseAfterAnimation];
    
//    punkty++;
}

@end
