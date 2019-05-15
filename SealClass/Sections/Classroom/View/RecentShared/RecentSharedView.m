//
//  RecentSharedView.m
//  SealClass
//
//  Created by liyan on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RecentSharedView.h"
#import "RecentSharedWhiteboardCell.h"
#import "ClassroomService.h"
#import "RecentSharedVideoCell.h"

@interface RecentSharedView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *recentSharedTableView;
@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) NSMutableArray *recentSharedDataSource;


@end

@implementation RecentSharedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"132023" alpha:0.95];
        [self reloadDataSource];
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.recentSharedTableView];
    [self addSubview:self.alertLabel];
}

- (void)reloadDataSource {
    __weak typeof(self) weakSelf = self;
    [[ClassroomService sharedService] getWhiteboardList:^(NSArray<Whiteboard *> * _Nullable boardList) {
        dispatch_main_async_safe(^{
            [self.recentSharedDataSource removeAllObjects];
            NSArray *memberArray = [ClassroomService sharedService].currentRoom.memberList;
            for (RoomMember *member in memberArray) {
                if (member.role == RoleTeacher || member.role == RoleAssistant) {
                    [self.recentSharedDataSource addObject:member];
                }
            }
            if (self.recentSharedDataSource.count > 0) {
                self.alertLabel.hidden = YES;
            }
            [weakSelf.recentSharedDataSource addObjectsFromArray:[[boardList reverseObjectEnumerator] allObjects]];
            [weakSelf.recentSharedTableView reloadData];
        });
    }];
}

#pragma mark - tableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellName;
    if ([[self.recentSharedDataSource objectAtIndex:indexPath.row] isKindOfClass:[Whiteboard class]]) {
        cellName = @"RecentSharedWhiteboardCell";
        RecentSharedWhiteboardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[RecentSharedWhiteboardCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        [cell setModel:[self.recentSharedDataSource objectAtIndex:indexPath.row]];
        return cell;
    }else {
        cellName = @"RecentSharedVideoCell";
        RecentSharedVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[RecentSharedVideoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        [cell setModel:[self.recentSharedDataSource objectAtIndex:indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.recentSharedDataSource.count > indexPath.row) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(recentSharedViewCellTap:)]) {
            [self.delegate recentSharedViewCellTap:[self.recentSharedDataSource objectAtIndex:indexPath.row]];
        }
    }
}
    
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentSharedDataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 165.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, self.frame.size.width, 20)];
    label.text = @"资源库";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    [view addSubview:label];
    return view;
}

- (UITableView *)recentSharedTableView {
    if(!_recentSharedTableView) {
        CGSize size = self.bounds.size;
        _recentSharedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        _recentSharedTableView.backgroundColor = [UIColor clearColor];
        _recentSharedTableView.delegate = self;
        _recentSharedTableView.dataSource = self;
        _recentSharedTableView.bounces = NO;
        _recentSharedTableView.separatorColor=[UIColor clearColor];
        _recentSharedTableView.showsVerticalScrollIndicator = NO;
        _recentSharedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        if (@available(iOS 11.0, *)) {
            _recentSharedTableView.insetsContentViewsToSafeArea = NO;
        }
        
    }
    return _recentSharedTableView;
}

- (UILabel *)alertLabel {
    CGSize size = self.bounds.size;
    if(!_alertLabel) {
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake((size.width - 80) / 2, (size.height - 40) / 2, 80, 40)];
        _alertLabel.font = [UIFont systemFontOfSize:12];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.numberOfLines = 2;
        _alertLabel.hidden = NO;
        _alertLabel.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _alertLabel.text = NSLocalizedStringFromTable(@"NoContent", @"SealClass", nil);
    }
    return _alertLabel;
}

- (NSMutableArray *)recentSharedDataSource {
    if(!_recentSharedDataSource) {
        _recentSharedDataSource = [[NSMutableArray alloc] init];
    }
    return _recentSharedDataSource;
}


@end
