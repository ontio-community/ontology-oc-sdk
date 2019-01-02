//
//  ONTIdentity.m
//  ONTWallet
//
//  Created by zhangyutao on 2018/12/20.
//  Copyright © 2018 zhangyutao. All rights reserved.
//

#import "ONTIdentity.h"
#import "crypto_scrypt.h"
#import "NSData+Extend.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"
#import "ONTMnemonicCode.h"
#import "ONTDeterministicKey.h"
#import "ONTECKey.h"
#import "IAGAesGcm.h"
#import "ONTStruct.h"

#import "ONTNativeBuildParams.h"
#import "ONTInvokeCode.h"
#import "ONTRpcApi.h"


@interface ONTIdentity ()

@property(nonatomic, readonly) NSString *password;

@end

@implementation ONTIdentity

- (instancetype)initWithName:(NSString *)name password:(NSString *)password {
    self = [super init];
    if (self) {
        _name = name;
        _password = password;
        
        // 随机数
        NSMutableData *randomData = [NSMutableData dataWithLength:16];
        int result = SecRandomCopyBytes(kSecRandomDefault, randomData.length, randomData.mutableBytes);
        if (result != noErr) {
            return nil;
        }
        // 助记词
        ONTMnemonicCode *mnemonicCode = [ONTMnemonicCode shareInstance];
        NSString *mnemonicText = [mnemonicCode toMnemonic:randomData];
        NSLog(@"助记词[%@]", mnemonicText);
        if (![mnemonicCode check:mnemonicText]) {
            return nil;
        }
        _mnemonicText = mnemonicText;
        
        NSData *seed = [mnemonicCode toSeed:[mnemonicText componentsSeparatedByString:@" "] withPassphrase:@""];
        
        ONTDeterministicKey *rootKey = [[ONTDeterministicKey alloc] initWithSeed:seed];
        
        NSMutableArray *path = [NSMutableArray new];
        [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:1024 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
        [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
        
        ONTECKey *ecKey = [[rootKey Derive:path] toECKey];
        _privateKey = [[ONTPrivateKey alloc] initWithData:ecKey.privateKeyAsData];
        _publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name password:(NSString *)password privateKeyHex:(NSString *)privateKeyHex {
    self = [super init];
    if (self) {
        _name = name;
        _password = password;
        
        ONTPrivateKey *privateKey = [[ONTPrivateKey alloc] initWithPrivateKeyHex:privateKeyHex];
        ONTECKey *ecKey = [[ONTECKey alloc] initWithPriKey:privateKey.data];
        _privateKey = [[ONTPrivateKey alloc] initWithData:ecKey.privateKeyAsData];
        _publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name password:(NSString *)password keystore:(NSString *)keystore {
    self = [super init];
    if (self) {
        _name = name;
        _password = password;
        
        // Keystore
        NSData *jsonData = [keystore dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *keystoreDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];
        if (error) {
            return nil;
        }
        // 检查参数
        if (![keystoreDic objectForKey:@"address"] ||
            ![keystoreDic objectForKey:@"salt"] ||
            ![keystoreDic objectForKey:@"key"] ||
            ![keystoreDic objectForKey:@"type"] ||
            ![keystoreDic objectForKey:@"algorithm"]) {
            return nil;
        }
        if (![[keystoreDic objectForKey:@"algorithm"] isEqualToString:@"ECDSA"] ||
            ![[keystoreDic objectForKey:@"type"] isEqualToString:@"I"]) {
            return nil;
        }
        if (name == nil && [keystoreDic objectForKey:@"label"]) {
            _name = [keystoreDic objectForKey:@"label"];
        }
        int n = [keystoreDic[@"scrypt"][@"n"] intValue];
        int r = [keystoreDic[@"scrypt"][@"r"] intValue];
        int p = [keystoreDic[@"scrypt"][@"p"] intValue];
        int dkLen = [keystoreDic[@"scrypt"][@"dkLen"] intValue];
        char stop = 0;
        
        NSData *passwordData = [[_password precomposedStringWithCompatibilityMapping] dataUsingEncoding:NSUTF8StringEncoding];
        NSData *salt = [NSData decodeBase64:[keystoreDic objectForKey:@"salt"]];
        
        NSString *address = [keystoreDic objectForKey:@"address"];
        
        NSData *key = [NSData decodeBase64:[keystoreDic objectForKey:@"key"]];
        
        NSMutableData *derivedkey = [NSMutableData dataWithLength:dkLen];
        int status = crypto_scrypt(passwordData.bytes, (int)passwordData.length, salt.bytes, salt.length, n, r, p, derivedkey.mutableBytes,derivedkey.length, &stop);
        // Bad scrypt parameters
        if (status == -1) {
            NSLog(@"Bad scrypt parameters");
            return nil;
        }
        NSData *derivedhalf2 = [derivedkey subdataWithRange:NSMakeRange(32, 32)];
        NSData *iv = [derivedkey subdataWithRange:NSMakeRange(0, 12)];
        
        // AES GCM
        NSData *encryptedkey = [key subdataWithRange:NSMakeRange(0, key.length-IAGAuthenticationTagLength128)];
        NSData *tag = [key subdataWithRange:NSMakeRange(key.length-IAGAuthenticationTagLength128,IAGAuthenticationTagLength128)];
        NSData *aad = [address dataUsingEncoding:NSUTF8StringEncoding];
        NSData *privateKeyData = [encryptedkey aesGcm128Decrypt:derivedhalf2 iv:iv aad:aad tag:tag];
        if (!privateKeyData) {
            return nil;
        }
        // Account
        ONTECKey *ecKey = [[ONTECKey alloc] initWithPriKey:privateKeyData];
        _privateKey = [[ONTPrivateKey alloc] initWithData:ecKey.privateKeyAsData];
        _publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
        NSLog(@"%@", _publicKey.toAddress.address);
        if (![_publicKey.toAddress.address isEqualToString:address]) {
            return nil;
        }
    }
    return self;
}

- (ONTAddress *)address {
    return _publicKey.toAddress;
}

- (NSString *)ontid {
    return [self.address generateOntid];
}

- (NSString *)keystore {
    return [self encrypt:self.password];
}

// 加密
- (NSString *)encrypt:(NSString *)password {
    int n = 4096;
    int r = 8;
    int p = 8;
    int dkLen = 64;
    char stop = 0;
    
    // Salt
    NSData *salt = [NSData randomWithSize:16];
    // Result
    NSMutableDictionary *keystore = [NSMutableDictionary dictionary];
    [keystore setObject:@"I" forKey:@"type"];
    [keystore setObject:_name forKey:@"label"];
    [keystore setObject:_publicKey.toAddress.address forKey:@"address"];
    [keystore setObject:@{
                          @"r":@(r),
                          @"p":@(p),
                          @"n":@(n),
                          @"dkLen":@(dkLen)
                          } forKey:@"scrypt"];
    [keystore setObject:@{
                          @"curve":@"P-256"
                          } forKey:@"parameters"];
    [keystore setObject:@"ECDSA" forKey:@"algorithm"];
    [keystore setObject:[[NSString alloc] initWithData:salt.base64 encoding:NSUTF8StringEncoding] forKey:@"salt"];
    
    // Private Key
    NSData *passwordData = [[password precomposedStringWithCompatibilityMapping] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *derivedkey = [NSMutableData dataWithLength:dkLen];
    int status = crypto_scrypt(passwordData.bytes, (int)passwordData.length, salt.bytes, salt.length, n, r, p, derivedkey.mutableBytes,derivedkey.length, &stop);
    // Bad scrypt parameters
    if (status == -1) {
        NSLog(@"Bad scrypt parameters");
        return nil;
    }
    NSData *derivedhalf2 = [derivedkey subdataWithRange:NSMakeRange(32, 32)];
    NSData *iv = [derivedkey subdataWithRange:NSMakeRange(0, 12)];
    
    // AES GCM
    NSData *aad = [_publicKey.toAddress.address dataUsingEncoding:NSUTF8StringEncoding];
    IAGCipheredData *cipheredData  = [_privateKey.data aesGcm128Encrypt:derivedhalf2 iv:iv aad:aad];
    
    // Key
    NSMutableData *key = [NSMutableData new];
    [key appendData:[NSData dataWithBytes:cipheredData.cipheredBuffer length:cipheredData.cipheredBufferLength]];
    [key appendData:[NSData dataWithBytes:cipheredData.authenticationTag length:cipheredData.authenticationTagLength]];
    [keystore setObject:[[NSString alloc] initWithData:key.base64 encoding:NSUTF8StringEncoding] forKey:@"key"];
    
    // Json -> String
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:keystore
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (ONTTransaction *)makeRegisterOntIdTxWithPayer:(ONTAccount *)payer gasPrice:(long)gasPrice gasLimit:(long)gasLimit {
    ONTECKey *ecKeyID = [[ONTECKey alloc] initWithPriKey:self.privateKey.data];
    
    ONTECKey *ecKeyPayer = nil;
    ONTPublicKey *publicKeyPayer = nil;
    ONTAddress *addressPayer = nil;
    if (payer) {
        ecKeyPayer = [[ONTECKey alloc] initWithPriKey:payer.privateKey.data];
        publicKeyPayer = [[ONTPublicKey alloc] initWithData:ecKeyPayer.publicKeyAsData];
        addressPayer = publicKeyPayer.toAddress;
    }
    
    ONTAddress *contractAddress = [[ONTAddress alloc] initWithData:ONTID_CONTRACT.hexToData];
    
    ONTStruct *ontStruct = [[ONTStruct alloc] init];
    [ontStruct add:[self.ontid dataUsingEncoding:NSUTF8StringEncoding]];
    [ontStruct add:self.publicKey.data];
    
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:ontStruct];
    
    NSData *args = [ONTNativeBuildParams createCodeParamsScript:array];
    ONTTransaction *transaction = [ONTInvokeCode invokeCodeTransaction:contractAddress initMethod:@"regIDWithPublicKey" args:args payer:addressPayer?addressPayer:self.address gasLimit:gasLimit gasPrice:gasPrice];
    
    // 签名
    ECKeySignature *sign = [ecKeyID sign:transaction.getSignHash];
    [transaction.signatures addObject:[[ONTSignature alloc] initWithPublicKey:ecKeyID.publicKeyAsData signature:sign.toDataNoV]];
    // 付款者是否是自己
    if (payer && ![addressPayer.address isEqualToString:self.address.address]) {
        ECKeySignature *signPayer = [ecKeyPayer sign:transaction.getSignHash];
        [transaction.signatures addObject:[[ONTSignature alloc] initWithPublicKey:ecKeyPayer.publicKeyAsData signature:signPayer.toDataNoV]];
    }
    
    return transaction;
}

- (ONTTransaction *)getDDOTx {
    //ONTECKey *ecKeyID = [[ONTECKey alloc] initWithPriKey:self.privateKey.data];
    
    ONTAddress *contractAddress = [[ONTAddress alloc] initWithData:ONTID_CONTRACT.hexToData];
    
    ONTStruct *ontStruct = [[ONTStruct alloc] init];
    [ontStruct add:[self.ontid dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:ontStruct];
    
    NSData *args = [ONTNativeBuildParams createCodeParamsScript:array];
    ONTTransaction *transaction = [ONTInvokeCode invokeCodeTransaction:contractAddress initMethod:@"getDDO" args:args payer:nil gasLimit:0 gasPrice:0];
    
    // 签名
    //ECKeySignature *sign = [ecKeyID sign:transaction.getSignHash];
    //[transaction.signatures addObject:[[ONTSignature alloc] initWithPublicKey:ecKeyID.publicKeyAsData signature:sign.toDataNoV]];
    
    return transaction;
}

- (ONTTransaction *)getDDOTxWithPayer:(ONTAccount *)payer gasPrice:(long)gasPrice gasLimit:(long)gasLimit {
    return nil;
}

@end
