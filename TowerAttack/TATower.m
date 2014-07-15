//
//  TATower.m
//  TowerAttack
//
//  Created by Ethan Hardy on 2014-07-07.
//  Copyright (c) 2014 Ethan Hardy. All rights reserved.
//

#import "TATower.h"
#import "TABattleScene.h"
#import "TAEnemy.h"
#import "TAUIOverlay.h"
#import "TATowerInfoPanel.h"

NSInteger const towerHeightAndWidth = 50;
NSInteger const maxTowerLevel = 5;
NSArray *towerStatsForLevel;

@implementation TATower

-(id)initWithImageNamed:(NSString *)name andLocation:(CGPoint)location inScene:(TABattleScene *)sceneParam
{
    if (self == [super initWithImageNamed:name andLocation:location inScene:sceneParam]) {
        //init code
         towerStatsForLevel = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Game Data" ofType:@"plist"]] objectForKey:@"TowerStatsForLevel"];
        
        self.attackRadius = 100;
        self.towerLevel = 1;
        self.timeBetweenAttacks = [[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] substringFromIndex:[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] rangeOfString:@" "].location] floatValue];
        self.attackDamage = [[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] substringToIndex:[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] rangeOfString:@" "].location] integerValue];
        self.isAttacking = NO;
        self.projectileSpeed = 400;
        self.enemiesInRange = [NSMutableSet set];
        self.purchaseCost = 50;
        self.description = @"A generic tower, this unit shoots enemies within its range with bolts of fire.";
        self.imageName = @"Tower";
        self.unitType = @"Tower";
        
        self.size = CGSizeMake(towerHeightAndWidth, towerHeightAndWidth);
        self.name =  [NSString stringWithFormat:@"Tower %lu", (unsigned long)[self.battleScene.towersOnField count]];
        
        self.zPosition = 0.1;
        self.physicsBody.contactTestBitMask = TAContactTypeEnemy;
        self.physicsBody.categoryBitMask = TAContactTypeTower;
        self.physicsBody.collisionBitMask = TAContactTypeNothing;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(self.size.width - 4) / 2];
        self.physicsBody.dynamic = NO;
        
        //SKNode *collisionDetection = [SKNode node];
        SKSpriteNode *collisionDetection = [SKSpriteNode spriteNodeWithImageNamed:@"TowerRadius"];
        collisionDetection.size = CGSizeMake(self.attackRadius * 2, self.attackRadius * 2);
        collisionDetection.alpha = 0.3;
        collisionDetection.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.attackRadius];
        collisionDetection.name = [NSString stringWithFormat:@"Detector %lu", (unsigned long)[self.battleScene.towersOnField count]];
        collisionDetection.position = self.position;
        collisionDetection.physicsBody.contactTestBitMask = TAContactTypeEnemy;
        collisionDetection.physicsBody.categoryBitMask = TAContactTypeDetector;
        collisionDetection.physicsBody.collisionBitMask = TAContactTypeNothing;
        collisionDetection.physicsBody.dynamic = NO;
        [self.battleScene addChild:collisionDetection];
        
        [self runAction:[SKAction playSoundFileNamed:@"TowerPlaced.wav" waitForCompletion:NO]];
    }
    return self;
}

-(void)beginAttackOnEnemy:(TAEnemy *)enemy
{
  //  NSLog(@"Begin");
    self.attackUpdate = [NSTimer scheduledTimerWithTimeInterval:self.timeBetweenAttacks target:self selector:@selector(fireProjectileCalledByTimer:) userInfo:enemy repeats:YES];
    self.isAttacking = YES;
}

-(void)fireProjectileCalledByTimer:(NSTimer *)timer
{
    //code to show projectile
  //  NSLog(@"%@ shot",self.name);
    TAEnemy *enemy = (TAEnemy *)[timer userInfo];
    SKEmitterNode *projectileToFire = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Projectile" ofType:@"sks"]];
    projectileToFire.position = self.position;
    [self.battleScene addChild:projectileToFire];
    [projectileToFire runAction:[SKAction moveTo:enemy.position
                                        duration:[self.battleScene distanceFromA:self.position
                                                                             toB:enemy.position]/ (self.projectileSpeed + 50)]
                     completion:^{
                         [projectileToFire removeFromParent];
                         [enemy setCurrentHealth:enemy.currentHealth - self.attackDamage];
                        // NSLog(@"Hit; enemy health = %d",enemy.currentHealth);
                         if ([enemy currentHealth] <= 0) {
                             [self.enemiesInRange removeObject:enemy];
                             [self endAttack];
                         }
                     }];
    if ([self.enemiesInRange count] == 0) {
        [self endAttack];
    }
}

-(void)endAttack
{
  //  NSLog(@"End");
    [self.attackUpdate invalidate];
    if ([self.enemiesInRange count] > 0) {
        self.attackUpdate = [NSTimer scheduledTimerWithTimeInterval:self.timeBetweenAttacks target:self selector:@selector(fireProjectileCalledByTimer:) userInfo:[self.enemiesInRange anyObject] repeats:YES];
    }
    else {
        self.isAttacking = NO;
    }
}

-(void)setTowerLevel:(NSUInteger)towerLevel
{
    _towerLevel = towerLevel;
    self.timeBetweenAttacks = [[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] substringFromIndex:[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] rangeOfString:@" "].location] floatValue];
    self.attackDamage = [[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] substringToIndex:[(NSString *)[towerStatsForLevel objectAtIndex:self.towerLevel-1] rangeOfString:@" "].location] integerValue];
    [(UILabel *)[self.battleScene.uiOverlay.infoPanel.additionalUnitInfo objectAtIndex:0] setText:[NSString stringWithFormat:@"Level: %lu",(unsigned long)self.towerLevel]];
    [(UILabel *)[self.battleScene.uiOverlay.infoPanel.additionalUnitInfo objectAtIndex:1] setText:[NSString stringWithFormat:@"Damage: %lu",(unsigned long)self.attackDamage]];
    [(UILabel *)[self.battleScene.uiOverlay.infoPanel.additionalUnitInfo objectAtIndex:2] setText:[NSString stringWithFormat:@"%g shots/second",self.timeBetweenAttacks]];
    
}


@end
