# ISOnDemandCollectionView

**Load your UICollectionView content on demand as you scroll on it**

`ISOnDemandCollectionView` allows you to load content into a UICollectionView in a paginated manner as you scroll the items, instead of loading all content at once. This is important for data-intensive applications and has the benefit of simplifying the implementation of a regular UICollectionView.


# Usage

To quickly implement, make your UICollectionView a subclass of ISOnDemandCollectionView:

![](https://github.com/Ilhasoft/ISOnDemandCollectionView/raw/master/ISOnDemandCollectionView/Resources/implement.png)

In your ViewController, implement the `ISOnDemandCollectionViewDelegate` protocol. You're required to implement:

```swift
extension ViewController: ISOnDemandCollectionViewDelegate {
    func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, reuseIdentifierForItemAt indexPath: IndexPath) -> String {
        return "ExampleCollectionViewCell"
    }

    func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, onContentLoadFinishedWithNewObjects objects: [Any]?, error: Error?) {

    }
}
```

# Loading Content

In order to load content, you must create your own class subclassing `ISOnDemandCollectionViewInteractor`:

```swift
class ExampleInteractor: ISOnDemandCollectionViewInteractor {
    let paginationOfChoice = 5

    init() {
        super.init(pagination: paginationOfChoice)
    }

    override open func fetchObjects(forPage: Int, completion: @escaping (([Any]?, Error?) -> Void)) {
      var objectsList: [Any] = []
      // get the content of the list for the current page
      completion(objectsList, nil)
    }
}
```

This method will automatically be called and the UICollectionView will be reloaded. When you scroll to the bottom of the list, the next page will be loaded.

In your `viewDidLoad` method, setup:

```swift
  override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    fileprivate func setupCollectionView() {
        collectionView.register(UINib(nibName: "ExampleCollectionViewCell", bundle: Bundle(for: ExampleCollectionViewCell.self)), forCellWithReuseIdentifier: "ExampleCollectionViewCell")
        collectionView.onDemandDelegate = self
        collectionView.interactor = ExampleInteractor()
        collectionView.loadContent()
    }
```

# Install

## Cocoapods

On your Podfile:

```
platform :ios, '9.0'

target 'YourTarget' do
    use_frameworks!
    pod 'ISOnDemandCollectionView', :git => 'https://github.com/Ilhasoft/ISOnDemandCollectionView.git'
end

```

# Using ISOnDemandCollectionView with Parse

As an example, you can create a simple interator that retrieves content from a `PFQuery` with a few lines of code:

```swift
import UIKit
import Parse
import ISOnDemandCollectionView

class ParseCollectionViewInteractor: ISOnDemandCollectionViewInteractor {

    private var query: PFQuery<PFObject>
    private let emptyObjectsList: [AnyObject] = []

    init(query: PFQuery<PFObject>, pagination: Int) {
        self.query = query
        query.limit = pagination
        query.skip = 0
        super.init(pagination: pagination)
    }

    override open func fetchObjects(forPage: Int, completion: @escaping (([Any]?, Error?) -> Void)) {
        query.skip = self.currentPage * self.pagination
        query.findObjectsInBackground { objects, error in
            handler(objects ?? self.emptyObjectsList, error)
        }
    }
}
```
