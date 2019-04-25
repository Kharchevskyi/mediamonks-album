## MediaMonks Albums

MediaMonks test project.   
Album list using https://jsonplaceholder.typicode.com. 

## Installation
Clone git repository 

```
git clone https://github.com/Kharchevskyi/mediamonks-album.git
``` 

Run `MediaMonks Photos.xcworkspace`

As architecture I've used Swift Clean Architecture (VIP). A unidirectional architecture.  
**ViewController -> Interactor -> Presenter -> Router**  
More about VIP  
https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf  
https://clean-swift.com  
  
- Used **States** with generics parameters to handle views based on different states.  
  *Try to load albums with slow internet connection and without internet to take a look on state handlings and "nice animations").*  
- Added custom interactive transitions between controllers.
