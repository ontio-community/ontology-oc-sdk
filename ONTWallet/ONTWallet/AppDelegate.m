//
//  AppDelegate.m
//  ONTWallet
//
//  Created by zhangyutao on 2018/7/13.
//  Copyright © 2018年 zhangyutao. All rights reserved.
//

#import "AppDelegate.h"
#import "ONTIdentity.h"
#import "ONTRpcApi.h"
#import "Categories.h"

#import "ONTScriptReader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // [self test];
    
    return YES;
}

- (void)test {
    NSString *result = @"2601000000210337c3fb6397eda039aee7212e09d250817323290b13e6ade1ac7d3cb6011ab9fe0000";
    NSString *ontId = @"did:ont:AZM2REuZzty8MmhWX5ANUUxEpqNzHDmxkX";
    
    /*
     {
         Attributes = [],
         OntId = AZM2REuZzty8MmhWX5ANUUxEpqNzHDmxkX,
         Owners = [{
             Type = ECDSA,
             Curve = P - 256,
             Value = 0337 c3fb6397eda039aee7212e09d250817323290b13e6ade1ac7d3cb6011ab9fe,
             PubKeyId = AZM2REuZzty8MmhWX5ANUUxEpqNzHDmxkX# keys - 1
         }]
     }
     */
    ONTScriptReader *reader = [[ONTScriptReader alloc] initWithData:result.hexToData];
    NSData *publicKey;
    NSData *attribute;
    NSData *recovery;
    
    publicKey = [reader readVarData];
    
    attribute = [reader readVarData];
    
    recovery = [reader readVarData];
    
    if (publicKey.length != 0) {
        ONTScriptReader *pubkeyReader = [[ONTScriptReader alloc] initWithData:publicKey];
        while (YES) {
            uint32_t keys = [pubkeyReader readUInt32LE];
            if (keys == 0) {
                break;
            }
            NSData *pubKey = [pubkeyReader readVarData];
            Byte key;
            [pubKey getBytes:&key range:NSMakeRange(0, 1)];
            
            Byte curve;
            [pubKey getBytes:&curve range:NSMakeRange(1, 1)];
            
            NSLog(@"PubKeyId:%@ #keys-%d",ontId,keys);
            if (pubKey.length == 33) {
                NSLog(@"Type:%@",@"ECDSA");
                NSLog(@"Curve:%@",@"P-256");
                NSLog(@"Value:%@",pubKey.hexString);
            } else {
                Byte key;
                [pubKey getBytes:&key range:NSMakeRange(0, 1)];
                
                Byte curve;
                [pubKey getBytes:&curve range:NSMakeRange(1, 1)];
                
                NSLog(@"Key:%@",[self keyType:key]);
                NSLog(@"Curve:%@",@"");
                NSLog(@"Value:%@",pubKey.hexString);
            }
        }
    }
    if (attribute.length != 0) {
        ONTScriptReader *attributeReader = [[ONTScriptReader alloc] initWithData:attribute];
        while (YES) {
            NSData *key = [attributeReader readVarData];
            if (!key && key.length == 0) {
                break;
            }
            NSLog(@"Key:%@",key);
            NSLog(@"Type:%@",[attributeReader readVarData]);
            NSLog(@"Value:%@",[attributeReader readVarData]);
        }
    }
}

- (NSString *)keyType:(Byte)byte {
    switch (byte) {
        case 0x12:
            return @"ECDSA";
        case 0x13:
            return @"SM2";
        default:
            return @"EDDSA";
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
