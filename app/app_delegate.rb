# -*- coding: utf-8 -*-
class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    documents_path         = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
    NanoStore.shared_store = NanoStore.store(:file, documents_path + "/mobiletouch.db")
    # ドリルダウンの遷移を作りたいので EntriesController のインスタンスを作り、UINavigationController の中に入れる
    articles_controller = ArticlesController.new
    navigation_controller = UINavigationController.alloc.initWithRootViewController(articles_controller)
    @window.rootViewController = navigation_controller
    @window.makeKeyAndVisible
    true
  end
end
