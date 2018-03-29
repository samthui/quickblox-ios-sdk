//
//  SearchUserViewController.m
//  BacSiViet
//
//  Created by Smisy on 3/27/18.
//  Copyright © 2018 QuickBlox Team. All rights reserved.
//

#import "SearchUserViewController.h"
#import "FilteredUsersViewController.h"

@interface SearchUserViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

// Our secondary search results table view.
@property (nonatomic, strong) FilteredUsersViewController *resultsTableController;

// For state restoration.
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation SearchUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configSearchController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configSearchController {
    _resultsTableController = [[FilteredUsersViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    
    if ([self.navigationItem respondsToSelector:@selector(setSearchController:)]) {
        // For iOS 11 and later, we place the search bar in the navigation bar.
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationItem.searchController = self.searchController;
        
        // We want the search bar visible all the time.
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    else {
        // For iOS 10 and earlier, we place the search bar in the table view's header.
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    
    // We want ourselves to be the delegate for this filtered table so didSelectRowAtIndexPath is called for both tables.
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    /** Search is now just presenting a view controller. As such, normal view controller
     presentation semantics apply. Namely that presentation will walk up the view controller
     hierarchy until it finds the root view controller or one that defines a presentation context.
     */
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
}


#pragma mark - Table view data source

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

/** Called after the search controller's search bar has agreed to begin editing or when
 'active' is set to YES.
 If you choose not to present the controller yourself or do not implement this method,
 a default presentation is performed on your behalf.
 
 Implement this method if the default presentation is not adequate for your purposes.
 */
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSLog(@"........");
    
        // update the filtered array based on the search text
        NSString *searchText = searchController.searchBar.text;
        NSMutableArray *searchResults = [self.dataSource.usersSortedByLastSeen mutableCopy];
    
        // strip out all the leading and trailing spaces
        NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
        // break up the search terms (separated by spaces)
        NSArray *searchItems = nil;
        if (strippedString.length > 0) {
            searchItems = [strippedString componentsSeparatedByString:@" "];
        }
    
        // build all the "AND" expressions for each value in the searchString
        //
        NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
        for (NSString *searchString in searchItems) {
            /** Each searchString creates an OR predicate for: name, yearIntroduced, introPrice
             Example if searchItems contains "iphone 599 2007":
             name CONTAINS[c] "iphone"
             name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
             name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
             */
            NSMutableArray *searchItemsPredicate = [NSMutableArray array];
    
            /** Below we use NSExpression represent expressions in our predicates.
             NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
             */
    
            // name field matching
            NSExpression *lhs = [NSExpression expressionForKeyPath:@"customData"];
            NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
            NSPredicate *finalPredicate = [NSComparisonPredicate
                                           predicateWithLeftExpression:lhs
                                           rightExpression:rhs
                                           modifier:NSDirectPredicateModifier
                                           type:NSContainsPredicateOperatorType
                                           options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
    
//            // yearIntroduced field matching
//            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
//            NSNumber *targetNumber = [numberFormatter numberFromString:searchString];
//            if (targetNumber != nil) {   // searchString may not convert to a number
//                lhs = [NSExpression expressionForKeyPath:@"yearIntroduced"];
//                rhs = [NSExpression expressionForConstantValue:targetNumber];
//                finalPredicate = [NSComparisonPredicate
//                                  predicateWithLeftExpression:lhs
//                                  rightExpression:rhs
//                                  modifier:NSDirectPredicateModifier
//                                  type:NSEqualToPredicateOperatorType
//                                  options:NSCaseInsensitivePredicateOption];
//                [searchItemsPredicate addObject:finalPredicate];
//
//                // price field matching
//                lhs = [NSExpression expressionForKeyPath:@"introPrice"];
//                rhs = [NSExpression expressionForConstantValue:targetNumber];
//                finalPredicate = [NSComparisonPredicate
//                                  predicateWithLeftExpression:lhs
//                                  rightExpression:rhs
//                                  modifier:NSDirectPredicateModifier
//                                  type:NSEqualToPredicateOperatorType
//                                  options:NSCaseInsensitivePredicateOption];
//                [searchItemsPredicate addObject:finalPredicate];
//            }
    
            // at this OR predicate to our master AND predicate
            NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
            [andMatchPredicates addObject:orMatchPredicates];
        }
    
        // match up the fields of the Product object
        NSCompoundPredicate *finalCompoundPredicate =
        [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
        searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    //
    //    // hand over the filtered results to our search results table
        FilteredUsersViewController *tableController = (FilteredUsersViewController *)self.searchController.searchResultsController;
    tableController.filteredUsers = searchResults;
        [tableController.tableView reloadData];
}

@end
