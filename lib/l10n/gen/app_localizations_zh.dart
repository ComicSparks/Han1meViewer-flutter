// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'HaVF';

  @override
  String get home => '首页';

  @override
  String get search => '搜索';

  @override
  String get downloads => '下载';

  @override
  String get mine => '我的';

  @override
  String get settings => '设置';

  @override
  String get more => '更多';

  @override
  String get retry => '重试';

  @override
  String get refresh => '刷新';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get saved => '已保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get rename => '重命名';

  @override
  String get add => '添加';

  @override
  String get clear => '清空';

  @override
  String get cleared => '已清理';

  @override
  String get apply => '应用';

  @override
  String get reset => '重置';

  @override
  String get open => '打开';

  @override
  String get all => '全部';

  @override
  String get empty => '这里什么都没有';

  @override
  String get share => '分享';

  @override
  String get linkCopied => '链接已复制';

  @override
  String get copied => '已复制';

  @override
  String get needPro => '发电后才能使用';

  @override
  String get exportNameTooLong => '文件名或路径过长，将缩短标题后再导出';

  @override
  String get multiSelect => '多选';

  @override
  String selectedCount(int count) {
    return '已选 $count 项';
  }

  @override
  String downloadQueued(int added, int skipped) {
    return '已加入 $added 个，跳过 $skipped 个';
  }

  @override
  String get subscriptionUpdates => '订阅更新提示';

  @override
  String get subscriptionUpdatesHint => '标出上次查看订阅之后出现的新影片';

  @override
  String get playing => '播放中';

  @override
  String get removed => '已移除';

  @override
  String get description => '简介';

  @override
  String get followSystem => '跟随系统';

  @override
  String get errTimeout => '连接超时';

  @override
  String get errDns => '域名解析失败，可尝试开启内置 Hosts 或 DoH';

  @override
  String get errTls => 'TLS 握手失败';

  @override
  String get errProxy => '代理连接失败';

  @override
  String get errNetwork => '网络错误';

  @override
  String get errCfChallenge => 'Cloudflare 验证未通过';

  @override
  String get errCfMismatch => '验证凭据与当前网络环境不匹配，请重新验证';

  @override
  String get errIpBlocked => '当前 IP 被站点拒绝，请更换网络或代理';

  @override
  String get errNotFound => '内容不存在';

  @override
  String get errNotLoggedIn => '请先登录';

  @override
  String get errLoginExpired => '登录已过期，请重新登录';

  @override
  String get errLoginFailed => '登录失败';

  @override
  String get errParse => '页面解析失败，站点可能已改版';

  @override
  String get errExists => '已经下载过了';

  @override
  String get errInvalid => '输入无效';

  @override
  String get errInvalidImage => '图片无效';

  @override
  String errHttp(String code) {
    return '服务器返回 $code';
  }

  @override
  String get cfVerifyTitle => '站点验证';

  @override
  String get cfVerifyHint => '请完成 Cloudflare 人机验证，通过后会自动返回';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirm => '确定退出登录？';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get webLogin => '网页登录';

  @override
  String get webLoginHint => '推荐。在内置浏览器里登录，可顺带完成人机验证';

  @override
  String get formLogin => '账号密码登录';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get cookieLogin => '导入 Cookie';

  @override
  String get cookieLoginHint => '从浏览器复制站点 Cookie 粘贴到这里';

  @override
  String get importCookie => '导入';

  @override
  String get searchHint => '搜索影片、作者…';

  @override
  String get pasteLink => '从剪贴板打开链接';

  @override
  String get noLinkInClipboard => '剪贴板里没有影片链接';

  @override
  String get filter => '筛选';

  @override
  String get searchEmptyHint => '输入关键词或使用筛选开始搜索';

  @override
  String get browseAll => '浏览全部';

  @override
  String get searchHistory => '搜索历史';

  @override
  String get genre => '类型';

  @override
  String get sort => '排序';

  @override
  String get releaseDate => '发布时间';

  @override
  String get duration => '时长';

  @override
  String get broadMatch => '广泛匹配';

  @override
  String get broadMatchHint => '标签之间按「或」匹配';

  @override
  String get brands => '品牌';

  @override
  String get tagVideoAttributes => '影片属性';

  @override
  String get tagRelationships => '人物关系';

  @override
  String get tagCharacteristics => '角色设定';

  @override
  String get tagAppearance => '外貌身材';

  @override
  String get tagLocation => '故事场景';

  @override
  String get tagPlot => '故事剧情';

  @override
  String get tagPositions => '性交体位';

  @override
  String get intro => '简介';

  @override
  String get comments => '评论';

  @override
  String get noComments => '还没有评论';

  @override
  String get commentHint => '发表评论…';

  @override
  String get commentSent => '已发送';

  @override
  String get reply => '回复';

  @override
  String viewReplies(int count) {
    return '查看 $count 条回复';
  }

  @override
  String get report => '举报';

  @override
  String get reportSent => '已举报';

  @override
  String get favorite => '喜欢';

  @override
  String get favorites => '喜欢的影片';

  @override
  String get watchLater => '稍后观看';

  @override
  String get addedToWatchLater => '已加入稍后观看';

  @override
  String get playlist => '播放清单';

  @override
  String get playlists => '播放清单';

  @override
  String get addToPlaylist => '加入播放清单';

  @override
  String get newPlaylist => '新建清单';

  @override
  String get editPlaylist => '编辑清单';

  @override
  String get playlistTitle => '清单名称';

  @override
  String get playlistCreated => '已创建清单';

  @override
  String get deletePlaylistConfirm => '确定删除这个清单？';

  @override
  String get removeFromList => '从列表中移除？';

  @override
  String videoCount(int count) {
    return '$count 部影片';
  }

  @override
  String get download => '下载';

  @override
  String get downloaded => '已下载';

  @override
  String get downloadAdded => '已加入下载队列';

  @override
  String get chooseQuality => '选择画质';

  @override
  String get related => '相关影片';

  @override
  String get subscribe => '订阅';

  @override
  String get subscribed => '已订阅';

  @override
  String get subscriptions => '订阅';

  @override
  String get playError => '播放失败';

  @override
  String get brightness => '亮度';

  @override
  String get volume => '音量';

  @override
  String get speed => '倍速';

  @override
  String get quality => '画质';

  @override
  String get fullscreen => '全屏';

  @override
  String get hKeyframes => 'H 关键帧';

  @override
  String addKeyframeAt(String time) {
    return '在 $time 添加关键帧';
  }

  @override
  String get keyframePromptHint => '备注（可选）';

  @override
  String get keyframeAdded => '已添加关键帧';

  @override
  String get keyframesEmptyHint => '还没有关键帧，播放时长按书签按钮可快速添加';

  @override
  String sharedBy(String author) {
    return '共享关键帧 · 作者 $author';
  }

  @override
  String get localKeyframes => '我的关键帧';

  @override
  String get sharedKeyframes => '共享关键帧';

  @override
  String get sharedKeyframesFirst => '优先使用共享关键帧';

  @override
  String get enableKeyframes => '启用 H 关键帧';

  @override
  String get enableKeyframesHint => '在进度条上标记并在临近时倒计时提醒';

  @override
  String get keyframeShowPrompt => '倒计时显示序号和备注';

  @override
  String get keyframeCountdown => '提前提醒秒数';

  @override
  String keyframeCount(int count) {
    return '$count 个关键帧';
  }

  @override
  String get notLoggedIn => '未登录';

  @override
  String get tapToLogin => '点击登录以同步喜欢、清单与历史';

  @override
  String get tapToManageAccount => '管理账号资料';

  @override
  String get localHistory => '本地观看记录';

  @override
  String get onlineHistory => '云端观看记录';

  @override
  String get clearHistoryConfirm => '确定清空全部观看记录？';

  @override
  String get deleteHistory => '删除这条记录？';

  @override
  String get sortLatest => '最新';

  @override
  String get sortPopular => '最热门';

  @override
  String get sortOldest => '最早';

  @override
  String get userSortDefault => '默认';

  @override
  String get userSortLatest => '最新';

  @override
  String get userSortPopular => '最热门';

  @override
  String get userSortOldest => '最早';

  @override
  String get account => '账号资料';

  @override
  String accountStats(int subs, int videos) {
    return '$subs 订阅者 · $videos 部影片';
  }

  @override
  String get profile => '个人资料';

  @override
  String get username => '用户名';

  @override
  String get changePassword => '修改密码';

  @override
  String get oldPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认新密码';

  @override
  String get downloading => '下载中';

  @override
  String get noDownloading => '没有进行中的下载';

  @override
  String get queued => '排队中';

  @override
  String get paused => '已暂停';

  @override
  String get failed => '失败';

  @override
  String get pauseAll => '全部暂停';

  @override
  String get resumeAll => '全部继续';

  @override
  String get newGroup => '新建分组';

  @override
  String get ungrouped => '未分组';

  @override
  String get deleteGroup => '删除分组';

  @override
  String get deleteGroupHint => '分组内的影片会移到「未分组」';

  @override
  String get moveToGroup => '移动到分组';

  @override
  String get deleteDownloadConfirm => '删除下载及本地文件？';

  @override
  String get saveToGallery => '保存到相册';

  @override
  String get exportFile => '导出文件';

  @override
  String get exported => '已导出';

  @override
  String get exportFailed => '导出失败';

  @override
  String downloadingNotification(int count, String title) {
    return '$count 个任务进行中 $title';
  }

  @override
  String get general => '通用';

  @override
  String get theme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '语言';

  @override
  String get videoLanguage => '站点字幕语言';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get traditionalChinese => '繁体中文';

  @override
  String get hideComments => '隐藏评论区';

  @override
  String get clipboardDetect => '剪贴板链接识别';

  @override
  String get clipboardDetectHint => '回到应用时检测剪贴板里的影片链接（iOS 会提示读取剪贴板）';

  @override
  String clipboardDetected(String code) {
    return '检测到影片 $code';
  }

  @override
  String get networkSettings => '网络设置';

  @override
  String get player => '播放器';

  @override
  String get defaultQuality => '默认画质';

  @override
  String get longPressSpeed => '长按倍速';

  @override
  String get gestures => '手势控制';

  @override
  String get gesturesHint => '左右滑动调进度，左侧上下调亮度，右侧上下调音量';

  @override
  String get resumePlayback => '从上次位置继续播放';

  @override
  String get fullscreenLandscape => '全屏时自动横屏';

  @override
  String get downloadConcurrency => '同时下载数';

  @override
  String get speedLimit => '下载限速';

  @override
  String get unlimited => '不限速';

  @override
  String get privacy => '隐私';

  @override
  String get appLock => '应用锁';

  @override
  String get appLockHint => '使用 PIN，可配合生物识别解锁';

  @override
  String get changePin => '修改 PIN';

  @override
  String get setPin => '设置 PIN';

  @override
  String get pinSetupHint => '输入 4–8 位数字';

  @override
  String get pinConfirm => '再输入一次';

  @override
  String get pinMismatch => '两次输入不一致';

  @override
  String get enterPin => '输入 PIN 解锁';

  @override
  String get pinWrong => 'PIN 错误';

  @override
  String get unlockReason => '解锁 HaVF';

  @override
  String get biometric => '生物识别解锁';

  @override
  String get lockDelay => '重新上锁';

  @override
  String get lockImmediately => '离开后立即';

  @override
  String get lockAfter1Min => '离开 1 分钟后';

  @override
  String get lockAfter5Min => '离开 5 分钟后';

  @override
  String get blurInBackground => '后台模糊';

  @override
  String get blurInBackgroundHint => '在多任务界面隐藏内容';

  @override
  String get disguiseIcon => '伪装图标';

  @override
  String get disguiseIconHint => '图标可能需要片刻才会在桌面上更新';

  @override
  String get iconDefault => '默认';

  @override
  String get iconCalc => '计算器';

  @override
  String get iconXxt => '学不通';

  @override
  String get storage => '存储';

  @override
  String get imageCache => '图片缓存';

  @override
  String get imageCacheLimit => '图片缓存上限';

  @override
  String get pageCache => '页面缓存';

  @override
  String get webviewData => '内置浏览器数据';

  @override
  String get clearCache => '清理缓存';

  @override
  String get clearCacheHint => '清理图片、页面与浏览器缓存，不影响下载和登录';

  @override
  String get about => '关于';

  @override
  String get discardChanges => '放弃未保存的修改？';

  @override
  String get domain => '站点域名';

  @override
  String get customMirror => '自定义镜像';

  @override
  String get dns => 'DNS';

  @override
  String get builtInHosts => '内置 Hosts';

  @override
  String get builtInHostsHint => '绕过 DNS 污染，直接连接 Cloudflare 节点';

  @override
  String get customIps => '自定义 IP（逗号分隔，留空使用内置）';

  @override
  String get dohServer => 'DoH 服务器';

  @override
  String get bootstrapIps => '引导 IP';

  @override
  String get timeout => '超时';

  @override
  String get dnsDiagnose => '测试解析';

  @override
  String get proxy => '代理';

  @override
  String get proxyMode => '代理模式';

  @override
  String get proxySystem => '跟随系统';

  @override
  String get proxyNone => '不使用';

  @override
  String get proxyHost => '代理地址';

  @override
  String get proxyPort => '代理端口';

  @override
  String get identity => '设备身份';

  @override
  String get deviceProfile => '随机设备';

  @override
  String get currentUserAgent => '当前 UA';

  @override
  String get followingWebview => '跟随 WebView';

  @override
  String get androidDisguise => 'Android 伪装';

  @override
  String get verifyNow => '立即进行站点验证';

  @override
  String get verifyNowHint => '在内置浏览器中打开站点完成 Cloudflare 验证';

  @override
  String get verifySuccess => '验证成功';

  @override
  String get verifyCancelled => '验证未完成';

  @override
  String get manualCfImport => '手动导入 cf_clearance';

  @override
  String get manualCfImportHint =>
      '从同一网络下的浏览器复制 cf_clearance 与该浏览器的 User-Agent，两者必须配对';

  @override
  String get clearCf => '清除验证凭据';

  @override
  String get regenerateIdentity => '重新生成设备身份';

  @override
  String get regenerateIdentityHint => '会清除现有 cf_clearance，可能需要重新验证';

  @override
  String get proTitle => '发电';

  @override
  String get proCenter => '发电中心';

  @override
  String get proPowered => '发电中';

  @override
  String get proNotPowered => '未发电';

  @override
  String get proGuide =>
      '发电状态绑定的是登录后的用户名。\n\n「我曾经发过电」同步已有状态\n「我刚才发了电」兑换代码\n「Patreon」是另一种发电方式\n更换「发电方式」可能解决连接失败';

  @override
  String get proSignIn => '签到/兑换';

  @override
  String get proPatreon => 'Patreon';

  @override
  String get proIHavePowered => '我曾经发过电';

  @override
  String get proIJustPowered => '我刚才发了电';

  @override
  String get proEnterCode => '输入代码';

  @override
  String get proPowerMethod => '发电方式';

  @override
  String get proChooseMethod => '选择发电方式';

  @override
  String get proClickPatToChange => '点击下面的 Patreon 进行变更';

  @override
  String get proUpdatePat => '更新 Patreon 状态';

  @override
  String get proBindAccount => '绑定到此账号';

  @override
  String get proChangePatKey => '更换 Patreon 密钥';

  @override
  String get proClearPat => '清除 Patreon 信息';

  @override
  String get proClickToBind => '点击绑定';

  @override
  String get proEnterAuthCode => '请输入授权代码';

  @override
  String get proPleaseWait => '请稍后';

  @override
  String get proKeyRecorded => '密钥已录入';

  @override
  String get proPatAccount => 'Patreon 账号';

  @override
  String get proBoundAccount => '绑定账号';

  @override
  String get proBindTime => '绑定时间';

  @override
  String get proRebindTime => '可以换绑时间';

  @override
  String get proPatBindHint => '请点击这里绑定到当前账号';

  @override
  String get proPatRebindHint => '绑定账号与当前登录用户名不一致，请换绑';

  @override
  String get proPatNotDetected => '未检测到入会';

  @override
  String get proPatNormal => '状态正常';

  @override
  String get proSynced => '已同步';

  @override
  String proPageLimit(int pages) {
    return '未发电只能看前 $pages 页';
  }

  @override
  String get proGo => '去发电';

  @override
  String get proErrNetworkTimeout => '网络超时，请检查网络或更换发电方式';

  @override
  String get proErrNetworkUnreachable => '连接不上服务器，请检查网络或更换发电方式';

  @override
  String get proErrServerFailed => '服务器处理失败';

  @override
  String get proErrServerInvalid => '服务器返回异常';

  @override
  String get proErrRequestInvalid => '请求无效';

  @override
  String get proErrOrderNotSynced => '订单尚未同步，请稍后再试';

  @override
  String get proErrOrderUsed => '订单已被使用';

  @override
  String get proErrOrderAmount => '订单金额无效';

  @override
  String get proErrTicketNotFound => '兑换券不存在';

  @override
  String get proErrTicketUsed => '兑换券已被使用';

  @override
  String get proErrTicketEventUsed => '活动兑换券已参与';

  @override
  String get proErrDeviceTime => '请检查设备时间';

  @override
  String get proErrPatNotBound => '尚未绑定密钥';

  @override
  String get browserAddressHint => '输入网址';

  @override
  String get browserBack => '后退';

  @override
  String get browserForward => '前进';

  @override
  String get checkUpdate => '检查更新';

  @override
  String get checkingUpdate => '正在检查更新';

  @override
  String get alreadyLatest => '已是最新版本';

  @override
  String newVersionFound(String version) {
    return '发现新版本 $version';
  }

  @override
  String get updateTitle => '发现新版本';

  @override
  String forceUpdateMessage(String version) {
    return '发现新版本 $version，请立即更新后继续使用';
  }

  @override
  String get downloadUpdate => '去下载';

  @override
  String get friendLinks => '友情链接';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => 'HaVF';

  @override
  String get home => '首頁';

  @override
  String get search => '搜尋';

  @override
  String get downloads => '下載';

  @override
  String get mine => '我的';

  @override
  String get settings => '設定';

  @override
  String get more => '更多';

  @override
  String get retry => '重試';

  @override
  String get refresh => '重新整理';

  @override
  String get ok => '確定';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get saved => '已儲存';

  @override
  String get delete => '刪除';

  @override
  String get edit => '編輯';

  @override
  String get rename => '重新命名';

  @override
  String get add => '新增';

  @override
  String get clear => '清空';

  @override
  String get cleared => '已清理';

  @override
  String get apply => '套用';

  @override
  String get reset => '重設';

  @override
  String get open => '開啟';

  @override
  String get all => '全部';

  @override
  String get empty => '這裡什麼都沒有';

  @override
  String get share => '分享';

  @override
  String get linkCopied => '連結已複製';

  @override
  String get copied => '已複製';

  @override
  String get needPro => '發電後才能使用';

  @override
  String get exportNameTooLong => '檔名或路徑過長，將縮短標題後再匯出';

  @override
  String get multiSelect => '多選';

  @override
  String selectedCount(int count) {
    return '已選 $count 項';
  }

  @override
  String downloadQueued(int added, int skipped) {
    return '已加入 $added 個，略過 $skipped 個';
  }

  @override
  String get subscriptionUpdates => '訂閱更新提示';

  @override
  String get subscriptionUpdatesHint => '標出上次查看訂閱之後出現的新影片';

  @override
  String get playing => '播放中';

  @override
  String get removed => '已移除';

  @override
  String get description => '簡介';

  @override
  String get followSystem => '跟隨系統';

  @override
  String get errTimeout => '連線逾時';

  @override
  String get errDns => '網域解析失敗，可嘗試開啟內建 Hosts 或 DoH';

  @override
  String get errTls => 'TLS 交握失敗';

  @override
  String get errProxy => '代理連線失敗';

  @override
  String get errNetwork => '網路錯誤';

  @override
  String get errCfChallenge => 'Cloudflare 驗證未通過';

  @override
  String get errCfMismatch => '驗證憑證與目前網路環境不符，請重新驗證';

  @override
  String get errIpBlocked => '目前 IP 被網站拒絕，請更換網路或代理';

  @override
  String get errNotFound => '內容不存在';

  @override
  String get errNotLoggedIn => '請先登入';

  @override
  String get errLoginExpired => '登入已過期，請重新登入';

  @override
  String get errLoginFailed => '登入失敗';

  @override
  String get errParse => '頁面解析失敗，網站可能已改版';

  @override
  String get errExists => '已經下載過了';

  @override
  String get errInvalid => '輸入無效';

  @override
  String get errInvalidImage => '圖片無效';

  @override
  String errHttp(String code) {
    return '伺服器回傳 $code';
  }

  @override
  String get cfVerifyTitle => '網站驗證';

  @override
  String get cfVerifyHint => '請完成 Cloudflare 人機驗證，通過後會自動返回';

  @override
  String get login => '登入';

  @override
  String get logout => '登出';

  @override
  String get logoutConfirm => '確定登出？';

  @override
  String get loginSuccess => '登入成功';

  @override
  String get webLogin => '網頁登入';

  @override
  String get webLoginHint => '推薦。在內建瀏覽器登入，可順帶完成人機驗證';

  @override
  String get formLogin => '帳號密碼登入';

  @override
  String get email => '電子郵件';

  @override
  String get password => '密碼';

  @override
  String get cookieLogin => '匯入 Cookie';

  @override
  String get cookieLoginHint => '從瀏覽器複製網站 Cookie 貼到這裡';

  @override
  String get importCookie => '匯入';

  @override
  String get searchHint => '搜尋影片、作者…';

  @override
  String get pasteLink => '從剪貼簿開啟連結';

  @override
  String get noLinkInClipboard => '剪貼簿裡沒有影片連結';

  @override
  String get filter => '篩選';

  @override
  String get searchEmptyHint => '輸入關鍵字或使用篩選開始搜尋';

  @override
  String get browseAll => '瀏覽全部';

  @override
  String get searchHistory => '搜尋紀錄';

  @override
  String get genre => '類型';

  @override
  String get sort => '排序';

  @override
  String get releaseDate => '發佈時間';

  @override
  String get duration => '時長';

  @override
  String get broadMatch => '廣泛配對';

  @override
  String get broadMatchHint => '標籤之間按「或」配對';

  @override
  String get brands => '品牌';

  @override
  String get tagVideoAttributes => '影片屬性';

  @override
  String get tagRelationships => '人物關係';

  @override
  String get tagCharacteristics => '角色設定';

  @override
  String get tagAppearance => '外貌身材';

  @override
  String get tagLocation => '故事場景';

  @override
  String get tagPlot => '故事劇情';

  @override
  String get tagPositions => '性交體位';

  @override
  String get intro => '簡介';

  @override
  String get comments => '評論';

  @override
  String get noComments => '還沒有評論';

  @override
  String get commentHint => '發表評論…';

  @override
  String get commentSent => '已送出';

  @override
  String get reply => '回覆';

  @override
  String viewReplies(int count) {
    return '查看 $count 則回覆';
  }

  @override
  String get report => '檢舉';

  @override
  String get reportSent => '已檢舉';

  @override
  String get favorite => '喜歡';

  @override
  String get favorites => '喜歡的影片';

  @override
  String get watchLater => '稍後觀看';

  @override
  String get addedToWatchLater => '已加入稍後觀看';

  @override
  String get playlist => '播放清單';

  @override
  String get playlists => '播放清單';

  @override
  String get addToPlaylist => '加入播放清單';

  @override
  String get newPlaylist => '新增清單';

  @override
  String get editPlaylist => '編輯清單';

  @override
  String get playlistTitle => '清單名稱';

  @override
  String get playlistCreated => '已建立清單';

  @override
  String get deletePlaylistConfirm => '確定刪除這個清單？';

  @override
  String get removeFromList => '從列表中移除？';

  @override
  String videoCount(int count) {
    return '$count 部影片';
  }

  @override
  String get download => '下載';

  @override
  String get downloaded => '已下載';

  @override
  String get downloadAdded => '已加入下載佇列';

  @override
  String get chooseQuality => '選擇畫質';

  @override
  String get related => '相關影片';

  @override
  String get subscribe => '訂閱';

  @override
  String get subscribed => '已訂閱';

  @override
  String get subscriptions => '訂閱';

  @override
  String get playError => '播放失敗';

  @override
  String get brightness => '亮度';

  @override
  String get volume => '音量';

  @override
  String get speed => '倍速';

  @override
  String get quality => '畫質';

  @override
  String get fullscreen => '全螢幕';

  @override
  String get hKeyframes => 'H 關鍵幀';

  @override
  String addKeyframeAt(String time) {
    return '在 $time 新增關鍵幀';
  }

  @override
  String get keyframePromptHint => '備註（選填）';

  @override
  String get keyframeAdded => '已新增關鍵幀';

  @override
  String get keyframesEmptyHint => '還沒有關鍵幀，播放時長按書籤按鈕可快速新增';

  @override
  String sharedBy(String author) {
    return '共享關鍵幀 · 作者 $author';
  }

  @override
  String get localKeyframes => '我的關鍵幀';

  @override
  String get sharedKeyframes => '共享關鍵幀';

  @override
  String get sharedKeyframesFirst => '優先使用共享關鍵幀';

  @override
  String get enableKeyframes => '啟用 H 關鍵幀';

  @override
  String get enableKeyframesHint => '在進度條上標記並在臨近時倒數提醒';

  @override
  String get keyframeShowPrompt => '倒數顯示序號和備註';

  @override
  String get keyframeCountdown => '提前提醒秒數';

  @override
  String keyframeCount(int count) {
    return '$count 個關鍵幀';
  }

  @override
  String get notLoggedIn => '未登入';

  @override
  String get tapToLogin => '點擊登入以同步喜歡、清單與紀錄';

  @override
  String get tapToManageAccount => '管理帳號資料';

  @override
  String get localHistory => '本機觀看紀錄';

  @override
  String get onlineHistory => '雲端觀看紀錄';

  @override
  String get clearHistoryConfirm => '確定清空全部觀看紀錄？';

  @override
  String get deleteHistory => '刪除這筆紀錄？';

  @override
  String get sortLatest => '最新';

  @override
  String get sortPopular => '最熱門';

  @override
  String get sortOldest => '最早';

  @override
  String get userSortDefault => '預設';

  @override
  String get userSortLatest => '最新';

  @override
  String get userSortPopular => '最熱門';

  @override
  String get userSortOldest => '最早';

  @override
  String get account => '帳號資料';

  @override
  String accountStats(int subs, int videos) {
    return '$subs 訂閱者 · $videos 部影片';
  }

  @override
  String get profile => '個人資料';

  @override
  String get username => '使用者名稱';

  @override
  String get changePassword => '修改密碼';

  @override
  String get oldPassword => '目前密碼';

  @override
  String get newPassword => '新密碼';

  @override
  String get confirmPassword => '確認新密碼';

  @override
  String get downloading => '下載中';

  @override
  String get noDownloading => '沒有進行中的下載';

  @override
  String get queued => '排隊中';

  @override
  String get paused => '已暫停';

  @override
  String get failed => '失敗';

  @override
  String get pauseAll => '全部暫停';

  @override
  String get resumeAll => '全部繼續';

  @override
  String get newGroup => '新增分組';

  @override
  String get ungrouped => '未分組';

  @override
  String get deleteGroup => '刪除分組';

  @override
  String get deleteGroupHint => '分組內的影片會移到「未分組」';

  @override
  String get moveToGroup => '移動到分組';

  @override
  String get deleteDownloadConfirm => '刪除下載及本機檔案？';

  @override
  String get saveToGallery => '儲存到相簿';

  @override
  String get exportFile => '匯出檔案';

  @override
  String get exported => '已匯出';

  @override
  String get exportFailed => '匯出失敗';

  @override
  String downloadingNotification(int count, String title) {
    return '$count 個任務進行中 $title';
  }

  @override
  String get general => '通用';

  @override
  String get theme => '主題';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '語言';

  @override
  String get videoLanguage => '網站字幕語言';

  @override
  String get simplifiedChinese => '簡體中文';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get hideComments => '隱藏評論區';

  @override
  String get clipboardDetect => '剪貼簿連結識別';

  @override
  String get clipboardDetectHint => '回到應用程式時偵測剪貼簿裡的影片連結（iOS 會提示讀取剪貼簿）';

  @override
  String clipboardDetected(String code) {
    return '偵測到影片 $code';
  }

  @override
  String get networkSettings => '網路設定';

  @override
  String get player => '播放器';

  @override
  String get defaultQuality => '預設畫質';

  @override
  String get longPressSpeed => '長按倍速';

  @override
  String get gestures => '手勢控制';

  @override
  String get gesturesHint => '左右滑動調進度，左側上下調亮度，右側上下調音量';

  @override
  String get resumePlayback => '從上次位置繼續播放';

  @override
  String get fullscreenLandscape => '全螢幕時自動橫向';

  @override
  String get downloadConcurrency => '同時下載數';

  @override
  String get speedLimit => '下載限速';

  @override
  String get unlimited => '不限速';

  @override
  String get privacy => '隱私';

  @override
  String get appLock => '應用程式鎖';

  @override
  String get appLockHint => '使用 PIN，可搭配生物辨識解鎖';

  @override
  String get changePin => '修改 PIN';

  @override
  String get setPin => '設定 PIN';

  @override
  String get pinSetupHint => '輸入 4–8 位數字';

  @override
  String get pinConfirm => '再輸入一次';

  @override
  String get pinMismatch => '兩次輸入不一致';

  @override
  String get enterPin => '輸入 PIN 解鎖';

  @override
  String get pinWrong => 'PIN 錯誤';

  @override
  String get unlockReason => '解鎖 HaVF';

  @override
  String get biometric => '生物辨識解鎖';

  @override
  String get lockDelay => '重新上鎖';

  @override
  String get lockImmediately => '離開後立即';

  @override
  String get lockAfter1Min => '離開 1 分鐘後';

  @override
  String get lockAfter5Min => '離開 5 分鐘後';

  @override
  String get blurInBackground => '背景模糊';

  @override
  String get blurInBackgroundHint => '在多工畫面隱藏內容';

  @override
  String get disguiseIcon => '偽裝圖示';

  @override
  String get disguiseIconHint => '圖示可能需要片刻才會在桌面上更新';

  @override
  String get iconDefault => '預設';

  @override
  String get iconCalc => '計算機';

  @override
  String get iconXxt => '學不通';

  @override
  String get storage => '儲存空間';

  @override
  String get imageCache => '圖片快取';

  @override
  String get imageCacheLimit => '圖片快取上限';

  @override
  String get pageCache => '頁面快取';

  @override
  String get webviewData => '內建瀏覽器資料';

  @override
  String get clearCache => '清理快取';

  @override
  String get clearCacheHint => '清理圖片、頁面與瀏覽器快取，不影響下載和登入';

  @override
  String get about => '關於';

  @override
  String get discardChanges => '放棄未儲存的修改？';

  @override
  String get domain => '網站網域';

  @override
  String get customMirror => '自訂鏡像';

  @override
  String get dns => 'DNS';

  @override
  String get builtInHosts => '內建 Hosts';

  @override
  String get builtInHostsHint => '繞過 DNS 污染，直接連線 Cloudflare 節點';

  @override
  String get customIps => '自訂 IP（逗號分隔，留空使用內建）';

  @override
  String get dohServer => 'DoH 伺服器';

  @override
  String get bootstrapIps => '引導 IP';

  @override
  String get timeout => '逾時';

  @override
  String get dnsDiagnose => '測試解析';

  @override
  String get proxy => '代理';

  @override
  String get proxyMode => '代理模式';

  @override
  String get proxySystem => '跟隨系統';

  @override
  String get proxyNone => '不使用';

  @override
  String get proxyHost => '代理位址';

  @override
  String get proxyPort => '代理埠';

  @override
  String get identity => '裝置身分';

  @override
  String get deviceProfile => '隨機裝置';

  @override
  String get currentUserAgent => '目前 UA';

  @override
  String get followingWebview => '跟隨 WebView';

  @override
  String get androidDisguise => 'Android 偽裝';

  @override
  String get verifyNow => '立即進行網站驗證';

  @override
  String get verifyNowHint => '在內建瀏覽器中開啟網站完成 Cloudflare 驗證';

  @override
  String get verifySuccess => '驗證成功';

  @override
  String get verifyCancelled => '驗證未完成';

  @override
  String get manualCfImport => '手動匯入 cf_clearance';

  @override
  String get manualCfImportHint =>
      '從同一網路下的瀏覽器複製 cf_clearance 與該瀏覽器的 User-Agent，兩者必須配對';

  @override
  String get clearCf => '清除驗證憑證';

  @override
  String get regenerateIdentity => '重新產生裝置身分';

  @override
  String get regenerateIdentityHint => '會清除現有 cf_clearance，可能需要重新驗證';

  @override
  String get proTitle => '發電';

  @override
  String get proCenter => '發電中心';

  @override
  String get proPowered => '發電中';

  @override
  String get proNotPowered => '未發電';

  @override
  String get proGuide =>
      '發電狀態綁定的是登入後的使用者名稱。\n\n「我曾經發過電」同步已有狀態\n「我剛才發了電」兌換代碼\n「Patreon」是另一種發電方式\n更換「發電方式」可能解決連線失敗';

  @override
  String get proSignIn => '簽到/兌換';

  @override
  String get proPatreon => 'Patreon';

  @override
  String get proIHavePowered => '我曾經發過電';

  @override
  String get proIJustPowered => '我剛才發了電';

  @override
  String get proEnterCode => '輸入代碼';

  @override
  String get proPowerMethod => '發電方式';

  @override
  String get proChooseMethod => '選擇發電方式';

  @override
  String get proClickPatToChange => '點擊下面的 Patreon 進行變更';

  @override
  String get proUpdatePat => '更新 Patreon 狀態';

  @override
  String get proBindAccount => '綁定到此帳號';

  @override
  String get proChangePatKey => '更換 Patreon 金鑰';

  @override
  String get proClearPat => '清除 Patreon 資訊';

  @override
  String get proClickToBind => '點擊綁定';

  @override
  String get proEnterAuthCode => '請輸入授權代碼';

  @override
  String get proPleaseWait => '請稍後';

  @override
  String get proKeyRecorded => '金鑰已錄入';

  @override
  String get proPatAccount => 'Patreon 帳號';

  @override
  String get proBoundAccount => '綁定帳號';

  @override
  String get proBindTime => '綁定時間';

  @override
  String get proRebindTime => '可以換綁時間';

  @override
  String get proPatBindHint => '請點擊這裡綁定到目前帳號';

  @override
  String get proPatRebindHint => '綁定帳號與目前登入的使用者名稱不一致，請換綁';

  @override
  String get proPatNotDetected => '未檢測到入會';

  @override
  String get proPatNormal => '狀態正常';

  @override
  String get proSynced => '已同步';

  @override
  String proPageLimit(int pages) {
    return '未發電只能看前 $pages 頁';
  }

  @override
  String get proGo => '去發電';

  @override
  String get proErrNetworkTimeout => '網路逾時，請檢查網路或更換發電方式';

  @override
  String get proErrNetworkUnreachable => '連不上伺服器，請檢查網路或更換發電方式';

  @override
  String get proErrServerFailed => '伺服器處理失敗';

  @override
  String get proErrServerInvalid => '伺服器回傳異常';

  @override
  String get proErrRequestInvalid => '請求無效';

  @override
  String get proErrOrderNotSynced => '訂單尚未同步，請稍後再試';

  @override
  String get proErrOrderUsed => '訂單已被使用';

  @override
  String get proErrOrderAmount => '訂單金額無效';

  @override
  String get proErrTicketNotFound => '兌換券不存在';

  @override
  String get proErrTicketUsed => '兌換券已被使用';

  @override
  String get proErrTicketEventUsed => '活動兌換券已參與';

  @override
  String get proErrDeviceTime => '請檢查裝置時間';

  @override
  String get proErrPatNotBound => '尚未綁定金鑰';

  @override
  String get browserAddressHint => '輸入網址';

  @override
  String get browserBack => '後退';

  @override
  String get browserForward => '前進';

  @override
  String get checkUpdate => '檢查更新';

  @override
  String get checkingUpdate => '正在檢查更新';

  @override
  String get alreadyLatest => '已是最新版本';

  @override
  String newVersionFound(String version) {
    return '發現新版本 $version';
  }

  @override
  String get updateTitle => '發現新版本';

  @override
  String forceUpdateMessage(String version) {
    return '發現新版本 $version，請立即更新後繼續使用';
  }

  @override
  String get downloadUpdate => '去下載';

  @override
  String get friendLinks => '友情連結';
}
