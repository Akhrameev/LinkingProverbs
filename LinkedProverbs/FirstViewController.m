//
//  FirstViewController.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 30.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "FirstViewController.h"
#import "UPProverbCollectionCell.h"
#import "DAO.h"
#import "Proverb.h"
#import "UIColor+MLPFlatColors.h"
#import "UIImage+Resize.h"
#import "UIImage+Tint.h"
#import "UIImageCache.h"

@interface FirstViewController () {
    NSArray *proverbs;
    NSMutableSet *selectedProverbs;
}

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proverbsUpdated:) name:DAOProverbsUpdated object:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [[DAO sharedInstance] proverbsWithReload:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    proverbs = nil;
    selectedProverbs = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"proverbCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[UPProverbCollectionCell class]]) {
        Proverb *proverb = [self proverbAtIndexPath:indexPath];
        UPProverbCollectionCell *proverbCell = (UPProverbCollectionCell *)cell;
        proverbCell.nameLabel.text = proverb.text;
        BOOL selected = [selectedProverbs containsObject:proverb];
        proverbCell.backgroundColor = selected?[UIColor flatDarkOrangeColor]:[UIColor flatGreenColor];
        proverbCell.nameLabel.textColor = selected ? [UIColor flatDarkYellowColor]:[UIColor flatYellowColor];
        [proverbCell.starImage setHidden:![proverb.starred isEqualToNumber:@(YES)]];
    }
    return cell;
}

- (void) proverbsUpdated:(NSNotification *)note {
    NSArray *updatedProverbs = note.object;
    if (!updatedProverbs || [updatedProverbs isKindOfClass:[NSArray class]]) {
        proverbs = updatedProverbs;
        selectedProverbs = nil;
        [self.collectionView reloadData];
        [self updateToolbarButtons];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return proverbs.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (Proverb *) proverbAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(proverbs.count >= indexPath.row, @"Ошибка: индекс за пределами массива");
    return [proverbs objectAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    Proverb *proverb = [self proverbAtIndexPath:indexPath];
    if (!proverb)
        return;
    if ([selectedProverbs containsObject:proverb]) {
        [selectedProverbs removeObject:proverb];
    }
    else {
        if (!selectedProverbs)
            selectedProverbs = [NSMutableSet setWithCapacity:1];
        [selectedProverbs addObject:proverb];
    }
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self updateToolbarButtons];
}

- (void) updateToolbarButtons {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    if (selectedProverbs.count >= 1) {
        NSString *imgName = @"star plus.png";
        NSString *toolbarImageName = [imgName stringByAppendingString:@" toolbar cached"];
        UIImage *starButtonImage = [[UIImageCache sharedInstance] imageCachedWithName:toolbarImageName];
        if (!starButtonImage) {
            starButtonImage = [[[UIImage imageNamed:imgName] resizeToSize:CGSizeMake(48, 48)] imageTintedWithColor:[UIColor flatYellowColor]];
            [[UIImageCache sharedInstance] cacheImage:starButtonImage withName:toolbarImageName];
        }
        UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
        starButton.bounds = CGRectMake( 0, 0, starButtonImage.size.width, starButtonImage.size.height) ;
        [starButton setImage:starButtonImage forState:UIControlStateNormal];
        [starButton addTarget:self
                       action:@selector(starSelectedClick:)
             forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithCustomView:starButton];
        [items addObject:bookmark];
    }
    if (selectedProverbs.count >= 1) {
        NSString *imgName = @"star minus.png";
        NSString *toolbarImageName = [imgName stringByAppendingString:@" toolbar cached"];
        UIImage *starButtonImage = [[UIImageCache sharedInstance] imageCachedWithName:toolbarImageName];
        if (!starButtonImage) {
            starButtonImage = [[[UIImage imageNamed:imgName] resizeToSize:CGSizeMake(48, 48)] imageTintedWithColor:[UIColor flatYellowColor]];
            [[UIImageCache sharedInstance] cacheImage:starButtonImage withName:toolbarImageName];
        }
        UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
        starButton.bounds = CGRectMake( 0, 0, starButtonImage.size.width, starButtonImage.size.height) ;
        [starButton setImage:starButtonImage forState:UIControlStateNormal];
        [starButton addTarget:self
                       action:@selector(unstarSelectedClick:)
             forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithCustomView:starButton];
        [items addObject:bookmark];
    }
    self.toolbar.items = items;
}

- (void) manageStartClick:(BOOL)plus {
    __weak NSMutableSet *selectedProverbsInBlock = selectedProverbs;
    __weak FirstViewController *selfInBlock = self;
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        for (Proverb *pr in selectedProverbsInBlock) {
            [pr setStarred:@(plus)];
        }
    } completion:^(BOOL success, NSError *error) {
        if (selectedProverbsInBlock.count) {
            [selfInBlock.collectionView reloadData];
        }
    }];
}

- (void) starSelectedClick:(id)sender {
    [self manageStartClick:YES];
}

- (void) unstarSelectedClick:(id)sender {
    [self manageStartClick:NO];
}
@end
