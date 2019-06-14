//
//  ViewController.m
//  ONTWallet
//
//  Created by zhangyutao on 2018/7/13.
//  Copyright © 2018年 zhangyutao. All rights reserved.
//

#import "ViewController.h"
#import "ONT.h"
#import "Categories.h"
#import "ONTUtils.h"
#import "ONTAccount.h"
#import "ONTRpcApi.h"
#import "ONTBalance.h"
#import "ONTMnemonicCode.h"

#import "Oep4.h"
#import "NeoVM.h"

#import "ONTIdentity.h"

@interface ViewController ()

@property(nonatomic, strong) NSString *privateKey;
@property(nonatomic, strong) NSString *contractAddress;

@end

@implementation ViewController

- (void)configData {
    // 地址：AQf4Mzu1YJrhz9f3aRkkwSm9n3qhXGSh4p
    _privateKey = @"5f2fe68215476abb9852cfa7da31ef00aa1468782d5ca809da5c4e1390b8ee45";
    
    // OEP4 Token: MyToken、MYT、8
    _contractAddress = @"b0bc9d8eb833c9903fa2e794f8413f6366f721ce";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Config Data
    [self configData];
    
    // Creat wallet
    //[self testCreateNewWallet];
    
    // Import Wallet
    [self testImportWalletWithWIF];
    
    // GET Get Best Block Hash
    //[self testGetBestBlockHash];
    
    // GET Block With TxHash
    //[self testGetBlockWithTxHash];
    
    // GET Block With Height
    //[self testGetBlockWithHeight];
    
    //GET Block Count
    //[self testGetBlockCount];
    
    //GET Block Hash With Height
    //[self testGetBlockHashWithHeight];
    
    //GET Connection Count
    //[self testGetConnectionCount];
    
    //GET Rawtransaction With TxHash
    //[self testGetRawtransactionWithTxHash];
    
    // Send ONT
    //[self testSendONT];
    
    // Send ONG
    //[self testSendONG];
    
    // Claim ONG
    //[self testClaimONG];
    
    //GET Storage WithScript Hash
    //[self testGetStorageWithScriptHash];
    
    //GET Version
    //[self testGetVersion];
    
    //GET Contract State With ScriptHash
    //[self testGetContractStateWithScriptHash];
    
    //Get Mempool TxCount
    //[self testGetMempoolTxCount];
    
    //Get Mempool TxState With TxHash
    //[self testGetMempoolTxStateWithTxHash];
    
    //Get Smart Code Event With TxHash
    //[self testGetSmartCodeEventWithTxHash];
    
    //Get Smart Code Event With Block Height
    //[self testGetSmartCodeEventWithBlockHeight];
    
    //Get Block Height With Txhash
    //[self testGetBlockHeightWithTxhash];
    
    //GET Balance
    //[self testGetBalabce];
    
    // Get Merkle Proof With TxHash
    //[self testGetMerkleProofWithTxHash];
    
    // GET Gas Price
    //[self testGetGasPrice];
    
    // Get Allowance With Asset ONT
    //[self testGetAllowanceWithAssetONT];
    
    // Get Allowance With Asset ONG
    //[self testGetAllowanceWithAssetONG];
    
    // GET Unbound Ong
    //[self testGetUnboundOng];
    
    // Get Block Txs With Height
    //[self testGetBlockTxsWithHeight];
    
    // Get Network ID
    //[self testGetNetworkID];
    
    
    // OEP4
    
    //[self testOep4Init];
    
    //[self testOep4QueryBalanceOf];
    //[self testOep4QueryDecimals];
    //[self testOep4Queries];
    
    //[self testSendOep4];
    
    //[self testOep4Approve];
    //[self testOep4SendTransferFrom];
    //[self testOep4QueryAllowance];
    
    
    // ONTID
    
    //[self testCreateOntid];
    //[self testRegisterOntid];
    //[self testImportOntid];
    //[self testGetDDO];
    //[self testParseDDO];
}

- (void)testCreateNewWallet {
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT123ont"];
    NSLog(@"=== 【ONTAccount】=== \n%@", account.description);
    NSLog(@"=== 【ONTAccount】=== \n%@", account.encryptMnemonicText);
    NSString *mnemonicText = [ONTMnemonicCode decryptMnemonicCode:account.encryptMnemonicText password:@"ONT123ont" address:account.address.address];
    if ([mnemonicText isEqualToString:account.mnemonicText]) {
        NSLog(@"助记词解析正确！！！");
    } else {
        NSLog(@"助记词解析错误！！！");
    }
}

- (void)testImportWalletWithWIF {
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT123ont" wif:@"L3WY9S4BWcz9PLY9LpbayXU6meg9VzgbJRaNQCReYbhNVGQEQ9FQ"];
    if (account) {
        NSLog(@"导入成功：address = %@", account.address.address);
    } else {
        NSLog(@"WIF 错误！！！");
    }
}

- (void)testGetBestBlockHash {
    [[ONTRpcApi shareInstance] getBestBlockHashCallback:^(NSString *txHash, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"txHash == %@", txHash);
        }
    }];
}

- (void)testGetBlockWithTxHash {
    [[ONTRpcApi shareInstance] getBlockWithTxHash:@"8d1e6acf0e304cba71e92fb47cb67e72b586b646508cee941405bb2e2dddaee2" verbose:NO callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetBlockWithHeight {
    [[ONTRpcApi shareInstance] getBlockWithHeight:108172 verbose:NO callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetBlockCount {
    [[ONTRpcApi shareInstance] getBlockCountCallback:^(NSInteger blockCount, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"blockCount == %ld", (long)blockCount);
        }
    }];
}

- (void)testGetBlockHashWithHeight {
    [[ONTRpcApi shareInstance] getBlockHashWithHeight:108172 callback:^(NSString *txHash, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"txHash == %@", txHash);
        }
    }];
}

- (void)testGetConnectionCount {
    [[ONTRpcApi shareInstance] getConnectionCountCallback:^(NSInteger connectionCount, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"connectionCount == %ld", (long)connectionCount);
        }
    }];
}

- (void)testGetRawtransactionWithTxHash {
    [[ONTRpcApi shareInstance] getRawtransactionWithTxHash:@"8d1e6acf0e304cba71e92fb47cb67e72b586b646508cee941405bb2e2dddaee2" verbose:YES callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testSendONT {
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT1234567890" wif:@"L2pGnv7waHczPursyuGDCBBU6GuoVBHkKF6uKjeFfiy584LQUqir"];
    NSString *txHex = [account makeTransferTxWithToken:ONTTokenTypeONT toAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" amount:@"10" gasPrice:500 gasLimit:20000];
    NSLog(@"txHex == %@", txHex);
    
    [[ONTRpcApi shareInstance] sendRawtransactionWithHexTx:txHex preExec:NO callback:^(NSString *txHash, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"txHash == %@", txHash);
            NSLog(@"View on explorer：%@", kONTScanTxURL(txHash));
        }
    }];
}

- (void)testSendONG {
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT1234567890" wif:@"L2pGnv7waHczPursyuGDCBBU6GuoVBHkKF6uKjeFfiy584LQUqir"];
    NSString *txHex = [account makeTransferTxWithToken:ONTTokenTypeONG toAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" amount:@"3" gasPrice:500 gasLimit:20000];
    NSLog(@"txHex == %@", txHex);
    
    [[ONTRpcApi shareInstance] sendRawtransactionWithHexTx:txHex preExec:NO callback:^(NSString *txHash, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"txHash == %@", txHash);
            NSLog(@"View on explorer：%@", kONTScanTxURL(txHash));
        }
    }];
}

- (void)testClaimONG {
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT1234567890" wif:@"L2pGnv7waHczPursyuGDCBBU6GuoVBHkKF6uKjeFfiy584LQUqir"];
    NSString *txHex = [account makeClaimOngTxWithAddress:account.address.address amount:@"0.000000001" gasPrice:500 gasLimit:20000];
    NSLog(@"Claim ONG txHex == %@", txHex);
    
    [[ONTRpcApi shareInstance] sendRawtransactionWithHexTx:txHex preExec:NO callback:^(NSString *txHash, NSError *error) {
        NSLog(@"txHash == %@,error:%@",txHash, error);
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"txHash == %@", txHash);
            NSLog(@"View on explorer：%@", kONTScanTxURL(txHash));
        }
    }];
}

- (void)testGetStorageWithScriptHash {
    [[ONTRpcApi shareInstance] getStorageWithScriptHash:@"03febccf81ac85e3d795bc5cbd4e84e907812aa3" key:@"5065746572" callback:^(id result, NSError *error) {
    }];
}

- (void)testGetVersion {
    [[ONTRpcApi shareInstance] getVersionCallback:^(id result, NSError *error) {
    }];
}

- (void)testGetContractStateWithScriptHash {
    [[ONTRpcApi shareInstance] getContractStateWithScriptHash:@"0239dcf9b4a46f15c5f23f20d52fac916a0bac0d" verbose:YES  callback:^(id result, NSError *error) {
    }];
}

- (void)testGetMempoolTxCount {
    [[ONTRpcApi shareInstance] getMempoolTxCountCallback:^(id result, NSError *error) {
    }];
}

- (void)testGetMempoolTxStateWithTxHash {
    [[ONTRpcApi shareInstance] getMempoolTxStateWithTxHash:@"8d1e6acf0e304cba71e92fb47cb67e72b586b646508cee941405bb2e2dddaee2" callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetSmartCodeEventWithTxHash {
    [[ONTRpcApi shareInstance] getSmartCodeEventWithTxHash:@"8d1e6acf0e304cba71e92fb47cb67e72b586b646508cee941405bb2e2dddaee2" callback:^(NSInteger state, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"state == %ld", (long)state);
        }
    }];
}

- (void)testGetSmartCodeEventWithBlockHeight {
    [[ONTRpcApi shareInstance] getSmartCodeEventWithBlockHeight:108172 callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetBlockHeightWithTxhash {
    [[ONTRpcApi shareInstance] getBlockHeightWithTxhash:@"8d1e6acf0e304cba71e92fb47cb67e72b586b646508cee941405bb2e2dddaee2" callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetBalabce {
    [[ONTRpcApi shareInstance] getBalanceWithAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" callback:^(NSArray *balances, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            for (ONTBalance *balance in balances) {
                NSLog(@"%@ == %@", balance.name, balance.balances);
            }
        }
    }];
}

- (void)testGetMerkleProofWithTxHash {
    [[ONTRpcApi shareInstance] getMerkleProofWithTxHash:@"8d1e6acf0e304cba71e92fb47cb67e72b586b646508cee941405bb2e2dddaee2" callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetGasPrice {
    [[ONTRpcApi shareInstance] getGaspriceCallback:^(NSString *gasprice, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"gasprice == %@", gasprice);
        }
    }];
}

- (void)testGetAllowanceWithAssetONT {
    [[ONTRpcApi shareInstance] getAllowanceWithAsset:@"ONT" fromAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" toAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetAllowanceWithAssetONG {
    [[ONTRpcApi shareInstance] getAllowanceWithAsset:@"ONG" fromAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" toAddress:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetUnboundOng {
    [[ONTRpcApi shareInstance] getUnboundOng:@"AatvPQVe1RECTqoAxe9FtSdWGnABVjMExv" callback:^(NSString *amount, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"amount == %@", amount);
            NSLog(@"amount == %@", [ONTUtils decimalNumber:amount byDividingBy:@"1000000000"]);
        }
    }];
}

- (void)testGetBlockTxsWithHeight {
    [[ONTRpcApi shareInstance] getBlockTxsWithHeight:108172 callback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}

- (void)testGetNetworkID {
    [[ONTRpcApi shareInstance] getNetworkIDCallback:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"result == %@", result);
        }
    }];
}


#pragma mark - OEP4
- (void)testOep4Init {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;
    
    ONTAccount *acct = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT1234567890" wif:@"L2pGnv7waHczPursyuGDCBBU6GuoVBHkKF6uKjeFfiy584LQUqir"];
    
    NSLog(@"from address:%@", acct.address.address);
    
    BOOL isPreExec = YES;
    [[NeoVM shareInstance].oep4 sendInit:acct
                              byGasPayer:acct
                             useGasLimit:0//10000000
                             useGasPrice:0//500
                                 preExec:isPreExec
                           queryCallback:^(id result, NSError *error) {
                               if (error) {
                                   NSLog(@"error == %@", error);
                               } else {
                                   if (isPreExec) {
                                       NSLog(@"result == %@", result);
                                   } else {
                                       NSString *txhash = (NSString *)result;
                                       NSLog(@"txhash == %@", txhash);
                                       
                                       [self testOep4QueryBalanceOf];
                                   }
                               }
                           }];
}

- (void)testOep4QueryBalanceOf {
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT" password:@"123456" privateKeyHex:_privateKey];
    NSLog(@"%@", account.address.address);

    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;

    [[NeoVM shareInstance].oep4 queryBalanceOf:account.address.address queryCallback:^(NSString *balance, NSError *error) {
        NSLog(@"balance == %@, %@", balance, [error localizedDescription]);
    }];
}

- (void)testOep4QueryDecimals {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;
    
    [[NeoVM shareInstance].oep4 queryDecimalsWithQueryCallback:^(NSString *result, NSError *error) {
        NSLog(@"result == %@, %@", result, [error localizedDescription]);
    }];
}

- (void)testOep4Queries {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;
    
    [[NeoVM shareInstance].oep4 queryTotalSupply:^(NSString *result, NSError *error) {
        NSLog(@"result == %@, %@", result, [error localizedDescription]);
    }];
    [[NeoVM shareInstance].oep4 queryName:^(NSString *result, NSError *error) {
        NSLog(@"result == %@, %@", result, [error localizedDescription]);
    }];
    [[NeoVM shareInstance].oep4 querySymbol:^(NSString *result, NSError *error) {
        NSLog(@"result == %@, %@", result, [error localizedDescription]);
    }];
}

- (void)testSendOep4 {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;

    ONTAccount *from = [[ONTAccount alloc] initWithName:@"ONT" password:@"123456" privateKeyHex:_privateKey];
    NSLog(@"from address:%@", from.address.address);

    BOOL isPreExec = NO;
    [[NeoVM shareInstance].oep4 sendTransfer:from
                                          to:@"ASrLANryFnqwSt76h2YbhssdZeRGagRYem"
                                  withAmount:100000000
                                  byGasPayer:from
                                 useGasLimit:20000
                                 useGasPrice:500
                                     preExec:isPreExec
                               queryCallback:^(id result, NSError *error) {
                                   if (error) {
                                       NSLog(@"error == %@", error);
                                   } else {
                                       if (isPreExec) {
                                           NSLog(@"result == %@", result);
                                       } else {
                                           NSString *txhash = (NSString *)result;
                                           NSLog(@"txhash == %@", txhash);

                                           [self testOep4QueryBalanceOf];
                                       }
                                   }
                               }];
}

- (void)testOep4Approve {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;
    
    ONTAccount *owner = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT1234567890" wif:@"L2pGnv7waHczPursyuGDCBBU6GuoVBHkKF6uKjeFfiy584LQUqir"];
    NSLog(@"from address:%@", owner.address.address);
    
    BOOL isPreExec = NO;
    [[NeoVM shareInstance].oep4 sendApprove:owner
                                  toSpender:@"AUvfyDwjEeCrBZWYTakazA9hQVQnaxYX46"
                                 withAmount:100000000
                                 byGasPayer:owner
                                useGasLimit:20000
                                useGasPrice:500
                                    preExec:isPreExec
                              queryCallback:^(id result, NSError *error) {
                                  if (isPreExec) {
                                      NSLog(@"result == %@", result);
                                  } else {
                                      NSString *txhash = (NSString *)result;
                                      NSLog(@"txhash == %@", txhash);
                                      
                                      [self testOep4QueryAllowance];
                                  }
                              }];
}

- (void)testOep4SendTransferFrom {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;
    
    //ONTAccount *sender = [[ONTAccount alloc] initWithName:@"ONT-Wallet" password:@"ONT123ont" wif:@"L44EwAY5X8afopnLxbytoU9KGH9pCZP37WxrvnDgvMkei9wrBfUe"];
    ONTAccount *sender = [[ONTAccount alloc] initWithName:@"ONT" password:@"123456" privateKeyHex:_privateKey];
    
    NSLog(@"from address:%@", sender.address.address);
    
    BOOL isPreExec = NO;
    [[NeoVM shareInstance].oep4 sendTransferFrom:sender
                                            from:sender.address.address
                                              to:@"AUwN8rcsEK4TkiYZFCdcjdxChx2aEHG3DN"
                                      withAmount:100000000
                                      byGasPayer:sender
                                     useGasLimit:20000
                                     useGasPrice:500
                                         preExec:isPreExec
                                   queryCallback:^(id result, NSError *error) {
                                       if (isPreExec) {
                                           NSString* gasConsumed = [(NSDictionary*)result objectForKey:@"Gas"];
                                           NSLog(@"\ngasConsumed === %@", gasConsumed);
                                           NSLog(@"\nGas == %@", result);
                                       } else {
                                           NSString* txhash = (NSString*)result;
                                           NSLog(@"\ntxhash == %@", txhash);
                                           [self testOep4QueryAllowance];
                                       }
                                   }];
}

- (void)testOep4QueryAllowance {
    [NeoVM shareInstance].oep4.contractAddress = _contractAddress;
    
    [[NeoVM shareInstance].oep4 queryAllowance:@"AQf4Mzu1YJrhz9f3aRkkwSm9n3qhXGSh4p"
                                   withSpender:@"AUvfyDwjEeCrBZWYTakazA9hQVQnaxYX46"
                                 queryCallback:^(NSString *balance, NSError *error) {
                                     NSLog(@"balance == %@, %@", balance, [error localizedDescription]);
                                 }];
    
}



#pragma mark - ONTID

- (void)testCreateOntid {
    ONTIdentity *ontID = [[ONTIdentity alloc] initWithName:@"MyOntid" password:@"ONT123ont"];
    NSLog(@"%@", ontID.ontid);
}

- (void)testRegisterOntid {
    ONTIdentity *ontID = [[ONTIdentity alloc] initWithName:@"MyOntid" password:@"ONT123ont"];
    ONTAccount *account = [[ONTAccount alloc] initWithName:@"ONT" password:@"ONT123ont" privateKeyHex:@"c3cc0e31af0e085299b38962281fceeb39cca70ac4ecc3bbd46e25154a9fb317"];
    NSString *txHex = [ontID makeRegisterOntIdTxWithPayer:account gasPrice:500 gasLimit:20000].toRawByte.hexString;
    
    [[ONTRpcApi shareInstance] sendRawtransactionWithHexTx:txHex preExec:NO callback:^(NSString *txHash, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"txHash == %@", txHash);
        }
    }];
}

- (void)testImportOntid {
    ONTIdentity *ontID = [[ONTIdentity alloc] initWithName:@"MyOntid" password:@"ONT123ont" privateKeyHex:@"c3cc0e31af0e085299b38962281fceeb39cca70ac4ecc3bbd46e25154a9fb317"];
    NSLog(@"%@", ontID.ontid);
}

- (void)testGetDDO {
    NSString *ontid = @"did:ont:AUr5QUfeBADq6BMY6Tp5yuMsUNGpsD7nLZ";
    NSString *txHex = [ONTIdentity makeGetDDOTransactionWithOntid:ontid].toRawByte.hexString;
    NSLog(@"%@", txHex);
    
    [[ONTRpcApi shareInstance] sendRawtransactionWithHexTx:txHex preExec:YES callback:^(NSString *resut, NSError *error) {
        if (error) {
            NSLog(@"error == %@", error);
        } else {
            NSLog(@"resut == %@", resut);
        }
    }];
}

- (void)testParseDDO {
    NSString *result = @"26010000002103f631f975560afc7bf47902064838826ec67794ddcdbcc6f0a9c7b91fc85025832d046b657931044a736f6e0f7b226b6579223a2268656c6c6f227d046b65793006537472696e670676616c75653114fa88f5244be19659bbd24477caeeacac7cbf781b";
    NSString *ontId = @"did:ont:AUr5QUfeBADq6BMY6Tp5yuMsUNGpsD7nLZ";
    NSDictionary *dicDDO = [ONTIdentity parserDDODataWithOntid:ontId result:result];
    NSLog(@"%@", dicDDO);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
