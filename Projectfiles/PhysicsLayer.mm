/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 *
 * blebleble Maciej Lobodzinski - maciejlobodzinski.me
 * twitter.com/mlobodzinski
 * nanana kabooom!
 *
 */

#import "PhysicsLayer.h"
#import "Box2DDebugLayer.h"
#import "Sample.h"
#import "LHPlayer.h"
#import "LHRocket.h"
#import "LHRaspberry.h"

const float PTM_RATIO = 32.0f;

const int TILESIZE = 100;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;

@interface PhysicsLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;

@end

@implementation PhysicsLayer {
    LeapController *controller;
    float handInclinationX;
    float handInclinationY;
    float handInclinationZ;
    b2Body *container;
}

@synthesize palmPos;

-(id) init
{
	if ((self = [super init]))
	{
        self.nodes = [[NSMutableArray alloc] init];
        
        [self run];
        [self addBG];
        [self initSettings];
        [self addPhysics];
        [self createTextures];
//        [self addLeapContainer];
//        [self addContainerForCircles];
//        [self addContainerForSquares];
        
        [self initPlayer];
        [self schedule:@selector(addNewObstacle:) interval:3.0];
        [self schedule:@selector(addNewRaspberries:) interval:7.0];
        
		[self scheduleUpdate];
        [self schedule:@selector(updateContainerPosition:)];
        [self schedule:@selector(updatePlayerPosition:)];
//        [self schedule:@selector(addFallingObject:) interval:3.];
        [self schedule:@selector(scalePlayer:)];
        // leap update - (void)onFrame:(NSNotification *)notification;
	}

	return self;
}


- (void)addNewRaspberries:(ccTime)dt
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat randomX = rand() % 1000;

    LHRaspberry *point = [[LHRaspberry alloc] init];
    [point setPosition:CGPointMake(randomX, winSize.height * 0.5)];
    [point addToLayer:self];
    [self.nodes addObject:point];
}

- (void)addNewObstacle:(ccTime)dt
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Random obstacle
    NSArray *obstaclesClasses = @[[LHRocket class]];
    int randomIdx = rand() % [obstaclesClasses count];
    LHObstacle *obstacle = [[obstaclesClasses[randomIdx] alloc] init];
    
    CGFloat randomX = rand() % 2000;
    [obstacle setPosition:CGPointMake(randomX, winSize.height/2)];
    [obstacle addToLayer:self];
    [self.nodes addObject:obstacle];
}

- (void)addBG
{
    CCSprite *cloud1 = [CCSprite spriteWithFile:@"chmura_lewa.png"];
    CCSprite *cloud2 = [CCSprite spriteWithFile:@"chmury_prawa.png"];
    CCSprite *cloud3 = [CCSprite spriteWithFile:@"chmura_dol.png"];
    
//    CCLayer *clouds = [[CCLayer alloc] init];
//    clouds.position = CGPointZero;
    
    [self addChild:cloud1];
    [self addChild:cloud2];
    [self addChild:cloud3];
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [cloud1 setPosition:ccp(winSize.width/4,winSize.height*3/4)];
    [cloud2 setPosition:ccp(winSize.width*3/4,winSize.height*3/4)];
    [cloud3 setPosition:ccp(winSize.width/2,winSize.height/7)];
    
//    [self addChild:clouds];
}


- (void)initPlayer
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [[LHPlayer mainPlayer] addToLayer:self];
    [[LHPlayer mainPlayer] setPosition:CGPointMake(winSize.width/2, winSize.height * 0.7)];
    [self.nodes addObject:[LHPlayer mainPlayer]];
}

- (void)initSettings
{
    handInclinationX = 0.;
    handInclinationY = 0.;
    handInclinationZ = 0.;
    
    self.palmPos = ccp(0,0);
    
    [KKInput sharedInput].accelerometerActive = YES;
}

- (void)addPhysics
{
    CCLOG(@"%@ init", NSStringFromClass([self class]));
    // Construct a world object, which will hold and simulate the rigid bodies.
    b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
    world = new b2World(gravity);
    world->SetAllowSleeping(YES);
    //world->SetContinuousPhysics(YES);
    
    // uncomment this line to draw debug info
    [self enableBox2dDebugDrawing];
    
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float widthInMeters = winSize.width / PTM_RATIO;
    float heightInMeters = winSize.height / PTM_RATIO;
    b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
    b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
    b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
    b2EdgeShape screenBorderShape;
    
    // Create fixtures for the four borders (the border shape is re-used)
//    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
//    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
//    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
//    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
}

- (void)createTextures
{
    CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png"
                                                           capacity:TILESET_ROWS * TILESET_COLUMNS];
    [self addChild:batch z:0 tag:kTagBatchNode];
}

- (void)addLeapContainer {
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
    
    
    // random image with tag and class - LF contactListener
    MLContainerSprite *wtf = [MLContainerSprite spriteWithFile:@"line.png"];
    wtf.tag  = 1;
    wtf.opacity = 0;
    [self addChild:wtf];
    
    bodyDef.userData = (__bridge void*)wtf;

	bodyDef.position = [self toMeters:ccp(1440/2,300)];
	
	b2Body* body = world->CreateBody(&bodyDef);
	b2EdgeShape dynamicBox;
    
    float widthInMeters = 300 / PTM_RATIO;
    float heightInMeters = 100 / PTM_RATIO;
    float posX = 100/PTM_RATIO;
    
    b2Vec2 lowerLeftCorner = b2Vec2(posX, posX);
    b2Vec2 lowerRightCorner = b2Vec2(posX+widthInMeters, posX);
    b2Vec2 upperLeftCorner = b2Vec2(posX, posX+heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(posX+widthInMeters, posX+heightInMeters);

    dynamicBox.Set(lowerLeftCorner, lowerRightCorner);
    body->CreateFixture(&dynamicBox, 0);
    
    dynamicBox.Set(lowerRightCorner, upperRightCorner);
    body->CreateFixture(&dynamicBox, 0);
    
    dynamicBox.Set(lowerLeftCorner, upperLeftCorner);
    body->CreateFixture(&dynamicBox, 0);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 0.5f;
	fixtureDef.friction = 1.0f;
	fixtureDef.restitution = 0.5f;
	body->CreateFixture(&fixtureDef);
    
    container = body;
    
    container->SetSleepingAllowed(YES);
    container->SetAwake(NO);
    container->SetGravityScale(0);
}
- (void)addContainerForCircles
{
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
    
    
    // random image with tag and class - LF contactListener
    MLContainerSprite *wtf = [MLContainerSprite spriteWithFile:@"line.png"];
    wtf.tag  = 1;
    wtf.opacity = 0;
    [self addChild:wtf];
    
    bodyDef.userData = (__bridge void*)wtf;
    
	bodyDef.position = [self toMeters:ccp(100,0)];
	
	b2Body* body = world->CreateBody(&bodyDef);
	b2EdgeShape dynamicBox;
    
    float widthInMeters = 300 / PTM_RATIO;
    float heightInMeters = 100 / PTM_RATIO;
    float posX = 100/PTM_RATIO;
    
    b2Vec2 lowerLeftCorner = b2Vec2(posX, posX);
    b2Vec2 lowerRightCorner = b2Vec2(posX+widthInMeters, posX);
    b2Vec2 upperLeftCorner = b2Vec2(posX, posX+heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(posX+widthInMeters, posX+heightInMeters);
    
    dynamicBox.Set(lowerLeftCorner, lowerRightCorner);
    body->CreateFixture(&dynamicBox, 0);
    
    dynamicBox.Set(lowerRightCorner, upperRightCorner);
    body->CreateFixture(&dynamicBox, 0);
    
    dynamicBox.Set(lowerLeftCorner, upperLeftCorner);
    body->CreateFixture(&dynamicBox, 0);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 0.5f;
	fixtureDef.friction = 1.0f;
	fixtureDef.restitution = 0.5f;
	body->CreateFixture(&fixtureDef);
    
    b2Body *cont = body;
    
    cont->SetSleepingAllowed(YES);
    cont->SetAwake(NO);
    cont->SetGravityScale(0);
}

- (void)addContainerForSquares
{
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
    
    
    // random image with tag and class - LF contactListener
    MLContainerSprite *wtf = [MLContainerSprite spriteWithFile:@"line.png"];
    wtf.tag  = 1;
    wtf.opacity = 0;
    [self addChild:wtf];
    
    bodyDef.userData = (__bridge void*)wtf;
    
	bodyDef.position = [self toMeters:ccp(840,0)];
	
	b2Body* body = world->CreateBody(&bodyDef);
	b2EdgeShape dynamicBox;
    
    float widthInMeters = 300 / PTM_RATIO;
    float heightInMeters = 100 / PTM_RATIO;
    float posX = 100/PTM_RATIO;
    
    b2Vec2 lowerLeftCorner = b2Vec2(posX, posX);
    b2Vec2 lowerRightCorner = b2Vec2(posX+widthInMeters, posX);
    b2Vec2 upperLeftCorner = b2Vec2(posX, posX+heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(posX+widthInMeters, posX+heightInMeters);
    
    dynamicBox.Set(lowerLeftCorner, lowerRightCorner);
    body->CreateFixture(&dynamicBox, 0);
    
    dynamicBox.Set(lowerRightCorner, upperRightCorner);
    body->CreateFixture(&dynamicBox, 0);
    
    dynamicBox.Set(lowerLeftCorner, upperLeftCorner);
    body->CreateFixture(&dynamicBox, 0);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 0.5f;
	fixtureDef.friction = 1.0f;
	fixtureDef.restitution = 0.5f;
	body->CreateFixture(&fixtureDef);
    
    b2Body *cont = body;
    
    cont->SetSleepingAllowed(YES);
    cont->SetAwake(NO);
    cont->SetGravityScale(0);
}

-(void) dealloc
{
	delete contactListener;
	delete world;

#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(void) enableBox2dDebugDrawing
{
	const BOOL useBox2DDebugLayer = YES;
    
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;

	UInt32 debugDrawFlags = 0;
	debugDrawFlags += b2Draw::e_shapeBit;
	debugDrawFlags += b2Draw::e_jointBit;

	if (useBox2DDebugLayer) {
		Box2DDebugLayer* debugLayer = [Box2DDebugLayer debugLayerWithWorld:world
																  ptmRatio:PTM_RATIO
																	 flags:debugDrawFlags];
		[self addChild:debugLayer z:100];
	}
	else {
		debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
		if (debugDraw) {
			debugDraw->SetFlags(debugDrawFlags);
			world->SetDebugDraw(debugDraw);
		}
	}
}

-(void) bodyCreateFixture:(b2Body*)body
{
	b2PolygonShape dynamicBox;
	float tileInMeters = TILESIZE / PTM_RATIO;
	dynamicBox.SetAsBox(tileInMeters * 0.5f, tileInMeters * 0.5f);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 0.3f;
	fixtureDef.friction = 0.5f;
	fixtureDef.restitution = 0.6f;
	body->CreateFixture(&fixtureDef);
	
}

-(void) bodyCreateFixtureCircle:(b2Body*)body
{
	b2CircleShape circle;
	float tileInMeters = TILESIZE / PTM_RATIO;
	
    circle.m_radius = tileInMeters/2;
//    circle.m_p.Set(5.0f, 10.0f);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 0.3f;
	fixtureDef.friction = 0.5f;
	fixtureDef.restitution = 0.6f;
	body->CreateFixture(&fixtureDef);
	
}



-(void) addNewSpriteAt:(CGPoint)pos
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position = [self toMeters:pos];
    bodyDef.allowSleep   = NO;
    
    CCSprite *wtf2 = [CCSprite spriteWithFile:@"line.png"];
    wtf2.tag  = 0;
    wtf2.opacity = 0;
    [self addChild:wtf2];
    
    bodyDef.userData = (__bridge void*)wtf2;
	b2Body* body = world->CreateBody(&bodyDef);
	
    if (arc4random()%2)
        [self bodyCreateFixture:body];
    else
        [self bodyCreateFixtureCircle:body];
	
    
}

- (float)mod:(float) sth {
    return (sth>=0)?sth:-sth;
}

-(void) update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
	if (director.currentPlatformIsMac) {
		KKInput* input = [KKInput sharedInput];
		if (input.isAnyMouseButtonUpThisFrame || CGPointEqualToPoint(input.scrollWheelDelta, CGPointZero) == NO) {
			[self addNewSpriteAt:input.mouseLocation];
        }
        KKAcceleration* acceleration = input.acceleration;
//        b2Vec2 gravity = 0.5f * b2Vec2(-handInclinationY, -handInclinationX);
        b2Vec2 gravity = b2Vec2(0,-2);
        world->SetGravity(gravity);
	}
    
	float timeStep = 0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(timeStep, velocityIterations, positionIterations);
	
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext()) {
//        body->SetSleepingAllowed(YES);
//        body->SetLinearVelocity(b2Vec2(0, -1));
		CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
		if (sprite != NULL) {
			sprite.position = [self toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
		}
	}
 
    for (LHNode *node in self.nodes) {
        [node update:delta];
    }
}

- (void)updateContainerPosition:(ccTime)dt
{
//    container->SetTransform(b2Vec2(self.palmPos.x/PTM_RATIO, self.palmPos.y/PTM_RATIO), 0);
}
- (void)updatePlayerPosition:(ccTime)dt
{
    [[LHPlayer mainPlayer] setPosition:ccp(self.palmPos.x, self.palmPos.y)];
}

- (float)countScale
{
    float scale = self.palmZPos/100;
    float deviation = 0.3;
    
    
    if (scale > 1 + deviation)
        scale = 1 + deviation;
    if (scale < 1 - deviation)
        scale = 1 - deviation;
    
    return scale;
}

- (void)scalePlayer:(ccTime)dt
{
    [[LHPlayer mainPlayer] setScale:[self countScale]];
}

- (void)addFallingObject:(ccTime)dt
{
    CGPoint pos;
    pos.y = 1000;
    
    float posMinX = 100;
    float posMaxX = 1340;
    
    float random =( (int)arc4random() % (int)(posMaxX-posMinX))+posMinX;
    pos.x = random;
    
    [self addNewSpriteAt:pos];
}

- (void)returnContainerToScreenCenter
{
    b2Vec2 currentPosition;// = container->GetPosition();
    b2Vec2 targetPosition = [self toMeters:ccp(1440/2, 900/2)];
    
    container->SetTransform(b2Vec2(1440/(2*PTM_RATIO),
                                   900/(2*PTM_RATIO)), 0);
}

#pragma mark - convert methods

-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

- (CGPoint)convertLeapPalmPositionToScreenPos:(LeapVector*)leapPosition
{
    float xMax, xMin, yMax, yMin;
    xMax = 60;
    xMin = -xMax;
    
    yMax = 140;
    yMin = 80;
    
    xMax += (xMin<0)?-xMin:xMin;
    
    yMax += (yMin<0)?-yMin:yMin;
    
    CGPoint leapPoint = ccp(leapPosition.x-xMin,
                            leapPosition.y-yMin);
    
    return ccp(leapPoint.x * 1440/xMax, leapPoint.y *900/yMax);
}

#pragma mark - LEAP update

- (void)onFrame:(NSNotification *)notification;
{
    LeapController *myController = (LeapController *)[notification object];
    LeapFrame *frame = [myController frame:0];
    
    if ([[frame hands] count] != 0) {
        LeapHand *hand = [[frame hands] objectAtIndex:0];
        self.palmPos = [self convertLeapPalmPositionToScreenPos:[hand palmPosition]];
        self.palmZPos = [hand palmPosition].z;
    }
}


#pragma mark - LEAP methods

- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addListener:self];
    NSLog(@"running");
}

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification;
{
    NSLog(@"Connected");
    LeapController *aController = (LeapController *)[notification object];
    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:NO];
    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:NO];
    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:NO];
    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:NO];
}

- (void)onDisconnect:(NSNotification *)notification;
{
    NSLog(@"Disconnected");
}

- (void)onExit:(NSNotification *)notification;
{
    NSLog(@"Exited");
}

- (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}

#pragma mark - debug shit

#if DEBUG
-(void) draw
{
	[super draw];
    
	if (debugDraw) {
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
		kmGLPushMatrix();
		world->DrawDebugData();
		kmGLPopMatrix();
	}
}
#endif

@end

@implementation MLContainerSprite
@end
