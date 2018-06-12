Pod::Spec.new do |ss|
  ss.name       = 'RFAlpha'
  ss.version    = '0.4.4'
  ss.summary    = 'RFUI: Alpha components.'
  ss.homepage   = 'https://github.com/RFUI/Alpha'
  ss.license    = { :type => 'MIT' }
  ss.authors    = { 'BB9z' => 'BB9z@me.com' }
  ss.source     = {
    :git => 'https://github.com/RFUI/Alpha.git'
    # No tag here
  }
  
  ss.ios.deployment_target = '6.0'
  ss.osx.deployment_target = '10.8'
  ss.watchos.deployment_target = '2.0'
  ss.tvos.deployment_target = '9.0'

  ss.exclude_files = 'Test'
  ss.requires_arc = true
  
  ss.subspec 'RFAudioPlayer' do |s|
    s.ios.deployment_target = '6.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFAudioPlayer/*.{h,m}'
    s.public_header_files = 'RFAudioPlayer/*.h'

    s.framework = 'AVFoundation'
  end

  ss.subspec 'RFBlockSelectorPerform' do |s|
    s.source_files = 'RFBlockSelectorPerform/*.{h,m}'
    s.public_header_files = 'RFBlockSelectorPerform/*.h'
  end

  ss.subspec 'RFButton' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFInitializing', '>=1.1'
    s.source_files = 'RFButton/*.{h,m}'
    s.public_header_files = 'RFButton/*.h'
  end

  ss.subspec 'RFCallbackControl' do |s|
    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/NSArray'
    s.source_files = 'RFCallbackControl/*.{h,m}'
    s.public_header_files = 'RFCallbackControl/*.h'
  end

  ss.subspec 'RFCarouselView' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFAlpha/RFTimer'
    s.dependency 'RFInitializing', '>=1.1'
    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/UIView+RFAnimate'
    s.dependency 'RFKit/Category/UIView'
    s.source_files = 'RFCarouselView/*.{h,m}'
    s.public_header_files = 'RFCarouselView/*.h'
  end

  ss.subspec 'RFCheckbox' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFAlpha/RFButton'
    s.source_files = 'RFCheckbox/*.{h,m}'
    s.public_header_files = 'RFCheckbox/*.h'
  end

  ss.subspec 'RFContainerView' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/UIView'
    s.dependency 'RFKit/Category/UIViewController'
    s.dependency 'RFInitializing', '>=1.1'
    s.source_files = 'RFContainerView/*.{h,m}'
    s.public_header_files = 'RFContainerView/*.h'
  end

  ss.subspec 'RFDataSourceArray' do |s|
    s.source_files = 'RFDataSourceArray/*.{h,m}'
    s.public_header_files = 'RFDataSourceArray/*.h'
  end

  ss.subspec 'RFDelegateChain' do |s|
    s.subspec 'Chain' do |ss|
      ss.osx.deployment_target = '10.8'
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.watchos.deployment_target = '2.0'

      ss.dependency 'RFKit/Runtime', '>=1.7.1'
      ss.dependency 'RFInitializing', '>=1.1'
      ss.source_files = 'RFDelegateChain/*.{h,m}'
      ss.public_header_files = 'RFDelegateChain/*.h'
    end

    s.subspec 'UIScrollViewDelegate' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = 'RFDelegateChain/UIKit/UIScrollViewDelegateChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UIScrollViewDelegateChain.h'
    end

    s.subspec 'UICollectionViewDataSource' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = 'RFDelegateChain/UIKit/UICollectionViewDataSourceChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UICollectionViewDataSourceChain.h'
    end

    s.subspec 'UICollectionViewDelegate' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.dependency 'RFAlpha/RFDelegateChain/UIScrollViewDelegate'
      ss.source_files = 'RFDelegateChain/UIKit/UICollectionViewDelegateChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UICollectionViewDelegateChain.h'
    end

    s.subspec 'UICollectionViewDelegateFlowLayout' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.dependency 'RFAlpha/RFDelegateChain/UICollectionViewDelegate'
      ss.source_files = 'RFDelegateChain/UIKit/UICollectionViewDelegateFlowLayoutChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UICollectionViewDelegateFlowLayoutChain.h'
    end

    s.subspec 'UISearchBarDelegate' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = 'RFDelegateChain/UIKit/UISearchBarDelegateChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UISearchBarDelegateChain.h'
    end

    s.subspec 'UITextFieldDelegate' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = 'RFDelegateChain/UIKit/UITextFiledDelegateChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UITextFiledDelegateChain.h'
    end

    s.subspec 'UITextViewDelegate' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.tvos.deployment_target = '9.0'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = 'RFDelegateChain/UIKit/UITextViewDelegateChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UITextViewDelegateChain.h'
    end

    s.subspec 'UIWebViewDelegate' do |ss|
      ss.ios.deployment_target = '6.0'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = 'RFDelegateChain/UIKit/UIWebViewDelegateChain.{h,m}'
      ss.public_header_files = 'RFDelegateChain/UIKit/UIWebViewDelegateChain.h'
    end
  end # RFDelegateChain

  ss.subspec 'RFDispatchTimer' do |s|
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.8'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.source_files = 'RFDispatchTimer/*.{h,m}'
    s.public_header_files = 'RFDispatchTimer/*.h'
  end

  ss.subspec 'RFDrawImage' do |s|
    s.ios.deployment_target = '6.0'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFDrawImage/*.{h,m}'
    s.public_header_files = 'RFDrawImage/*.h'
  end

  ss.subspec 'RFImageCropper' do |s|
    s.ios.deployment_target = '6.0'
    # s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/UIColor'
    s.dependency 'RFKit/Category/UIImage'
    s.dependency 'RFKit/Category/UIView'
    s.dependency 'RFKit/Category/UIView+RFAnimate'
    s.dependency 'RFInitializing', '>=1.1'
    s.source_files = 'RFImageCropper/*.{h,m}'
    s.public_header_files = 'RFImageCropper/*.h'
  end

  ss.subspec 'RFKVOWrapper' do |s|
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.8'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFKVOWrapper/*.{h,m}'
    s.public_header_files = 'RFKVOWrapper/*.h'
  end

  ss.subspec 'RFNavigationController' do |s|
    s.ios.deployment_target = '7.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/NSError'
    s.dependency 'RFKit/Category/UIView'
    s.dependency 'RFKit/Category/UIView+RFAnimate'
    s.dependency 'RFKit/Category/UIViewController+RFInterfaceOrientation'
    s.dependency 'RFAlpha/RFTransitioning/NavigationControllerTransition'
    s.source_files = 'RFNavigationController/*.{h,m}'
    s.public_header_files = 'RFNavigationController/*.h'
  end

  ss.subspec 'RFRefreshButton' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/UIView'
    s.dependency 'RFInitializing', '>=1.1'
    s.source_files = 'RFRefreshButton/*.{h,m}'
    s.public_header_files = 'RFRefreshButton/*.h'
  end

  ss.subspec 'RFRefreshControl' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFRefreshControl/*.{h,m}'
    s.public_header_files = 'RFRefreshControl/*.h'
  end

  ss.subspec 'RFScrollViewPageControl' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFInitializing', '>=1.1'
    s.dependency 'RFAlpha/RFKVOWrapper'
    s.source_files = 'RFScrollViewPageControl/*.{h,m}'
    s.public_header_files = 'RFScrollViewPageControl/*.h'
  end

  ss.subspec 'RFSerialTaskOperationController' do |s|
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.8'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFSerialTaskOperationController/*.{h,m}'
    s.public_header_files = 'RFSerialTaskOperationController/*.h'
  end

  ss.subspec 'RFSliderView' do |s|
    s.ios.deployment_target = '6.0'

    s.dependency 'RFAlpha/RFTimer'
    s.dependency 'RFInitializing', '>=1.1'
    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/UIView+RFAnimate'
    s.dependency 'RFKit/Category/UIView'
    s.source_files = 'RFSliderView/*.{h,m}'
    s.public_header_files = 'RFSliderView/*.h'
  end

  ss.subspec 'RFSound' do |s|
    s.ios.deployment_target = '6.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFSound/*.{h,m}'
    s.public_header_files = 'RFSound/*.h'
    s.framework = ['AudioToolbox', 'MediaPlayer']
  end

  ss.subspec 'RFSwizzle' do |s|
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.8'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFSwizzle/*.{h,m}'
    s.public_header_files = 'RFSwizzle/*.h'
  end

  ss.subspec 'RFSynthesize' do |s|
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.8'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.source_files = 'RFSynthesize/*.{h,m}'
    s.public_header_files = 'RFSynthesize/*.h'
  end

  ss.subspec 'RFTabController' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/NSArray'
    s.dependency 'RFKit/Category/UIView'
    s.dependency 'RFInitializing', '>=1.1'
    s.dependency 'RFAlpha/RFDataSourceArray'
    s.source_files = 'RFTabController/*.{h,m}'
    s.public_header_files = 'RFTabController/*.h'
  end

  ss.subspec 'RFTableViewAutoFetchDataSource' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFAlpha/RFDelegateChain/Chain'
    s.source_files = 'RFTableViewAutoFetchDataSource/*.{h,m}'
    s.public_header_files = 'RFTableViewAutoFetchDataSource/*.h'
    s.framework = 'CoreData'
  end

  ss.subspec 'RFTableViewCellHeightDelegate' do |s|
    s.ios.deployment_target = '6.0'

    s.dependency 'RFAlpha/RFDelegateChain/Chain'
    s.dependency 'RFKit/Runtime', '>=1.7.1'
    s.dependency 'RFKit/Category/UIView+RFAnimate'
    s.source_files = 'RFTableViewCellHeightDelegate/*.{h,m}'
    s.public_header_files = 'RFTableViewCellHeightDelegate/*.h'
  end

  ss.subspec 'RFTableViewPullToFetchPlugin' do |s|
    s.ios.deployment_target = '6.0'

    s.dependency 'RFAlpha/RFDelegateChain/Chain'
    s.dependency 'RFKit/Category/UIView+RFAnimate'
    s.dependency 'RFKit/Category/UIView'
    s.dependency 'RFAlpha/RFKVOWrapper'
    s.source_files = 'RFTableViewPullToFetchPlugin/*.{h,m}'
    s.public_header_files = 'RFTableViewPullToFetchPlugin/*.h'
  end

  ss.subspec 'RFTimer' do |s|
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.8'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'

    s.source_files = 'RFTimer/*.{h,m}'
    s.public_header_files = 'RFTimer/*.h'
  end

  ss.subspec 'RFTransitioning' do |s|
    s.ios.deployment_target = '7.0'

    s.subspec 'Core' do |ss|
      ss.dependency 'RFKit/Runtime', '>=1.7.1'
      ss.dependency 'RFInitializing', '>=1.1'
      ss.source_files = [
        'RFTransitioning/RFAnimationTransitioning.{h,m}'
      ]
      ss.public_header_files = [
        'RFTransitioning/RFAnimationTransitioning.h'
      ]
    end

    s.subspec 'NavigationControllerTransition' do |ss|
      ss.dependency 'RFAlpha/RFTransitioning/Core'
      ss.dependency 'RFAlpha/RFDelegateChain/Chain'
      ss.source_files = [
        'RFTransitioning/RFNavigation*.{h,m}',
        'RFTransitioning/UIViewController+RFTransitioning.{h,m}'
      ]
      ss.public_header_files = [
        'RFTransitioning/RFNavigation*.h',
        'RFTransitioning/UIViewController+RFTransitioning.h'
      ]
    end

    s.subspec 'PullDownToPopInteraction' do |ss|
      ss.dependency 'RFAlpha/RFTransitioning/Core'
      ss.dependency 'RFAlpha/RFTransitioning/NavigationControllerTransition'
      ss.dependency 'RFKit/Category/UIView+RFAnimate'
      ss.source_files = 'RFTransitioning/RFInteractiveTransitioning/RFPullDownToPopInteractionController.{h,m}'
      ss.public_header_files = 'RFTransitioning/RFInteractiveTransitioning/RFPullDownToPopInteractionController.h'
    end

    s.subspec 'MagicMoveTransitioningStyle' do |ss|
      ss.dependency 'RFAlpha/RFTransitioning/Core'
      ss.dependency 'RFKit/Category/UIView'
      ss.dependency 'RFKit/Category/UIView+RFAnimate'
      ss.source_files = 'RFTransitioning/RFTransitioningStyle/RFMagicMoveTransitioning.{h,m}'
      ss.public_header_files = 'RFTransitioning/RFTransitioningStyle/RFMagicMoveTransitioning.h'
    end

    s.subspec 'MoveInFromBottomTransitioningStyle' do |ss|
      ss.dependency 'RFAlpha/RFTransitioning/Core'
      ss.dependency 'RFAlpha/RFTransitioning/PullDownToPopInteraction'
      ss.source_files = 'RFTransitioning/RFTransitioningStyle/RFMoveInFromBottomTransitioning.{h,m}'
      ss.public_header_files = 'RFTransitioning/RFTransitioningStyle/RFMoveInFromBottomTransitioning.h'
    end
  end # RFTransitioning

  ss.subspec 'RFViewApperance' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.subspec 'RFDrawView' do |ss|
      ss.dependency 'RFKit/Runtime', '>=1.7.1'
      ss.dependency 'RFInitializing', '>=1.1'
      ss.source_files = 'RFViewApperance/RFDrawView.{h,m}'
      ss.public_header_files = 'RFViewApperance/RFDrawView.h'
    end

    s.subspec 'RFLine' do |ss|
      ss.dependency 'RFAlpha/RFViewApperance/RFDrawView'
      ss.dependency 'RFKit/Category/UIView+RFAnimate'
      ss.source_files = 'RFViewApperance/RFLine.{h,m}'
      ss.public_header_files = 'RFViewApperance/RFLine.h'
    end

    s.subspec 'RFRoundingCornersView' do |ss|
      ss.dependency 'RFAlpha/RFViewApperance/RFDrawView'
      ss.source_files = 'RFViewApperance/RFRoundingCornersView.{h,m}'
      ss.public_header_files = 'RFViewApperance/RFRoundingCornersView.h'
    end

    s.subspec 'RFLayerApperance' do |ss|
      ss.dependency 'RFKit/Category/UIDevice'
      ss.source_files = 'RFViewApperance/UIView+RFLayerApperance.{h,m}'
      ss.public_header_files = 'RFViewApperance/UIView+RFLayerApperance.h'
      ss.framework = 'QuartzCore'
    end

    s.subspec 'RFPatternImageBackground' do |ss|
      ss.dependency 'RFKit/Category/UIColor'
      ss.source_files = 'RFViewApperance/UIView+RFPatternImageBackground.{h,m}'
      ss.public_header_files = 'RFViewApperance/UIView+RFPatternImageBackground.h'
    end

  end # RFViewApperance

  ss.subspec 'RFWindow' do |s|
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'

    s.dependency 'RFInitializing', '>=1.1'
    s.source_files = 'RFWindow/*.{h,m}'
    s.public_header_files = 'RFWindow/*.h'
  end
end

# http://guides.cocoapods.org/syntax/podspec.html
