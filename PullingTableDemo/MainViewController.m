//
//  MainViewController.m
//  PullingTableDemo
//
//  Created by luo danal on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "PullingRefreshTableView.h"

@interface MainViewController () <
PullingRefreshTableViewDelegate,
UITableViewDataSource,
UITableViewDelegate
>
@property (retain,nonatomic) PullingRefreshTableView *tableView;
@property (retain,nonatomic) NSMutableArray *list;
@property (nonatomic) BOOL refreshing;
@property (assign,nonatomic) NSInteger page;
@end

@implementation MainViewController
@synthesize tableView = _tableView;
@synthesize list = _list;
@synthesize refreshing = _refreshing;
@synthesize page = _page;

- (void)dealloc{
    [_list release];
    _list = nil;
    [_tableView release];
    [super dealloc];
}

- (void)loadView
{
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
    [super loadView];
    _list = [[NSMutableArray alloc] init ];
    
    CGRect bounds = CGRectMake(0, 0, 320, 416);
    bounds.size.height -= 44.f;
    _tableView = [[PullingRefreshTableView alloc] initWithFrame:bounds pullingDelegate:self];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:
                               [NSArray arrayWithObjects:@"Both",@"Top Only",nil]
                               ];
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    [seg release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (self.page == 0) {
        [self.tableView launchRefreshing];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Your actions

- (void)loadData{
    self.page++;
    if (self.refreshing) {
        self.page = 1;
        self.refreshing = NO;
        [self.list removeAllObjects];
    }
    for (int i = 0; i < 3; i++) {
        [self.list addObject:@"ROW"];
    }
    if (self.page >= 4) {
        [self.tableView tableViewDidFinishedLoadingWithMessage:@"All loaded!"];
        self.tableView.reachedTheEnd  = YES;
    } else {        
        [self.tableView tableViewDidFinishedLoading];
        self.tableView.reachedTheEnd  = NO;
        [self.tableView reloadData];
    }
}

- (IBAction)segChanged:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex == 1) {
        self.tableView.headerOnly = YES;
    } else {
        self.tableView.headerOnly = NO;
    }
}

#pragma mark - TableView*

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *identifier = @"_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    return cell;
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [df dateFromString:@"2012-05-03 10:10"];
    [df release];
    return date;
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];    
}

#pragma mark - Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}

@end
