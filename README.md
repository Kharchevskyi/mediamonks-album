## MediaMonks Albums
![alt text](https://github.com/Kharchevskyi/mediamonks-album/blob/develop/Screenshots/4.jpeg)

MediaMonks test project.   
Album list using https://jsonplaceholder.typicode.com. 

## Installation
Clone git repository 

```
git clone https://github.com/Kharchevskyi/mediamonks-album.git
``` 

Run `MediaMonks Photos.xcworkspace`.  
  
**Please run on a device to avoid problems with CIFilters on simulators.**  
 
## Scenes  
**Albums List**  
- Custom loaders for failed and loading states.   
- Try to tap on "Monk" image to retry.  
- Custom pull to refresh.  
- Custom interactive fade transition.
![alt text](https://github.com/Kharchevskyi/mediamonks-album/blob/develop/Screenshots/3.jpeg)
  
**Photos List** 
- Mosaic flow layout.
- All images are saved to cache.
- Tap on photo will show you photo detail with custom animation transition.
- Tap on right bar button will show you random image. (Added just to show filters on photo detail).    
  
![alt text](https://github.com/Kharchevskyi/mediamonks-album/blob/develop/Screenshots/2.jpeg)
  
**Photo Detail**
- Added "Edit" feature to apply different filters to image.
- Pan gesture for dismissing.
- Pinch to zoom in/zoom out.
- Double tap to zoom in/zoom out.  
![alt text](https://github.com/Kharchevskyi/mediamonks-album/blob/develop/Screenshots/1.jpeg)
  
## App architecture
As architecture I've used Swift Clean Architecture (VIP).  
A unidirectional architecture.  
 
More about VIP  
https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf  
https://clean-swift.com  
  
- Used **States** with generics parameters to handle views based on different states.  
  *Try to load albums with slow internet connection and without internet to take a look on state handlings and "nice animations").* 
  
*3-d party libraries*
``` 
https://github.com/ReactiveCocoa/ReactiveSwift/#readme
```
