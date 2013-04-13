/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "GLES-Render.h"

#import "ContactListener.h"
#import "LeapObjectiveC.h"

enum
{
	kTagBatchNode,
};

@interface PhysicsLayer1 : CCLayer
{
	b2World* world;
	ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
}

@end
