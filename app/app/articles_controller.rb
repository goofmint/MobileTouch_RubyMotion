# -*- coding: utf-8 -*-
class ArticlesController < UITableViewController
  # ビューが読み込まれた後で実行されるメソッド
  def viewDidLoad
    super
    self.title = "Mobile Touch - 新着エントリー"
    @articles = [] # 取得したエントリをこのインスタンス変数に格納
    # 既存データを読み込む
    @articles = Article.all({:sort => {:pub_date => :desc}}).mutableCopy
    if @articles.empty?
      @articles = []
    else
      self.tableView.reloadData
    end
    url = 'http://mobiletou.ch/api/articles/side.json?with_body=true'
    # 前回に引き続き BubbleWrap を使う
    date_formatter = NSDateFormatter.alloc.init
    date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    BW::HTTP.get(url) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_s)
        json['articles'].reverse.each do |article|
          article_id = article['web_url'].gsub(/^.*p=([0-9]*)$/, '\\1')
          next if @articles.map(&:id).include?(article_id.to_i)
          date = date_formatter.dateFromString article['updated_at']
          @articles.unshift Article.create(:id => article_id.to_i, :json => BW::JSON.generate(article), :pub_date => date)
        end
        self.tableView.reloadData # テーブルをリロード
      else
        p response.error_message
      end
    end
  end

  # テーブルの行数を返すメソッド
  def tableView(tableView, numberOfRowsInSection:section)
    @articles.count
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    article = @articles[indexPath.row]
    json = BW::JSON.parse(article.json.to_s.dataUsingEncoding(4, allowLossyConversion:false))
    body = json['post_content']
    # UIWebView を貼り付けたビューコントローラを作成
    controller = UIViewController.new
    webview = UIWebView.new
    webview.frame = controller.view.frame # webview の表示サイズを調整
    controller.view.addSubview(webview)
    navigationController.pushViewController(controller, animated:true)
    html = <<-EOS
      <html><head><meta http-equiv="Content-Style-Type" content="text/css">
      <link rel="stylesheet" href="style.css" type="text/css" />
      <script src="jquery.js" type="text/javascript"></script></head>
    <body>#{body.flavoredHTMLStringFromMarkdown}</body></html>
    EOS
    html = html.gsub("src=\"//", "src=\"http://")
    url = NSURL.fileURLWithPath NSBundle.mainBundle.bundlePath
    webview.loadHTMLString(html, baseURL:url)
  end

  # テーブルのセルを返すメソッド
  ARTICLE_CELL_ID = 'Article'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(ARTICLE_CELL_ID)
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:ARTICLE_CELL_ID)
    end
    article = @articles[indexPath.row]
    json = BW::JSON.parse(article.json.to_s.dataUsingEncoding(4, allowLossyConversion:false))
    # ラベルをセット
    cell.textLabel.text = json['post_title']
    cell.detailTextLabel.text = "#{json['pub_date']} by #{json['author']['display_name']}"
    cell
  end
end
