//
//  Whiteboard.h
//  SealClass
//
//  Created by LiFei on 2019/2/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Whiteboard : NSObject

@property (nonatomic, copy)   NSString *boardId;
@property (nonatomic, copy)   NSString *name;

+ (instancetype)whiteboardFromJson:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
