## MediaMonks Albums

MediaMonks test project.   
Album list using https://jsonplaceholder.typicode.com. 

## Installation
Clone git repository 

```
git clone https://github.com/Kharchevskyi/mediamonks-album.git
``` 

Run `MediaMonks Photos.xcworkspace`.  
  
Please run on a device to avoid problems with CIFilters on simulators.  

As architecture I've used Swift Clean Architecture (VIP).  
A unidirectional architecture.  
 
More about VIP  
https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf  
https://clean-swift.com  
  
- Used **States** with generics parameters to handle views based on different states.  
  *Try to load albums with slow internet connection and without internet to take a look on state handlings and "nice animations").*  
  
Also added custom interactive transitions between controllers.  
- Interactive fade transition
- Custom transition between photos list and photo detail. Also added pan transition for dismissing photo)
  
Albums Scene:  
- Added custom pull to refresh.
- Try to load with pure internet connection or without it.  
- Try to tap on "Monk" image to retry.

Photos Scene: 
- Added mosaic flow layout.
- Load and then caching images.
- Tap on phot - shows you photo detail.
- pull to refresh 
  
  
ReactiveSwift.   
ReactiveCocoa.   
