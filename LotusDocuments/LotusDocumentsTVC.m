//
//  LotusDocumentsTVCTableViewController.m
//  LotusDocuments
//
//  Created by Sergey Mironchuk on 22.12.15.
//  Copyright © 2015 ATB-Market. All rights reserved.
//

#import "LotusDocumentsTVC.h"
#import "LotusDocument.h"
#import "DocumentViewController.h"

@interface LotusDocumentsTVC ()

@end

@implementation LotusDocumentsTVC

#define URL_FOR_LOAD_DOCUMENT @"http://iis-p.atbmarket.com/LotusWebAPI/api/Documents"

- (void)setDocuments:(NSArray *)documents
{
    _documents = documents;
    [self.tableView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Список документов";
    [self fetchDocuments];
}

- (IBAction)fetchDocuments {
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("document fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSURL *url = [NSURL URLWithString: URL_FOR_LOAD_DOCUMENT];
        NSData *jsonResult = [NSData dataWithContentsOfURL:url];
        if (jsonResult != nil) {
            NSArray *documents = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                 options:0
                                                                   error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                NSMutableArray *documentArray = [[NSMutableArray alloc] init];
                for (NSDictionary *documentDictionary in documents) {
                    LotusDocument *lotusDocument = [[LotusDocument alloc] init];
                    lotusDocument.UNID = [documentDictionary valueForKey:@"UNID"];
                    lotusDocument.TDate = [documentDictionary valueForKey:@"TDate"];
                    lotusDocument.Refer = [documentDictionary valueForKey:@"Refer"];
                    lotusDocument.Number = [documentDictionary valueForKey:@"Number"];
                    lotusDocument.Author = [documentDictionary valueForKey:@"Author"];
                    lotusDocument.Text = [documentDictionary valueForKey:@"Text"];
                    lotusDocument.Attachments = [documentDictionary mutableArrayValueForKey:@"Attachments"];

                    [documentArray addObject:lotusDocument];
                }
                self.documents = documentArray;
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Document Title Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    LotusDocument *document = self.documents[indexPath.row];
    cell.textLabel.text = document.Number;
    cell.detailTextLabel.text = document.Refer;
    
    return cell;
}

#pragma mark - UITableViewDelegate

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detailNavigationController = self.splitViewController.viewControllers[1];
    if ([detailNavigationController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) detailNavigationController;
        id detail = [navigationController.viewControllers firstObject];
        if ([detail isKindOfClass:[DocumentViewController class]]) {
            //if(![navigationController.topViewController isKindOfClass:[DocumentViewController class]])
                [((DocumentViewController *)detail).navigationController popViewControllerAnimated:YES];
            [self prepareViewController:detail toDisplayDocument:self.documents[indexPath.row]];
            if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
                self.splitViewController.displayModeButtonItem.title = self.title;
                ((DocumentViewController *) detail).navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
                                 }];
            }
        }
    }
    //[self.splitViewController.view setNeedsLayout];
    //[self.splitViewController willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
}
#pragma clang diagnostic pop

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath  *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([[segue identifier] isEqualToString:@"Display Document"]) {
                if ([[segue destinationViewController] isKindOfClass:[DocumentViewController class]]) {
                    [self prepareViewController:[segue destinationViewController]
                                 toDisplayDocument:self.documents[indexPath.row]];
                }
            }
        }
    }
}

- (void)prepareViewController: (DocumentViewController *)ivc toDisplayDocument: (LotusDocument *)document
{
    ivc.LotusDocument = document;
    ivc.title = document.Refer;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
