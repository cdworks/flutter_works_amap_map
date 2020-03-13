//
//  WorksAMapSearchPOIViewController.m
//  Pods-Runner
//
//  Created by 李平 on 2020/2/25.
//

#import "WorksAMapSearchPOIViewController.h"
#import "POIItemCell.h"
#import "MJRefresh.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface WorksAMapSearchPOIViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,AMapSearchDelegate>

@property(nonatomic,weak)IBOutlet UITableView* tableView;
@property(nonatomic,weak)IBOutlet UISearchBar* searchBar;

@property(nonatomic,weak)IBOutlet UIActivityIndicatorView* indicatorView;

@property(nonatomic,strong)NSMutableArray<AMapPOI *> * data;

@property(nonatomic,strong)AMapSearchAPI* searchApi;

@property(nonatomic,strong)AMapPOIKeywordsSearchRequest* researchRequest;

@end

@implementation WorksAMapSearchPOIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBarTintColor:_barColor ?_barColor: [UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTintColor:_titleColor ?_titleColor: [UIColor blackColor]];
    
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : _titleColor ?_titleColor: [UIColor blackColor]}];
    
    self.navigationItem.title = @"位置搜索";
    
    _data = [NSMutableArray arrayWithCapacity:50];
    
    _searchBar.placeholder = @"请输入地址";
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_searchBar becomeFirstResponder];
    
    [_tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    
    UIView *view = [UIView new];
       view.backgroundColor = [UIColor clearColor];
       [_tableView setTableFooterView:view];
    
    _searchBar.delegate = self;
    
    _indicatorView.hidesWhenStopped = YES;
    
    
}


-(AMapSearchAPI*)searchApi
{
    if(!_searchApi)
    {
        _searchApi = [[AMapSearchAPI alloc] init];
        _searchApi.delegate = self;
        
        
    }
    return _searchApi;
}

-(AMapPOIKeywordsSearchRequest*)researchRequest
{
    if(!_researchRequest)
    {
        _researchRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
        _researchRequest.page = 1;
        _researchRequest.offset = 20;
    }
    return _researchRequest;
}


-(void)setTableviewFoot
{
    if (!self.tableView.mj_footer) {
        __weak typeof(self) weakSelf = self;
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf requestDataWithPageIndex:weakSelf.researchRequest.page + 1];
            
        }];
    }
}


-(void)requestDataWithPageIndex:(NSInteger)pageIndex
{
    if(pageIndex == 1)
    {
        [_indicatorView startAnimating];
        self.researchRequest.page = 1;
        
    }
    else
    {
        self.researchRequest.page = self.researchRequest.page+1;
    }
    
    [self.searchApi AMapPOIKeywordsSearch:self.researchRequest];
    
}


#pragma mark - UISearchbardelegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchApi cancelAllRequests];
    if(searchText.length)
    {
        self.researchRequest.page = 1;
        self.researchRequest.keywords = searchText;
        [self.searchApi AMapPOIKeywordsSearch:self.researchRequest];
    }
    else if(self.data.count)
    {
    
        [self.data removeAllObjects];
        [self.tableView reloadData];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}


#pragma mark - amapsearch
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [_indicatorView stopAnimating];
    [self.tableView.mj_footer endRefreshing];
    
    if (response.pois.count == 0)
    {
        self.tableView.mj_footer = nil;
        return;
    }
    
    if(request.page == 1)
    {
        [self.data removeAllObjects];
    }
    
    [self.data addObjectsFromArray:response.pois];
    
    if(self.data.count >= response.count)
    {
        self.tableView.mj_footer = nil;
    }
    else{
        [self setTableviewFoot];
    }
        

    [self.tableView reloadData];
}



- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    [_indicatorView stopAnimating];
    NSLog(@"search error:%@",error.localizedDescription);
}


#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    AMapPOI* poi = _data[indexPath.row];
    
    POIItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"POIItemCell" forIndexPath:indexPath];
    cell.titleLabel.text = poi.name;
    if(poi.address.length)
    {
        cell.addressLabel.text = [NSString stringWithFormat:@"%@%@",poi.city,poi.address];
    }
    else
    {
        cell.addressLabel.text = poi.formattedDescription;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapPOI* poi = _data[indexPath.row];
    if(_didSelectPOI)
    {
        _didSelectPOI(poi.location.latitude,poi.location.longitude);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
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
