//
//  Profile.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Profile.h"
#import "ListField.h"
#import "ProfileMediaCell.h"
#import "ProfileCollectionCell.h"
#import "MediaView.h"

@interface Profile ()
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet ListField *withMe;
@property (weak, nonatomic) IBOutlet ListField *ageGroup;
@property (weak, nonatomic) IBOutlet ListField *gender;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation Profile


- (void)awakeFromNib
{
    [super awakeFromNib];
}

const id kProfileLocationCell = @"ProfileLocationCell";
const id kProfileCollectionCell = @"ProfileCollectionCell";

- (void)setupViewAttributes
{
    UIColor *blue = [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1.0f];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:kProfileLocationCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kProfileLocationCell];
    [self.tableView registerNib:[UINib nibWithNibName:kProfileCollectionCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kProfileCollectionCell];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.nickname.textColor = blue;
    self.ageGroup.textColor = blue;
    self.gender.textColor = blue;
    self.withMe.textColor = blue;
    
    self.nickname.radius = 5.0f;
    self.ageGroup.radius = 5.0f;
    self.gender.radius = 5.0f;
    self.withMe.radius = 5.0f;
    self.mapView.radius = 5.0f;
    
    self.photo.editBlock = ^(UserMedia* media) {
        NSLog(@"USERMEDIA:%@\nUSER:%@", media, self.user);
        UserMedia *firstObject = [self.user.media firstObject];
        NSLog(@"MEDIA BEFORE:%@", self.user.media);
        if (firstObject) {
            [self.user removeObjectsInArray:@[firstObject] forKey:@"media"];
            NSLog(@"MEDIA AFTER:%@", self.user.media);
        }
        [self.user saved:^{
            [self.user addUniqueObject:media forKey:@"media"];
            NSLog(@"MEDIA AFTER FINAL:%@", self.user.media);
            [self.user saved:^{
                [self.tableView reloadData];
            }];
        }];
    };
}

- (void)setUser:(User *)user
{
    _user = user;
    
    [self.withMe setPickerForWithMesWithHandler:nil];
    [self.ageGroup setPickerForAgeGroupsWithHandler:nil];
    [self.gender setPickerForGendersWithHandler:nil];
    
    self.nickname.text = self.user.nickname;
    self.withMe.text = self.user.withMe;
    self.ageGroup.text = self.user.age;
    self.gender.text = self.user.genderTypeString;
    
    self.gender.radius = 3.0f;
    self.withMe.radius = 3.0f;
    self.ageGroup.radius = 3.0f;
    
    [self.photo setEditable:self.user.isMe];
    [self.photo loadMediaFromUser:self.user];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewAttributes];
    self.user = [User me];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((ProfileSections)indexPath.section) {
        case kProfileSectionProfileMedia:
            return 100;
        case kProfileSectionLikes:
            return 70;
        case kProfileSectionLiked:
            return 70;
        case kProfileSectionPosts:
            return 600;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((ProfileSections)section) {
        case kProfileSectionProfileMedia:
            return self.user.media.count;
        case kProfileSectionLikes:
            return self.user.likes.count;
        case kProfileSectionLiked:
            return self.user.likes.count; // TO UPDATE TO LIKED
        case kProfileSectionPosts:
            return self.user.posts.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((ProfileSections) indexPath.section) {
        case kProfileSectionProfileMedia:
            return [self collectionCellFromTableView:tableView
                               cellForRowAtIndexPath:indexPath
                                               items:self.user.media
                                            editable:YES
                    ];
        case kProfileSectionLikes:
            return [self collectionCellFromTableView:tableView
                               cellForRowAtIndexPath:indexPath
                                               items:self.user.likes
                                            editable:NO
                    ];
        case kProfileSectionLiked:
            return [self collectionCellFromTableView:tableView
                               cellForRowAtIndexPath:indexPath
                                               items:self.user.likes
                                            editable:NO
                    ];
        case kProfileSectionPosts:
            return [self collectionCellFromTableView:tableView
                               cellForRowAtIndexPath:indexPath
                                               items:self.user.posts
                                            editable:NO
                    ];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"lalala";
    return cell;
}

- (ProfileCollectionCell*) collectionCellFromTableView:(UITableView *)tableView
                                 cellForRowAtIndexPath:(NSIndexPath *)indexPath
                                                 items:(id)items
                                              editable:(BOOL)editable
{
    ProfileCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileCollectionCell forIndexPath:indexPath];
    cell.items = items;
    cell.editable = editable;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(20, 0, self.tableView.bounds.size.width, 50);
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1.0f];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:titleLabel];
    
    switch ((ProfileSections)section) {
        case kProfileSectionProfileMedia:
            titleLabel.text = [NSString stringWithFormat:@"User Media (%ld)", self.user.media.count];
            break;
        case kProfileSectionLikes:
            titleLabel.text = [NSString stringWithFormat:@"Likes (%ld)", self.user.likes.count];
            break;
        case kProfileSectionLiked:
            titleLabel.text = [NSString stringWithFormat:@"Liked by (%ld)", self.user.likes.count];
            break;
        case kProfileSectionPosts:
            titleLabel.text = [NSString stringWithFormat:@"Posts (%ld)", self.user.posts.count];
            break;
    }
    
    return headerView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
