//
//  MessageDataSource.m
//  SealClass
//
//  Created by 张改红 on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageDataSource.h"
#import "TimeStampMessage.h"
#import "MessageHelper.h"
#import "ClassroomService.h"
const NSUInteger numOfMessages = 20;
@interface MessageDataSource () <MessageHelperDelegate>
@property (nonatomic, strong) dispatch_queue_t storeQueue;
@property (nonatomic, strong) NSMutableArray <MessageModel *> *dataSource;
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, assign) long long earliestMessageSendTime; /// 当前sotre中最早的发送时间
@property (nonatomic, strong) NSMutableDictionary <NSNumber *,NSNumber *> *sendingCache;
@property (nonatomic, copy) NSString *targetId;
@end

@implementation MessageDataSource
#pragma mark - Life cycle
- (instancetype)initWithTargetId:(NSString *)targetId
                conversationType:(RCConversationType)type {
    if (self = [super init]) {
        [IMService sharedService].receiveMessageDelegate = self;
        self.targetId = targetId;
        self.conversationType = type;
        [self fetchLatestMessages];
        [MessageHelper sharedInstance].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roleDidChange:) name:RoleDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Api
- (NSUInteger)count {
    return self.dataSource.count;
}

- (MessageModel *)objectAtIndex:(NSUInteger)index{
    MessageModel *model = self.dataSource[index];
    return model;
}

- (void)fetchHistoryMessages {
    NSAssert([[NSThread currentThread] isMainThread],
             @"%@ is not invoked by the main thread.",
             NSStringFromSelector(_cmd));
    NSMutableArray *totalArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSLog(@"rcim getHistoryMessages"
          @"earliestMessageSendTime %@",
          @(self.earliestMessageSendTime));
    NSArray<RCMessage *> *localMessages= [IMClient getHistoryMessages:self.conversationType targetId:self.targetId objectNames:[[MessageHelper sharedInstance] getAllSupportMessage] sentTime:self.earliestMessageSendTime isForward:YES count:numOfMessages];
    localMessages = [localMessages.reverseObjectEnumerator allObjects];
    
    void (^insertHistoryMessageBlock)(NSArray<RCMessage *> *, BOOL) =
    ^(NSArray<RCMessage *> *messages,BOOL isRemaining) {
        NSLog(@"rcim insertHistorymesssages %@"
              @"count %@, isRemaining %@",
              messages,@(messages.count),@(isRemaining));
        messages = [self insertTimeMessage:messages];
        dispatch_async(self.storeQueue, ^{
            __block NSArray *array = [self messageModels:messages];
            dispatch_main_async_safe(^{
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
                [self.dataSource insertObjects:array atIndexes:indexSet];
                [self.delegate didLoadHistory:array isRemaining:isRemaining];
            });
        });
    };
    if (localMessages.count < numOfMessages) {
        NSUInteger msgCount = numOfMessages - localMessages.count;
        if (localMessages.count > 0) {
            [totalArray addObjectsFromArray:localMessages];
        }
        void (^success)(NSArray *, BOOL) = ^(NSArray *messages, BOOL isRemaining) {
            NSArray<RCMessage *> *remoteMessage = [messages.reverseObjectEnumerator allObjects];
            [totalArray addObjectsFromArray:remoteMessage];
            insertHistoryMessageBlock([totalArray copy], isRemaining);
        };
        void (^error)(RCErrorCode) = ^(RCErrorCode status) {
            BOOL isRemain = status == MSG_ROAMING_SERVICE_UNAVAILABLE ? NO : YES;
            insertHistoryMessageBlock(totalArray, isRemain);
        };
        [IMClient getRemoteHistoryMessages:self.conversationType
                                  targetId:self.targetId
                                recordTime:self.earliestMessageSendTime
                                     count:(int)msgCount
                                   success:success
                                     error:error];
        return;
    }
    [totalArray addObjectsFromArray:localMessages];
    insertHistoryMessageBlock([totalArray copy], YES);
}

#pragma mark - IMReceiveMessageDelegate
- (void)onReceiveMessage:(RCMessage *)message left:(int)nLeft object:(id)object {
    NSArray *supportMessages = [[MessageHelper sharedInstance] getAllSupportMessage];
    if (![self isCurrentConversation:message] && ![self isPersistentMessage:message] && ![supportMessages containsObject:message.objectName]) {
        return;
    }
    dispatch_async(self.storeQueue, ^{
        MessageModel *model = [self messageModel:message];
        if (!model) {
            return;
        }
        dispatch_main_async_safe(^{
            [self insertNewMessageTime:message];
            [self.dataSource addObject:model];
            NSUInteger index = self.dataSource.count - 1;
            [self.delegate didInsert:model startIndex:index];
        });
    });
}

#pragma mark - MessageHelperDelegate
- (void)willSendMessage:(RCMessage *)message {
    if (![self isCurrentConversation:message]) {
        return;
    }
    dispatch_async(self.storeQueue, ^{
        message.sentStatus = SentStatus_SENDING;
        MessageModel *model = [self messageModel:message];
        if (!model) {
            return;
        }
        dispatch_main_async_safe(^{
            [self insertNewMessageTime:message];
            [self.dataSource addObject:model];
            NSUInteger index = self.dataSource.count - 1;
            self.sendingCache[@(message.messageId)] = @(index);
            [self.delegate didInsert:model startIndex:index];
            [self.delegate didSendStatusUpdate:model index:index];
        });
    });
}

- (void)onSendMessage:(RCMessage *)message didCompleteWithError:(nullable NSError *)error {
    if (![self isCurrentConversation:message]) {
        return;
    }
    dispatch_main_async_safe(^{
        NSNumber *indexNumber =  self.sendingCache[@(message.messageId)];
        if (indexNumber) {
            NSInteger index = [indexNumber integerValue];
            MessageModel *model = [self.dataSource objectAtIndex:index];
            model.message.sentStatus = SentStatus_SENT;
            // dispatch_async(dispatch_get_main_queue(), ^{
            //NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
            [self.delegate didSendStatusUpdate:model index:index];
            //});
            [self.sendingCache removeObjectForKey:@(message.messageId)];
        } else {
            NSUInteger count = self.dataSource.count;
            NSInteger index = NSNotFound;
            for (NSInteger i = count - 1; i >= 0; i--) {
                MessageModel *model = self.dataSource[i];
                if (model.message.messageId == message.messageId) {
                    index = i;
                    break;
                }
            }
            if (index != NSNotFound) {
                MessageModel *model = [self.dataSource objectAtIndex:index];
                model.message.sentStatus = SentStatus_SENT;
                [self.delegate didSendStatusUpdate:model index:index];
            } else {
                MessageModel *model = [self messageModel:message];
                if (!model) {
                    return;
                }
                [self insertNewMessageTime:message];
                [self.dataSource addObject:model];
                NSUInteger index = self.dataSource.count - 1;
                self.sendingCache[@(message.messageId)] = @(index);
                [self.delegate didInsert:model startIndex:index];
                [self.delegate didSendStatusUpdate:model index:index];
            }
        }
    });
}

#pragma mark - Helper
- (void)fetchLatestMessages {
    NSArray<RCMessage *> *messages= [IMClient getHistoryMessages:self.conversationType targetId:self.targetId objectNames:[[MessageHelper sharedInstance] getAllSupportMessage] sentTime:0 isForward:YES count:numOfMessages];
    messages = [messages.reverseObjectEnumerator allObjects];
    messages = [self insertTimeMessage:messages];
    NSLog(@"rcim lastestMessage %@ count %@", messages, @(messages.count));
    dispatch_async(self.storeQueue, ^{
        NSArray *array = [self messageModels:messages];
        dispatch_main_async_safe(^{
            [self.dataSource addObjectsFromArray:array];
            [self.delegate forceReloadData];
            [self.delegate lastestMessageLoadCompleted];
        });
    });
    if (messages.count == 0) {
        [self fetchHistoryMessages];
    }
}

- (MessageModel *)messageModel:(RCMessage *)message {
    return [[MessageModel alloc] initWithMessage:message];
}

- (NSArray *)messageModels:(NSArray *)messages {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:messages.count];
    [messages enumerateObjectsUsingBlock:^(RCMessage *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        MessageModel *model = [self messageModel:obj];
        if (model) {
            [array addObject:model];
        }
    }];
    return [array copy];
}

- (BOOL)isCurrentConversation:(RCMessage *)message {
    return [message.targetId isEqualToString:self.targetId] &&
    message.conversationType == self.conversationType;
}

- (BOOL)isPersistentMessage:(RCMessage *)message{
    return ([[message.content class] persistentFlag] & MessagePersistent_ISPERSISTED);
}

- (RCMessage *)buildTimeMessage:(NSTimeInterval)time {
    TimeStampMessage *timeMessage = [[TimeStampMessage alloc] initWithTime:time];
    timeMessage.timeText = [[MessageHelper sharedInstance] convertChatMessageTime:time/1000];
    RCMessage *message =
    [[RCMessage alloc] initWithType:self.conversationType
                           targetId:self.targetId
                          direction:MessageDirection_SEND
                          messageId:0
                            content:timeMessage];
    message.objectName = [TimeStampMessage getObjectName];
    return message;
}

- (NSArray <RCMessage *> *)insertTimeMessage:(NSArray *)messages{
    if (messages.count == 0) {
        return nil;
    }
    NSMutableArray *mutableMessages = messages.mutableCopy;
    RCMessage *lastMessage = messages[0];
    for (int i = (int)messages.count-1; i > 0; i--) {
        RCMessage *lastMessage = messages[i];
        RCMessage *preMessage = messages[i-1];
        if ((lastMessage.sentTime - preMessage.sentTime) > 3*60*1000) {
            RCMessage *timeMessage = [self buildTimeMessage:lastMessage.sentTime];
            [mutableMessages insertObject:timeMessage atIndex:i];
        }
    }
    RCMessage *timeMessage = [self buildTimeMessage:lastMessage.sentTime];
    [mutableMessages insertObject:timeMessage atIndex:0];
    
    NSMutableArray *currentMessages = self.dataSource.mutableCopy;
    if (currentMessages.count > 0) {
        RCMessage *lastMessage = messages[messages.count-1];
        //当前数据源第一个元素一定是时间model,所以第2个才是真正的消息
        RCMessage *startMessage = ((MessageModel *)self.dataSource[1]).message;
        if ((startMessage.sentTime - lastMessage.sentTime) < 3*60*1000) {
            dispatch_main_async_safe(^{
                [self removeObjectAtIndex:0];
            });
        }
    }
    return mutableMessages;
}

- (void)insertNewMessageTime:(RCMessage *)newMessage{
    RCMessage *currentLastMessage = self.dataSource.lastObject.message;
    if ((newMessage.sentTime - currentLastMessage.sentTime) > 3*60*1000) {
        RCMessage *timeMessage = [self buildTimeMessage:newMessage.sentTime];
        MessageModel *model = [self messageModel:timeMessage];
        if (!model) {
            return;
        }
        if ([NSThread isMainThread]) {
            [self.dataSource addObject:model];
            NSUInteger index = self.dataSource.count - 1;
            [self.delegate didInsert:model startIndex:index];
        }else{
            dispatch_main_async_safe(^{
                [self.dataSource addObject:model];
                NSUInteger index = self.dataSource.count - 1;
                [self.delegate didInsert:model startIndex:index];
            });
        }
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    NSAssert([[NSThread currentThread] isMainThread],
             @"%@ is not invoked by the main thread.",
             NSStringFromSelector(_cmd));
    NSAssert(index < self.dataSource.count,
             @"index %@ beyond bounds [0 .. %@]",
             @(index), @(self.dataSource.count));
    [self.dataSource removeObjectAtIndex:index];
    [self.delegate didRemoved:self.dataSource[index] atIndex:index];
}

- (void)roleDidChange:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    Role role = [dic[@"role"] integerValue];
    NSString *userId = dic[@"userId"];
    RoomMember *member = [[ClassroomService sharedService].currentRoom getMember:userId];
    NSString *name = userId;
    if(member.name.length > 0){
        name = member.name;
    }
    if ([member.userId isEqualToString:IMClient.currentUserInfo.userId]) {
        name = NSLocalizedStringFromTable(@"You", @"SealClass", nil);
    }
    NSString *info;
    if (role == RoleAssistant) {
        info = [NSString stringWithFormat:NSLocalizedStringFromTable(@"BecomeAssistant", @"SealClass", nil),name];
    }else if (role == RoleTeacher) {
        info = [NSString stringWithFormat:NSLocalizedStringFromTable(@"BecomeTeacher", @"SealClass", nil),name];
    }else if (role == RoleStudent) {
        info = [NSString stringWithFormat:NSLocalizedStringFromTable(@"BecomeStudent", @"SealClass", nil),name];
    }else if (role == RoleAudience) {
        info = [NSString stringWithFormat:NSLocalizedStringFromTable(@"BecomeAudience", @"SealClass", nil),name];
    }
    if (info.length > 0) {
        RCInformationNotificationMessage *infoContent = [[RCInformationNotificationMessage alloc] init];
        infoContent.message = info;
        RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:(MessageDirection_RECEIVE) messageId:-1 content:infoContent];
        [self onReceiveMessage:message left:0 object:@""];
    }
}

#pragma mark - Getters & setters
- (NSMutableArray<MessageModel *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:2000];
    }
    return _dataSource;
}

- (NSMutableDictionary<NSNumber *, NSNumber *> *)sendingCache {
    if (!_sendingCache) {
        _sendingCache = [[NSMutableDictionary alloc] initWithCapacity:30];
    }
    return _sendingCache;
}

- (dispatch_queue_t)storeQueue {
    if (!_storeQueue) {
        _storeQueue = dispatch_queue_create("rcimkit.messagestorequeue", DISPATCH_QUEUE_SERIAL);
    }
    return _storeQueue;
}

- (long long)earliestMessageSendTime{
    long long time = 0;
    if (self.dataSource.count > 1) {
        //当前数据源第一个元素一定是时间model,所以第2个才是真正的消息
        MessageModel *model = [self objectAtIndex:1];
        time = model.message.sentTime;
    }
    return time;
}
@end
