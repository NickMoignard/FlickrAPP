# iOS Coding Challenge

Hi!  I'm **Nick Moignard**. 
I've built an iOS Application according to the brief found below.

### Aproach
I built the base of the application using a UICollectionView.
~ ( FlickrPhotoCollectionViewController.swift )
I included:  
* Pull down to refresh most recent photos
* Pull up to load more photos when at the bottom of the list
* A Search bar in the Navigation bar to search Flickr

A simple view for looking at individual photos from Flickr
~ (FlickrPhotoDetailViewControll.swift)
I implemented Pinch to Zoom on the Image for the curious users

A class to handle the interaction with the Flickr API. 
~ ( FlickrNetworkManager.swift )

Various Data Structures to house data receive from the Flickr API
~ ( FlickrPhoto.swift, FlickrError.swift & FlickrResponse.swift )

Custom Refresh Control for loading more images (Pagination)
~ (CollectionFooterView.xib, CollectionFooterView.swift)
This is necessary as apple only provides a RefreshControl for pull down to refresh

Simple Header class & CollectionViewCell class
~ (FlickrPhotoCollectionViewCell.swift, HeaderCollectionReusableView.swift)

Included Pods in project:
~ Not sure if CocoaPods are encouraged for this project but I come from rails and much prefer to conform to the DRY principle. Also it produces much more readable code

*  SDWebImage for asynchronous image downloading and cacheing
* SwiftyJSON for clean json parsing
* Alamofire for simple HTTP requests and responses
* Fabric & Crashlytics are included for beta testing on various devices

# Brief
Using Flickr’s publicly available APIs, develop a mobile application that displays a list of the most recent public photos posted to Flickr. The application should display a total number of photos in the list. The application should also support filtering via a basic search/filter component. The application should display a list of thumbnails with some basic metadata (title etc.) and allow a user to click on a thumbnail to display a more high resolution version of the image.

## Mandatories

The application must run on a version which is within 1 major release of the most recently available OS version for your target platform. The application must start and display a list of recent photographs

## Specs

You may use an IDE or any other tooling of your choice. Default application icons are acceptable. You may use any third party, OSS, library of your choice as long as that library is permissive and may be used in a commercial context. You may use any automated testing framework of your choice.
