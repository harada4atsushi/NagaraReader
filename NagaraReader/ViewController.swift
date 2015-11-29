import UIKit

class ViewController: UIViewController, MEMELibDelegate, UISearchBarDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var blinkTimes : [NSDate] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
        searchBar.delegate = self
        webView.delegate = self
        loadAddressURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
    }
    
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connectPeripheral(peripheral)
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        if data.blinkStrength > 0 {
            blinkTimes.append(NSDate())
            
            if blinkTimes.count > 3 {
                blinkTimes.removeFirst()
            }
            
            // 2秒間以内に3回のまばたきをした場合
            if blinkTimes.count == 3 {
                let diffTime = blinkTimes.last!.timeIntervalSinceDate(blinkTimes.first!)
                if diffTime < 2 {
                    print(diffTime)
                    blinkTimes = []
                    
                    // 一番下へスクロール
                    //webView.scrollView.setContentOffset(CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.frame.size.height), animated: true)
                    
                    // いい感じの位置へスクロール
                    let currentY = webView.scrollView.contentOffset.y
                    webView.scrollView.setContentOffset(CGPointMake(0, currentY + webView.scrollView.frame.size.height - 200), animated: true)
                }
            }
        }
    }
    
    func loadAddressURL() {
        let requestURL = NSURL(string: searchBar.text!)
        print("requestURL: " + String(requestURL))
        let req = NSURLRequest(URL: requestURL!)
        webView.loadRequest(req)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        searchBar.text = webView.stringByEvaluatingJavaScriptFromString("document.URL")
    }
    
    func searchBarSearchButtonClicked( searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        loadAddressURL()
    }
    
    @IBAction func back(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: AnyObject) {
        webView.goForward()
    }
    
}