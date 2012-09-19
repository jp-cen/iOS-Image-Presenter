# iOS-Image-Presenter

Instructions:

1. Copy the methods into your base viewController Class 
	viewImage:view:viewBounds:
	dismissImageView 

2. Add the following declarations to the header files 
	UIImageView *popupImageView;
    UIView *popupImageViewContainer;
    CGRect savedRect;

3. Add the UIScrollViewDelegate protocol to your viewController

4. Copy the following methods into the viewController
	scrollViewDidEndZooming:withView:atScale:(float) 
	viewForZoomingInScrollView:

5. Call the viewImage:view:viewBounds class with the image, containerView and frame of the image when you want to present an image

Known Issues:
Only supports portrait mode