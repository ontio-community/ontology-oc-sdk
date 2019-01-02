//
//  ONTDappInvokeConfig.m
//  MediSharesiOS
//
//  Created by zhangyutao on 2018/12/25.
//  Copyright © 2018 zhongtuobang. All rights reserved.
//

#import "ONTDappInvokeConfig.h"
#import "Categories.h"
#import "Parameter.h"
#import "AbiFunction.h"
#import "ONTAddress.h"
#import "ONTLong.h"

@implementation ONTDappInvokeConfig

+ (ONTDappInvokeConfig *)invokeConfigWithDic:(NSDictionary *)dic {
    ONTDappInvokeConfig *ontDappInvokeConfig = [ONTDappInvokeConfig new];
    
    NSDictionary *params = dic[@"params"];
    NSDictionary *invokeConfig = params[@"invokeConfig"];
    if (!invokeConfig) {
        return nil;
    }
    
    NSString *contractHash = invokeConfig[@"contractHash"];
    if (!contractHash || contractHash.length == 0) {
        return nil;
    }
    ontDappInvokeConfig.contractHash = contractHash;
    
    NSString *payer = invokeConfig[@"payer"];
    if (!payer || payer.length == 0) {
        //return nil;
    }
    ontDappInvokeConfig.payer = payer;
    
    long gasLimit = [invokeConfig[@"gasLimit"] longValue];
    if (gasLimit < 20000) {
        gasLimit = 20000;
    }
    ontDappInvokeConfig.gasLimit = gasLimit;
    
    long gasPrice = [invokeConfig[@"gasPrice"] longValue];
    if (gasPrice < 500) {
        gasPrice = 500;
    }
    ontDappInvokeConfig.gasPrice = gasPrice;
    
    NSArray *functions = invokeConfig[@"functions"];
    if (!functions || functions.count == 0) {
        return nil;
    }
    
    NSMutableArray *arrayFunctions = [NSMutableArray new];
    for (NSDictionary *functionDic in functions) {
        NSString *operation = functionDic[@"operation"];
        
        AbiFunction *func = [[AbiFunction alloc] init];
        func.name = operation;
        func.returntype = @"Boolean";
        
        NSArray *args = functionDic[@"args"];
        for (NSDictionary *argDic in args) {
            Parameter *param = [[Parameter alloc] init];
            param.name = argDic[@"name"];
            
            id value = argDic[@"value"];
            if ([value isKindOfClass:[NSString class]]) {
                NSArray *array = [value componentsSeparatedByString:@":"];
                if (array.count == 2) {
                    NSString *result = (NSString *)array[1];
                    if ([array[0] isEqualToString:@"Address"]) {
                        param.type = @"ByteArray";
                        ONTAddress *address = [ONTAddress addressWithString:result];
                        [param setValue:address.publicKeyHash160];
                    } else if ([array[0] isEqualToString:@"String"]) {
                        param.type = @"String";
                        [param setValue:result];
                    } else if ([array[0] isEqualToString:@"ByteArray"]) {
                        param.type = @"ByteArray";
                        [param setValue:result.hexToData];
                    } else if ([array[0] isEqualToString:@"Long"]) {
                        param.type = @"Integer";
                        [param setValue:[[ONTLong alloc] initWithLong:(long)result.integerValue]];
                    } else {
                        return nil;
                    }
                } else {
                    param.type = @"String";
                    [param setValue:value];
                }
            } else if ([value isKindOfClass:[NSNumber class]]) {
                param.type = @"Integer";
                NSNumber *result = (NSNumber *)value;
                [param setValue:[[ONTLong alloc] initWithLong:(long)result.longValue]];
            } else {
                return nil;
            }
            
            [func addParam:param];
        }
        
        [arrayFunctions addObject:func];
    }
    ontDappInvokeConfig.functions = arrayFunctions;
    
    return ontDappInvokeConfig;
}

@end
