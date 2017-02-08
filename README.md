# TVOS-Infinite-Scroll-View
	the swift version infinite TVOS scroll View : (ouroboros)[https://github.com/willowtreeapps/ouroboros]

# Usage
	{quote}
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    self.view.backgroundColor = [UIColor redColor];
	    self.carouselView = [[CarouselView alloc] initWithFrame:CGRectMake(0.0f, 300.0f, self.view.bounds.size.width, 608.0f)];
	    self.carouselView.backgroundColor= [UIColor whiteColor];
	    self.carouselView.carouselDelegate = self;
	    self.carouselView.carouselContentArray = @[@"red", @"organge", @"yellow", @"green", @"blue"];
	    self.carouselView.autoScroll = YES;
	    [self.view addSubview:self.carouselView];
	}
	{quote}