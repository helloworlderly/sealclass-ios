//
//  Whiteboard.m
//  SealClass
//
//  Created by LiFei on 2019/2/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "Whiteboard.h"

@implementation Whiteboard

+ (instancetype)whiteboardFromJson:(NSDictionary *)dic {
    Whiteboard *board = [[Whiteboard alloc] init];
    board.boardId = dic[@"whiteboardId"];
    board.name = dic[@"name"];
    return board;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"whiteboard:%@ name:%@", self.boardId,self.name];
}
@end
