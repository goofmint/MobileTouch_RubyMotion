# -*- coding: utf-8 -*-
class ArticlesController < UITableViewController
  # ビューが読み込まれた後で実行されるメソッド
  def viewDidLoad
    super
    self.title = "Mobile Touch - 新着エントリー"
    @entries = [] # 取得したエントリをこのインスタンス変数に格納
    url = 'http://mobiletou.ch/api/articles/side.json?with_body=true'
    # 前回に引き続き BubbleWrap を使う
    BW::HTTP.get(url) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_s)
        @entries = json['articles']
        self.tableView.reloadData # テーブルをリロード
      else
        p response.error_message
      end
    end
  end

  # テーブルの行数を返すメソッド
  def tableView(tableView, numberOfRowsInSection:section)
    @entries.count
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    entry = @entries[indexPath.row]
    body = entry['post_content']
    # UIWebView を貼り付けたビューコントローラを作成
    controller = UIViewController.new
    webview = UIWebView.new
    webview.frame = controller.view.frame # webview の表示サイズを調整
    controller.view.addSubview(webview)
    navigationController.pushViewController(controller, animated:true)
    html = '<html><head><meta http-equiv="Content-Style-Type" content="text/css">
            <link rel="stylesheet" href="style.css" type="text/css" />
            <script src="jquery.js" type="text/javascript"></script></head>
            <body>'+body.flavoredHTMLStringFromMarkdown+'</body></html>'
    html = html.gsub("src=\"//", "src=\"http://")
    url = NSURL.fileURLWithPath NSBundle.mainBundle.bundlePath
    webview.loadHTMLString(html, baseURL:url)
  end

  # テーブルのセルを返すメソッド
  ENTRY_CELL_ID = 'Article'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(ENTRY_CELL_ID)
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:ENTRY_CELL_ID)
    end
    article = @entries[indexPath.row]
    # ラベルをセット
    cell.textLabel.text = article['post_title']
    cell.detailTextLabel.text = "#{article['pub_date']} by #{article['author']['display_name']}"
    cell
  end
end
