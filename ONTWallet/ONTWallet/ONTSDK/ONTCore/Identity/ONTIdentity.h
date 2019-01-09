//
//  ONTIdentity.h
//  ONTWallet
//
//  Created by zhangyutao on 2018/12/20.
//  Copyright © 2018 zhangyutao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONTPublicKey.h"
#import "ONTPrivateKey.h"
#import "ONTAddress.h"
#import "ONTAccount.h"
#import "ONTTransaction.h"

#define ONTID_CONTRACT @"0000000000000000000000000000000000000003"


@interface ONTIdentity : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *ontid;
@property (nonatomic, readonly) NSString *mnemonicText;
@property (nonatomic, readonly) NSString *keystore;
@property (nonatomic, readonly) ONTPrivateKey *privateKey;
@property (nonatomic, readonly) ONTPublicKey *publicKey;
@property (nonatomic, readonly) ONTAddress *address;


- (instancetype)initWithName:(NSString *)name password:(NSString *)password;

- (instancetype)initWithName:(NSString *)name password:(NSString *)password privateKeyHex:(NSString *)privateKeyHex;

- (instancetype)initWithName:(NSString *)name password:(NSString *)password keystore:(NSString *)keystore;


- (ONTTransaction *)makeRegisterOntIdTxWithPayer:(ONTAccount *)payer gasPrice:(long)gasPrice gasLimit:(long)gasLimit;

+ (ONTTransaction *)makeGetDDOTransactionWithOntid:(NSString *)ontid;

+ (NSDictionary *)parserDDODataWithOntid:(NSString *)ontid result:(NSString *)result;

@end
