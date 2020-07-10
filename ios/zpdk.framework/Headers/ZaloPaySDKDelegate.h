//
//  ZaloPaySDKDelegate.h
//  zpdk
//
//  Created by Thang Tran on 9/26/19.
//  Copyright © 2019 VNG Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZaloPaySDKErrorCode.h"

@protocol ZaloPaySDKDelegate <NSObject>
- (void)zalopayCompleteWithErrorCode:(ZPErrorCode)errorCode transactionId:(NSString *)transactionId zpTranstoken:(NSString*)zptranstoken;
@end
