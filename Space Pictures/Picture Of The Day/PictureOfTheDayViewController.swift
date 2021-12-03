//
//  PictureOfTheDayViewController.swift
//  
//
//  Created by Ravikant Kumar on 03/12/21.
//

import UIKit
import SDWebImage
import DeckTransition
import CoreData
import Network

class PictureOfTheDayViewController: UIViewController {
    
    var sharedStack: CoreDataStackManager {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataStack
    }
    
    var sharedContext: NSManagedObjectContext {
        return sharedStack.context
    }
    //if #available(iOS 12.0, *) {
    let monitor = NWPathMonitor()
   // }
    var pictures = [Picture]()
    
    var collectionView: UICollectionView?
    var activityIndicator: UIActivityIndicatorView?
    var startDateLoaded: Date?
    var endDateLoaded: Date?
    let refreshControl = UIRefreshControl()

    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths : [IndexPath]!
    var updatedIndexPaths : [IndexPath]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<Picture> = {
        let fetchRequest = NSFetchRequest<Picture>(entityName: Picture.entityName())
        let sortDescriptor = NSSortDescriptor(key: "dateString", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController<Picture>(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        return fetchedResultsController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDateLoaded = UserDefaults.standard.object(forKey: "startDate") as? Date
        self.endDateLoaded = UserDefaults.standard.object(forKey: "fromDate") as? Date
        
        self.view.backgroundColor = UIColor.white
        self.collectionView?.backgroundColor = UIColor.red
        self.navigationController?.view.backgroundColor = UIColor.white
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        let cellNib = UINib(nibName: "PictureOfTheDayCell", bundle: nil)
        self.collectionView?.register(cellNib, forCellWithReuseIdentifier: PictureOfTheDayCell.reuseIdentifier)
        self.collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "loaderView")

        self.view.addSubview(self.collectionView!)
        
        self.collectionView?.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = refreshControl
        } else {
            collectionView?.addSubview(refreshControl)
        }

        performFetch()
        self.pictures = fetchedResultsController.fetchedObjects!
        if (self.pictures.count > 0) {
            let dateString = self.pictures[0].dateString
            let systemDate = Date()
            let systemDateString = dateToString(systemDate: systemDate)
            guard let systemDateData = systemDateString.toDate() else {return}
            guard let savedDate = dateString?.toDate() else {return}
            let isSame = systemDateData.compare(savedDate) == ComparisonResult.orderedSame
            if isSame == false && self.pictures.count > 0 {
                let alertController = UIAlertController(title: "Error", message: "We are not connected to the internet, showing you the last image we have.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
            self.calledFromNetwork()
            } else {
                let alertController = UIAlertController(title: "Error", message: "We are not connected to the internet.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            }
            let queue = DispatchQueue(label: "Monitor")
            monitor.start(queue: queue)
        }
    }
    
    func calledFromNetwork() {
        if pictures.isEmpty {
            DispatchQueue.main.async {
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            self.activityIndicator?.frame = self.view.bounds
            self.view.addSubview(self.activityIndicator!)
            self.activityIndicator?.startAnimating()
            }
            getNextPhotos(fromDate: Date())
        }

    }
    
    func dateToString(systemDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: systemDate)
        return dateString
    }

    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
        self.getNextPhotos(fromDate: Date())
        }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
    }
    
    func getNextPage() {
        if self.startDateLoaded != nil {
            getNextPhotos(fromDate: self.startDateLoaded!)
        }
    }
    
    func getNextPhotos(fromDate: Date) {
        var timeInterval = DateComponents()
        timeInterval.day = -27
        let startDate = Calendar.current.date(byAdding: timeInterval, to: fromDate)!
        self.activityIndicator?.startAnimating()
        NASAAPODClient.sharedInstance().getPhotos(startDate: startDate, endDate: fromDate) { (success, error) in
            DispatchQueue.main.async {
                self.collectionView?.isHidden = false
                self.activityIndicator?.stopAnimating()
            }
            if(!success && error != nil) {
                performUIUpdatesOnMain {
                    self.activityIndicator?.stopAnimating()

                    let alertController = UIAlertController(title: "Error", message: "App failed to get photos, try checking your internet connection.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    self.performFetch()
                    if(self.pictures.count == 0) {
                        self.activityIndicator?.stopAnimating()
                    }
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                }
                self.pictures = self.fetchedResultsController.fetchedObjects!
                UserDefaults.standard.set(startDate, forKey: "startDate")
                
                self.startDateLoaded = startDate
                self.endDateLoaded = fromDate
            }
            

        }
    }
}

extension PictureOfTheDayViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.collectionView != nil {
            let currentOffset = self.collectionView!.contentOffset.y;
            let maximumOffset = self.collectionView!.contentSize.height - scrollView.frame.size.height;
            
            if (maximumOffset - currentOffset <= 900) {
               // getNextPage()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let picture = self.pictures[indexPath.row]
        let detailViewController = PictureOfTheDayDetailViewController(picture: picture)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func pictureForIndexPath(_ indexPath : IndexPath) -> Picture? {
        if (!pictures.isEmpty) {
            return pictures[indexPath.row]
        } else {
            return Picture()
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureOfTheDayCell
            
            let picture = fetchedResultsController.object(at: indexPath)
            if picture.title != nil {
                cell.title?.text = picture.title
            }
            if picture.urlString != nil {
                let url = URL(string: picture.urlString!)!
               // if(picture.mediaType == "image") {
                cell.pictureOfTheDay?.sd_setIndicatorStyle(.gray)

                    cell.pictureOfTheDay?.sd_addActivityIndicator()
                    cell.pictureOfTheDay?.sd_imageTransition = .fade
                    cell.pictureOfTheDay.sd_setImage(with: url, completed: { (image, error, cacheType, imageURL) in
                        cell.pictureOfTheDay?.sd_removeActivityIndicator()
                        cell.pictureOfTheDay.image = image
                    })
                    cell.pictureOfTheDay?.sd_setImage(with:url)
    //                cell.pictureOfTheDay?.kf.setImage(with: url)
                   // cell.pictureOfTheDay?.sd_removeActivityIndicator()
                    cell.pictureOfTheDay.contentMode = .scaleAspectFill
               // }
//                if(picture.mediaType == "video") {
//
//                }
            }
        if picture.explanation != nil {
            cell.descriptionView?.text = picture.explanation
        }
            return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "loaderView", for: indexPath) as! UICollectionViewCell
//            let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//            loader.center = view.contentView.center
//            view.backgroundColor = .white
//            view.addSubview(loader)
//            loader.startAnimating()
            return view

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
        //        / CGFloat(1)
        let size = Int((collectionView.bounds.width - totalSpace))
        if(self.pictures.count > 0) {
            return CGSize(width: size, height: 60)
        } else {
            return CGSize.zero
        }
    }
}

extension PictureOfTheDayViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvRect = collectionView.frame
        return CGSize(width: cvRect.width, height: cvRect.height-50)
    }
}

extension PictureOfTheDayViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths  = [IndexPath]()
        updatedIndexPaths  = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView?.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView?.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}
