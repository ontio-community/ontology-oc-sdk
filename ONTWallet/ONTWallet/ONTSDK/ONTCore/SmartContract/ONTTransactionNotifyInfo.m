//
//  ONTTransactionNotifyInfo.m
//  MediSharesiOS
//
//  Created by zhangyutao on 2018/12/26.
//  Copyright © 2018 zhongtuobang. All rights reserved.
//

#import "ONTTransactionNotifyInfo.h"
//#import "NSString+Extend.h"

@implementation ONTTransactionNotifyInfo

+ (ONTTransactionNotifyInfo *)initWithDic:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    ONTTransactionNotifyInfo *notifyInfo = [ONTTransactionNotifyInfo new];
    notifyInfo.result = dic[@"Result"];
    notifyInfo.state = [dic[@"State"] integerValue];
    notifyInfo.gas = [dic[@"Gas"] integerValue];
    
    NSMutableArray *arrayNotify = [NSMutableArray new];
    NSArray *notifyList = dic[@"Notify"];
    for (NSDictionary *dicNotify in notifyList) {
        ONTTransactionNotify *notify = [ONTTransactionNotify new];
        notify.contractAddress = dicNotify[@"ContractAddress"];
        
        ONTTransactionState *state = [ONTTransactionState new];
        NSArray *stateList = dicNotify[@"States"];
        for (int i = 0; i < stateList.count; i++) {
            if (i == 0) {
                state.func = stateList[0];
            } else if (i == 1) {
                state.from = stateList[1];
            } else if (i == 2) {
                state.to = stateList[2];
            } else if (i == 3) {
                state.amount = stateList[3];
            }
        }
        notify.states = state;
        
        [arrayNotify addObject:notify];
    }
    notifyInfo.notify = arrayNotify;
    
    return notifyInfo;
}

@end


@implementation ONTTransactionNotify

@end


@implementation ONTTransactionState

@end
