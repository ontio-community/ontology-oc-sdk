//
//  ONTDappInvokeConfig.h
//  MediSharesiOS
//
//  Created by zhangyutao on 2018/12/25.
//  Copyright © 2018 zhongtuobang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONTDappInvokeConfig : NSObject

@property(nonatomic, strong) NSString *contractHash;
@property(nonatomic, strong) NSString *payer;
@property(nonatomic, assign) long gasLimit;
@property(nonatomic, assign) long gasPrice;
@property(nonatomic, strong) NSMutableArray *functions;

+ (ONTDappInvokeConfig *)invokeConfigWithDic:(NSDictionary *)dic;

@end

