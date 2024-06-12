# TabletxNasa App

## Summary

The TabletxNasa app is an iOS application that allows users to search for and view images from the NASA Image Library. The app is built using Swift and follows the Model-View-ViewModel (MVVM) architectural pattern. Key features of the app include:

- **Search Functionality**: Users can search for images using keywords.
- **Image Display**: Thumbnails of the images are displayed in a grid layout.
- **Detail View**: Tapping on a thumbnail opens a detail view with more information about the image.
- **Filtering**: Users can filter search results by specifying a date range.
- **Pagination**: The app supports pagination to load more images as the user scrolls.
- **Caching**: Images are cached to improve performance and reduce network usage.
- **Concurrency**: The app uses Swift Concurrency for asynchronous tasks.

## Features

### Main Features

1. **Search Bar**: Allows users to search for NASA images by keywords.
2. **Grid Display**: Images are displayed in a grid layout using `UICollectionView`. Items per can be configured by toggling the filter option(Ideally would go into settings)
3. **Detail View**: Detailed information about each image, including title, description, photographer, and location.
4. **Year Range Picker**: Users can filter images by specifying a start and end year.
5. **Load More**: Supports pagination to load more images on demand.
6. **Cache Management**: Images are cached to reduce network calls and improve performance.

### Architecture

The app follows the Model-View-ViewModel (MVVM) architectural pattern, which promotes separation of concerns and enhances testability.

1. **Model**: Represents the data and business logic of the app. In this case, `NASAImage` is the primary model representing the image data fetched from the NASA API.

2. **ViewModel**: Acts as an intermediary between the View and Model. It handles the business logic and prepares data for presentation in the View. The ViewModel also handles the interaction with the network service and image cache. In this app, we have two primary view models:
    - `NASAImageViewModel`: Handles the logic for fetching and managing a list of NASA images, including search, pagination, and filtering.
    - `NASAImageDetailViewModel`: Manages the detailed view of a single NASA image, including loading the image from the network or cache.

3. **View**: The UI components that present data to the user. Views are updated based on changes in the ViewModel. The primary views in this app include:
    - `NASAImageListViewController`: Displays the list of NASA images in a grid layout and handles user interactions such as searching and loading more images.
    - `NASAImageDetailViewController`: Shows detailed information about a selected image, including the title, description, photographer, and location.

4. **Network Service**: A protocol-based service (`NetworkServiceProtocol`) that handles network requests to fetch data from the NASA API. The actual implementation (`NetworkService`) performs the network calls, and a mock implementation (`MockNetworkService`) is used for testing purposes.

5. **Image Cache**: A protocol-based cache (`ImageCacheProtocol`) that manages the caching of images to improve performance and reduce network usage. The actual implementation (`ImageCache`) stores images in memory, and a mock implementation (`MockImageCache`) is used for testing purposes.

### Future Work

1. **Improved Error Handling**: Enhance error messages and handling, especially for network-related issues.
2. **Better Offline Support**: Implement better offline support by storing previously fetched data for offline access.
3. **Enhanced Filtering**: Add more filtering options, such as media type, location, and more.
4. **User Preferences**: Save user preferences for search keywords and filters.
5. **Accessibility**: Improve accessibility features for a wider range of users.
6. **Performance Optimization**: Further optimize image loading and caching/purging mechanisms.
7. **UI Enhancements**: Improve the UI better design ideas

## Installation

To run the app locally, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/your-repo/TabletxNasa.git
    ```
2. Open the project in Xcode:
    ```bash
    cd TabletxNasa
    open TabletxNasa.xcodeproj
    ```
3. Build and run the app in Xcode.
