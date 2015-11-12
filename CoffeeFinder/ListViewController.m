#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ListViewController.h"
#import "CoffeePlace.h"
#import "DetailViewController.h"

@interface ListViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property NSArray *coffeePlacesArray;


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    [self updateCurrentLocation];
    
}

- (void)updateCurrentLocation {
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}


- (void)findCoffeePlaces: (CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"coffee";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.05, .05));
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *mapItems = response.mapItems;
        NSMutableArray *temporaryArray = [NSMutableArray new];
        
        
        for (int i = 0; i < 5; i++) {
            MKMapItem *mapItem = [mapItems objectAtIndex:i];
            CLLocationDistance metersAway = [mapItem.placemark.location distanceFromLocation:location];
            float milesDifference = metersAway / 1609.34;
            
            CoffeePlace *coffeePlace = [CoffeePlace new];
            coffeePlace.mapItem = mapItem;
            coffeePlace.milesDifference = milesDifference;
            
            [temporaryArray addObject:coffeePlace];
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"milesDifference" ascending:true];
        self.coffeePlacesArray = [temporaryArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        for (CoffeePlace *coffeePlace in self.coffeePlacesArray) {
            NSLog(@"%f",coffeePlace.milesDifference);
        }
        [self.tableView reloadData];
    }];
}




- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = locations.firstObject;
    NSLog(@"%@", self.currentLocation);
    [self.locationManager stopUpdatingLocation];
    [self findCoffeePlaces:self.currentLocation];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [[[self.coffeePlacesArray objectAtIndex:indexPath.row] mapItem] name];
    //cell.detailTextLabel.text = [self.coffeePlacesArray objectAtIndex:<#(NSUInteger)#>]
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coffeePlacesArray.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *detailVC = [segue destinationViewController];
    
    detailVC.coffeePlace = [self.coffeePlacesArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    detailVC.currentLocation = self.currentLocation;
}

@end
