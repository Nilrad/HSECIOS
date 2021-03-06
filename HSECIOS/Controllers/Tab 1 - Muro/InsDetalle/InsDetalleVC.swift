import UIKit

class InsDetalleVC: UIViewController {
    
    var oldSegmentIndex = 0
    
    @IBOutlet weak var tabs: UISegmentedControl!
    
    @IBOutlet weak var tabsScroll: UIScrollView!
    
    @IBOutlet weak var tabsInfBar: UIView!
    
    var inspeccion = MuroElement()
    
    var codigoInsObservacion = ""
    var correlativoInsObservacion = ""
    var shouldReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabs.customize(self.tabsInfBar)
        self.automaticallyAdjustsScrollViewInsets = false
        Utils.setTitleAndImage(self, "Inspección", Images.inspeccion)
        selectTab(Tabs.indexInsDetalle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.shouldReload {
            self.shouldReload = false
            selectTab(Tabs.indexInsDetalle)
        }
    }
    
    func focusScroll() {
        let height = tabs.frame.height
        let width = tabs.frame.width
        let singleTabWidth = width/CGFloat(tabs.numberOfSegments)
        let rect = CGRect.init(
            x: singleTabWidth*CGFloat(tabs.selectedSegmentIndex),
            y: CGFloat(0),
            width: singleTabWidth,
            height: height)
        tabsScroll.scrollRectToVisible(rect, animated: true)
    }
    
    func selectTab(_ index: Int) {
        tabs.selectedSegmentIndex = index
        let slider = self.childViewControllers[0] as! InsDetallePVC
        var direction = UIPageViewControllerNavigationDirection.forward
        let newSegmentIndex = tabs.selectedSegmentIndex
        if newSegmentIndex < oldSegmentIndex {
            direction = UIPageViewControllerNavigationDirection.reverse
        }
        oldSegmentIndex = newSegmentIndex
        focusScroll()
        slider.setViewControllers([Tabs.forInsDetalle[tabs.selectedSegmentIndex]], direction: direction, animated: true, completion: nil)
    }
    
    @IBAction func clickEnSegment(_ sender: Any) {
        let slider = self.childViewControllers[0] as! InsDetallePVC
        var direction = UIPageViewControllerNavigationDirection.forward
        let newSegmentIndex = tabs.selectedSegmentIndex
        if newSegmentIndex < oldSegmentIndex {
            direction = UIPageViewControllerNavigationDirection.reverse
        }
        oldSegmentIndex = newSegmentIndex
        focusScroll()
        slider.setViewControllers([Tabs.forInsDetalle[tabs.selectedSegmentIndex]], direction: direction, animated: true, completion: nil)
    }
}
