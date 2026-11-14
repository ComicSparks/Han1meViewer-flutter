import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'HaVF'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @downloads.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get downloads;

  /// No description provided for @mine.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get mine;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get more;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get saved;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @cleared.
  ///
  /// In zh, this message translates to:
  /// **'已清理'**
  String get cleared;

  /// No description provided for @apply.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get reset;

  /// No description provided for @open.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get open;

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @empty.
  ///
  /// In zh, this message translates to:
  /// **'这里什么都没有'**
  String get empty;

  /// No description provided for @share.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share;

  /// No description provided for @linkCopied.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制'**
  String get linkCopied;

  /// No description provided for @copied.
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get copied;

  /// No description provided for @needPro.
  ///
  /// In zh, this message translates to:
  /// **'发电后才能使用'**
  String get needPro;

  /// No description provided for @exportNameTooLong.
  ///
  /// In zh, this message translates to:
  /// **'文件名或路径过长，将缩短标题后再导出'**
  String get exportNameTooLong;

  /// No description provided for @multiSelect.
  ///
  /// In zh, this message translates to:
  /// **'多选'**
  String get multiSelect;

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 项'**
  String selectedCount(int count);

  /// No description provided for @downloadQueued.
  ///
  /// In zh, this message translates to:
  /// **'已加入 {added} 个，跳过 {skipped} 个'**
  String downloadQueued(int added, int skipped);

  /// No description provided for @subscriptionUpdates.
  ///
  /// In zh, this message translates to:
  /// **'订阅更新提示'**
  String get subscriptionUpdates;

  /// No description provided for @subscriptionUpdatesHint.
  ///
  /// In zh, this message translates to:
  /// **'标出上次查看订阅之后出现的新影片'**
  String get subscriptionUpdatesHint;

  /// No description provided for @playing.
  ///
  /// In zh, this message translates to:
  /// **'播放中'**
  String get playing;

  /// No description provided for @removed.
  ///
  /// In zh, this message translates to:
  /// **'已移除'**
  String get removed;

  /// No description provided for @description.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get description;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @errTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接超时'**
  String get errTimeout;

  /// No description provided for @errDns.
  ///
  /// In zh, this message translates to:
  /// **'域名解析失败，可尝试开启内置 Hosts 或 DoH'**
  String get errDns;

  /// No description provided for @errTls.
  ///
  /// In zh, this message translates to:
  /// **'TLS 握手失败'**
  String get errTls;

  /// No description provided for @errProxy.
  ///
  /// In zh, this message translates to:
  /// **'代理连接失败'**
  String get errProxy;

  /// No description provided for @errNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络错误'**
  String get errNetwork;

  /// No description provided for @errCfChallenge.
  ///
  /// In zh, this message translates to:
  /// **'Cloudflare 验证未通过'**
  String get errCfChallenge;

  /// No description provided for @errCfMismatch.
  ///
  /// In zh, this message translates to:
  /// **'验证凭据与当前网络环境不匹配，请重新验证'**
  String get errCfMismatch;

  /// No description provided for @errIpBlocked.
  ///
  /// In zh, this message translates to:
  /// **'当前 IP 被站点拒绝，请更换网络或代理'**
  String get errIpBlocked;

  /// No description provided for @errNotFound.
  ///
  /// In zh, this message translates to:
  /// **'内容不存在'**
  String get errNotFound;

  /// No description provided for @errNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get errNotLoggedIn;

  /// No description provided for @errLoginExpired.
  ///
  /// In zh, this message translates to:
  /// **'登录已过期，请重新登录'**
  String get errLoginExpired;

  /// No description provided for @errLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败'**
  String get errLoginFailed;

  /// No description provided for @errParse.
  ///
  /// In zh, this message translates to:
  /// **'页面解析失败，站点可能已改版'**
  String get errParse;

  /// No description provided for @errExists.
  ///
  /// In zh, this message translates to:
  /// **'已经下载过了'**
  String get errExists;

  /// No description provided for @errInvalid.
  ///
  /// In zh, this message translates to:
  /// **'输入无效'**
  String get errInvalid;

  /// No description provided for @errInvalidImage.
  ///
  /// In zh, this message translates to:
  /// **'图片无效'**
  String get errInvalidImage;

  /// No description provided for @errHttp.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回 {code}'**
  String errHttp(String code);

  /// No description provided for @cfVerifyTitle.
  ///
  /// In zh, this message translates to:
  /// **'站点验证'**
  String get cfVerifyTitle;

  /// No description provided for @cfVerifyHint.
  ///
  /// In zh, this message translates to:
  /// **'请完成 Cloudflare 人机验证，通过后会自动返回'**
  String get cfVerifyHint;

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定退出登录？'**
  String get logoutConfirm;

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccess;

  /// No description provided for @webLogin.
  ///
  /// In zh, this message translates to:
  /// **'网页登录'**
  String get webLogin;

  /// No description provided for @webLoginHint.
  ///
  /// In zh, this message translates to:
  /// **'推荐。在内置浏览器里登录，可顺带完成人机验证'**
  String get webLoginHint;

  /// No description provided for @formLogin.
  ///
  /// In zh, this message translates to:
  /// **'账号密码登录'**
  String get formLogin;

  /// No description provided for @email.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get email;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @cookieLogin.
  ///
  /// In zh, this message translates to:
  /// **'导入 Cookie'**
  String get cookieLogin;

  /// No description provided for @cookieLoginHint.
  ///
  /// In zh, this message translates to:
  /// **'从浏览器复制站点 Cookie 粘贴到这里'**
  String get cookieLoginHint;

  /// No description provided for @importCookie.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importCookie;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索影片、作者…'**
  String get searchHint;

  /// No description provided for @pasteLink.
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板打开链接'**
  String get pasteLink;

  /// No description provided for @noLinkInClipboard.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板里没有影片链接'**
  String get noLinkInClipboard;

  /// No description provided for @filter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get filter;

  /// No description provided for @searchEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词或使用筛选开始搜索'**
  String get searchEmptyHint;

  /// No description provided for @browseAll.
  ///
  /// In zh, this message translates to:
  /// **'浏览全部'**
  String get browseAll;

  /// No description provided for @searchHistory.
  ///
  /// In zh, this message translates to:
  /// **'搜索历史'**
  String get searchHistory;

  /// No description provided for @genre.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get genre;

  /// No description provided for @sort.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get sort;

  /// No description provided for @releaseDate.
  ///
  /// In zh, this message translates to:
  /// **'发布时间'**
  String get releaseDate;

  /// No description provided for @duration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get duration;

  /// No description provided for @broadMatch.
  ///
  /// In zh, this message translates to:
  /// **'广泛匹配'**
  String get broadMatch;

  /// No description provided for @broadMatchHint.
  ///
  /// In zh, this message translates to:
  /// **'标签之间按「或」匹配'**
  String get broadMatchHint;

  /// No description provided for @brands.
  ///
  /// In zh, this message translates to:
  /// **'品牌'**
  String get brands;

  /// No description provided for @tagVideoAttributes.
  ///
  /// In zh, this message translates to:
  /// **'影片属性'**
  String get tagVideoAttributes;

  /// No description provided for @tagRelationships.
  ///
  /// In zh, this message translates to:
  /// **'人物关系'**
  String get tagRelationships;

  /// No description provided for @tagCharacteristics.
  ///
  /// In zh, this message translates to:
  /// **'角色设定'**
  String get tagCharacteristics;

  /// No description provided for @tagAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外貌身材'**
  String get tagAppearance;

  /// No description provided for @tagLocation.
  ///
  /// In zh, this message translates to:
  /// **'故事场景'**
  String get tagLocation;

  /// No description provided for @tagPlot.
  ///
  /// In zh, this message translates to:
  /// **'故事剧情'**
  String get tagPlot;

  /// No description provided for @tagPositions.
  ///
  /// In zh, this message translates to:
  /// **'性交体位'**
  String get tagPositions;

  /// No description provided for @intro.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get intro;

  /// No description provided for @comments.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get comments;

  /// No description provided for @noComments.
  ///
  /// In zh, this message translates to:
  /// **'还没有评论'**
  String get noComments;

  /// No description provided for @commentHint.
  ///
  /// In zh, this message translates to:
  /// **'发表评论…'**
  String get commentHint;

  /// No description provided for @commentSent.
  ///
  /// In zh, this message translates to:
  /// **'已发送'**
  String get commentSent;

  /// No description provided for @reply.
  ///
  /// In zh, this message translates to:
  /// **'回复'**
  String get reply;

  /// No description provided for @viewReplies.
  ///
  /// In zh, this message translates to:
  /// **'查看 {count} 条回复'**
  String viewReplies(int count);

  /// No description provided for @report.
  ///
  /// In zh, this message translates to:
  /// **'举报'**
  String get report;

  /// No description provided for @reportSent.
  ///
  /// In zh, this message translates to:
  /// **'已举报'**
  String get reportSent;

  /// No description provided for @favorite.
  ///
  /// In zh, this message translates to:
  /// **'喜欢'**
  String get favorite;

  /// No description provided for @favorites.
  ///
  /// In zh, this message translates to:
  /// **'喜欢的影片'**
  String get favorites;

  /// No description provided for @watchLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后观看'**
  String get watchLater;

  /// No description provided for @addedToWatchLater.
  ///
  /// In zh, this message translates to:
  /// **'已加入稍后观看'**
  String get addedToWatchLater;

  /// No description provided for @playlist.
  ///
  /// In zh, this message translates to:
  /// **'播放清单'**
  String get playlist;

  /// No description provided for @playlists.
  ///
  /// In zh, this message translates to:
  /// **'播放清单'**
  String get playlists;

  /// No description provided for @addToPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'加入播放清单'**
  String get addToPlaylist;

  /// No description provided for @newPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'新建清单'**
  String get newPlaylist;

  /// No description provided for @editPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'编辑清单'**
  String get editPlaylist;

  /// No description provided for @playlistTitle.
  ///
  /// In zh, this message translates to:
  /// **'清单名称'**
  String get playlistTitle;

  /// No description provided for @playlistCreated.
  ///
  /// In zh, this message translates to:
  /// **'已创建清单'**
  String get playlistCreated;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除这个清单？'**
  String get deletePlaylistConfirm;

  /// No description provided for @removeFromList.
  ///
  /// In zh, this message translates to:
  /// **'从列表中移除？'**
  String get removeFromList;

  /// No description provided for @videoCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 部影片'**
  String videoCount(int count);

  /// No description provided for @download.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download;

  /// No description provided for @downloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载'**
  String get downloaded;

  /// No description provided for @downloadAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入下载队列'**
  String get downloadAdded;

  /// No description provided for @chooseQuality.
  ///
  /// In zh, this message translates to:
  /// **'选择画质'**
  String get chooseQuality;

  /// No description provided for @related.
  ///
  /// In zh, this message translates to:
  /// **'相关影片'**
  String get related;

  /// No description provided for @subscribe.
  ///
  /// In zh, this message translates to:
  /// **'订阅'**
  String get subscribe;

  /// No description provided for @subscribed.
  ///
  /// In zh, this message translates to:
  /// **'已订阅'**
  String get subscribed;

  /// No description provided for @subscriptions.
  ///
  /// In zh, this message translates to:
  /// **'订阅'**
  String get subscriptions;

  /// No description provided for @playError.
  ///
  /// In zh, this message translates to:
  /// **'播放失败'**
  String get playError;

  /// No description provided for @brightness.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get brightness;

  /// No description provided for @volume.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volume;

  /// No description provided for @speed.
  ///
  /// In zh, this message translates to:
  /// **'倍速'**
  String get speed;

  /// No description provided for @quality.
  ///
  /// In zh, this message translates to:
  /// **'画质'**
  String get quality;

  /// No description provided for @fullscreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get fullscreen;

  /// No description provided for @hKeyframes.
  ///
  /// In zh, this message translates to:
  /// **'H 关键帧'**
  String get hKeyframes;

  /// No description provided for @addKeyframeAt.
  ///
  /// In zh, this message translates to:
  /// **'在 {time} 添加关键帧'**
  String addKeyframeAt(String time);

  /// No description provided for @keyframePromptHint.
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get keyframePromptHint;

  /// No description provided for @keyframeAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加关键帧'**
  String get keyframeAdded;

  /// No description provided for @keyframesEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有关键帧，播放时长按书签按钮可快速添加'**
  String get keyframesEmptyHint;

  /// No description provided for @sharedBy.
  ///
  /// In zh, this message translates to:
  /// **'共享关键帧 · 作者 {author}'**
  String sharedBy(String author);

  /// No description provided for @localKeyframes.
  ///
  /// In zh, this message translates to:
  /// **'我的关键帧'**
  String get localKeyframes;

  /// No description provided for @sharedKeyframes.
  ///
  /// In zh, this message translates to:
  /// **'共享关键帧'**
  String get sharedKeyframes;

  /// No description provided for @sharedKeyframesFirst.
  ///
  /// In zh, this message translates to:
  /// **'优先使用共享关键帧'**
  String get sharedKeyframesFirst;

  /// No description provided for @enableKeyframes.
  ///
  /// In zh, this message translates to:
  /// **'启用 H 关键帧'**
  String get enableKeyframes;

  /// No description provided for @enableKeyframesHint.
  ///
  /// In zh, this message translates to:
  /// **'在进度条上标记并在临近时倒计时提醒'**
  String get enableKeyframesHint;

  /// No description provided for @keyframeShowPrompt.
  ///
  /// In zh, this message translates to:
  /// **'倒计时显示序号和备注'**
  String get keyframeShowPrompt;

  /// No description provided for @keyframeCountdown.
  ///
  /// In zh, this message translates to:
  /// **'提前提醒秒数'**
  String get keyframeCountdown;

  /// No description provided for @keyframeCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个关键帧'**
  String keyframeCount(int count);

  /// No description provided for @notLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get notLoggedIn;

  /// No description provided for @tapToLogin.
  ///
  /// In zh, this message translates to:
  /// **'点击登录以同步喜欢、清单与历史'**
  String get tapToLogin;

  /// No description provided for @tapToManageAccount.
  ///
  /// In zh, this message translates to:
  /// **'管理账号资料'**
  String get tapToManageAccount;

  /// No description provided for @localHistory.
  ///
  /// In zh, this message translates to:
  /// **'本地观看记录'**
  String get localHistory;

  /// No description provided for @onlineHistory.
  ///
  /// In zh, this message translates to:
  /// **'云端观看记录'**
  String get onlineHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定清空全部观看记录？'**
  String get clearHistoryConfirm;

  /// No description provided for @deleteHistory.
  ///
  /// In zh, this message translates to:
  /// **'删除这条记录？'**
  String get deleteHistory;

  /// No description provided for @sortLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get sortLatest;

  /// No description provided for @sortPopular.
  ///
  /// In zh, this message translates to:
  /// **'最热门'**
  String get sortPopular;

  /// No description provided for @sortOldest.
  ///
  /// In zh, this message translates to:
  /// **'最早'**
  String get sortOldest;

  /// No description provided for @userSortDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get userSortDefault;

  /// No description provided for @userSortLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get userSortLatest;

  /// No description provided for @userSortPopular.
  ///
  /// In zh, this message translates to:
  /// **'最热门'**
  String get userSortPopular;

  /// No description provided for @userSortOldest.
  ///
  /// In zh, this message translates to:
  /// **'最早'**
  String get userSortOldest;

  /// No description provided for @account.
  ///
  /// In zh, this message translates to:
  /// **'账号资料'**
  String get account;

  /// No description provided for @accountStats.
  ///
  /// In zh, this message translates to:
  /// **'{subs} 订阅者 · {videos} 部影片'**
  String accountStats(int subs, int videos);

  /// No description provided for @profile.
  ///
  /// In zh, this message translates to:
  /// **'个人资料'**
  String get profile;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @changePassword.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In zh, this message translates to:
  /// **'当前密码'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In zh, this message translates to:
  /// **'新密码'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'确认新密码'**
  String get confirmPassword;

  /// No description provided for @downloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中'**
  String get downloading;

  /// No description provided for @noDownloading.
  ///
  /// In zh, this message translates to:
  /// **'没有进行中的下载'**
  String get noDownloading;

  /// No description provided for @queued.
  ///
  /// In zh, this message translates to:
  /// **'排队中'**
  String get queued;

  /// No description provided for @paused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get paused;

  /// No description provided for @failed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failed;

  /// No description provided for @pauseAll.
  ///
  /// In zh, this message translates to:
  /// **'全部暂停'**
  String get pauseAll;

  /// No description provided for @resumeAll.
  ///
  /// In zh, this message translates to:
  /// **'全部继续'**
  String get resumeAll;

  /// No description provided for @newGroup.
  ///
  /// In zh, this message translates to:
  /// **'新建分组'**
  String get newGroup;

  /// No description provided for @ungrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get ungrouped;

  /// No description provided for @deleteGroup.
  ///
  /// In zh, this message translates to:
  /// **'删除分组'**
  String get deleteGroup;

  /// No description provided for @deleteGroupHint.
  ///
  /// In zh, this message translates to:
  /// **'分组内的影片会移到「未分组」'**
  String get deleteGroupHint;

  /// No description provided for @moveToGroup.
  ///
  /// In zh, this message translates to:
  /// **'移动到分组'**
  String get moveToGroup;

  /// No description provided for @deleteDownloadConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除下载及本地文件？'**
  String get deleteDownloadConfirm;

  /// No description provided for @saveToGallery.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get saveToGallery;

  /// No description provided for @exportFile.
  ///
  /// In zh, this message translates to:
  /// **'导出文件'**
  String get exportFile;

  /// No description provided for @exported.
  ///
  /// In zh, this message translates to:
  /// **'已导出'**
  String get exported;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get exportFailed;

  /// No description provided for @downloadingNotification.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个任务进行中 {title}'**
  String downloadingNotification(int count, String title);

  /// No description provided for @general.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get general;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @videoLanguage.
  ///
  /// In zh, this message translates to:
  /// **'站点字幕语言'**
  String get videoLanguage;

  /// No description provided for @simplifiedChinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  /// No description provided for @traditionalChinese.
  ///
  /// In zh, this message translates to:
  /// **'繁体中文'**
  String get traditionalChinese;

  /// No description provided for @hideComments.
  ///
  /// In zh, this message translates to:
  /// **'隐藏评论区'**
  String get hideComments;

  /// No description provided for @clipboardDetect.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板链接识别'**
  String get clipboardDetect;

  /// No description provided for @clipboardDetectHint.
  ///
  /// In zh, this message translates to:
  /// **'回到应用时检测剪贴板里的影片链接（iOS 会提示读取剪贴板）'**
  String get clipboardDetectHint;

  /// No description provided for @clipboardDetected.
  ///
  /// In zh, this message translates to:
  /// **'检测到影片 {code}'**
  String clipboardDetected(String code);

  /// No description provided for @networkSettings.
  ///
  /// In zh, this message translates to:
  /// **'网络设置'**
  String get networkSettings;

  /// No description provided for @player.
  ///
  /// In zh, this message translates to:
  /// **'播放器'**
  String get player;

  /// No description provided for @defaultQuality.
  ///
  /// In zh, this message translates to:
  /// **'默认画质'**
  String get defaultQuality;

  /// No description provided for @longPressSpeed.
  ///
  /// In zh, this message translates to:
  /// **'长按倍速'**
  String get longPressSpeed;

  /// No description provided for @gestures.
  ///
  /// In zh, this message translates to:
  /// **'手势控制'**
  String get gestures;

  /// No description provided for @gesturesHint.
  ///
  /// In zh, this message translates to:
  /// **'左右滑动调进度，左侧上下调亮度，右侧上下调音量'**
  String get gesturesHint;

  /// No description provided for @resumePlayback.
  ///
  /// In zh, this message translates to:
  /// **'从上次位置继续播放'**
  String get resumePlayback;

  /// No description provided for @fullscreenLandscape.
  ///
  /// In zh, this message translates to:
  /// **'全屏时自动横屏'**
  String get fullscreenLandscape;

  /// No description provided for @downloadConcurrency.
  ///
  /// In zh, this message translates to:
  /// **'同时下载数'**
  String get downloadConcurrency;

  /// No description provided for @speedLimit.
  ///
  /// In zh, this message translates to:
  /// **'下载限速'**
  String get speedLimit;

  /// No description provided for @unlimited.
  ///
  /// In zh, this message translates to:
  /// **'不限速'**
  String get unlimited;

  /// No description provided for @privacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私'**
  String get privacy;

  /// No description provided for @appLock.
  ///
  /// In zh, this message translates to:
  /// **'应用锁'**
  String get appLock;

  /// No description provided for @appLockHint.
  ///
  /// In zh, this message translates to:
  /// **'使用 PIN，可配合生物识别解锁'**
  String get appLockHint;

  /// No description provided for @changePin.
  ///
  /// In zh, this message translates to:
  /// **'修改 PIN'**
  String get changePin;

  /// No description provided for @setPin.
  ///
  /// In zh, this message translates to:
  /// **'设置 PIN'**
  String get setPin;

  /// No description provided for @pinSetupHint.
  ///
  /// In zh, this message translates to:
  /// **'输入 4–8 位数字'**
  String get pinSetupHint;

  /// No description provided for @pinConfirm.
  ///
  /// In zh, this message translates to:
  /// **'再输入一次'**
  String get pinConfirm;

  /// No description provided for @pinMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入不一致'**
  String get pinMismatch;

  /// No description provided for @enterPin.
  ///
  /// In zh, this message translates to:
  /// **'输入 PIN 解锁'**
  String get enterPin;

  /// No description provided for @pinWrong.
  ///
  /// In zh, this message translates to:
  /// **'PIN 错误'**
  String get pinWrong;

  /// No description provided for @unlockReason.
  ///
  /// In zh, this message translates to:
  /// **'解锁 HaVF'**
  String get unlockReason;

  /// No description provided for @biometric.
  ///
  /// In zh, this message translates to:
  /// **'生物识别解锁'**
  String get biometric;

  /// No description provided for @lockDelay.
  ///
  /// In zh, this message translates to:
  /// **'重新上锁'**
  String get lockDelay;

  /// No description provided for @lockImmediately.
  ///
  /// In zh, this message translates to:
  /// **'离开后立即'**
  String get lockImmediately;

  /// No description provided for @lockAfter1Min.
  ///
  /// In zh, this message translates to:
  /// **'离开 1 分钟后'**
  String get lockAfter1Min;

  /// No description provided for @lockAfter5Min.
  ///
  /// In zh, this message translates to:
  /// **'离开 5 分钟后'**
  String get lockAfter5Min;

  /// No description provided for @blurInBackground.
  ///
  /// In zh, this message translates to:
  /// **'后台模糊'**
  String get blurInBackground;

  /// No description provided for @blurInBackgroundHint.
  ///
  /// In zh, this message translates to:
  /// **'在多任务界面隐藏内容'**
  String get blurInBackgroundHint;

  /// No description provided for @disguiseIcon.
  ///
  /// In zh, this message translates to:
  /// **'伪装图标'**
  String get disguiseIcon;

  /// No description provided for @disguiseIconHint.
  ///
  /// In zh, this message translates to:
  /// **'图标可能需要片刻才会在桌面上更新'**
  String get disguiseIconHint;

  /// No description provided for @iconDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get iconDefault;

  /// No description provided for @iconCalc.
  ///
  /// In zh, this message translates to:
  /// **'计算器'**
  String get iconCalc;

  /// No description provided for @iconXxt.
  ///
  /// In zh, this message translates to:
  /// **'学不通'**
  String get iconXxt;

  /// No description provided for @storage.
  ///
  /// In zh, this message translates to:
  /// **'存储'**
  String get storage;

  /// No description provided for @imageCache.
  ///
  /// In zh, this message translates to:
  /// **'图片缓存'**
  String get imageCache;

  /// No description provided for @imageCacheLimit.
  ///
  /// In zh, this message translates to:
  /// **'图片缓存上限'**
  String get imageCacheLimit;

  /// No description provided for @pageCache.
  ///
  /// In zh, this message translates to:
  /// **'页面缓存'**
  String get pageCache;

  /// No description provided for @webviewData.
  ///
  /// In zh, this message translates to:
  /// **'内置浏览器数据'**
  String get webviewData;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清理缓存'**
  String get clearCache;

  /// No description provided for @clearCacheHint.
  ///
  /// In zh, this message translates to:
  /// **'清理图片、页面与浏览器缓存，不影响下载和登录'**
  String get clearCacheHint;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @discardChanges.
  ///
  /// In zh, this message translates to:
  /// **'放弃未保存的修改？'**
  String get discardChanges;

  /// No description provided for @domain.
  ///
  /// In zh, this message translates to:
  /// **'站点域名'**
  String get domain;

  /// No description provided for @customMirror.
  ///
  /// In zh, this message translates to:
  /// **'自定义镜像'**
  String get customMirror;

  /// No description provided for @dns.
  ///
  /// In zh, this message translates to:
  /// **'DNS'**
  String get dns;

  /// No description provided for @builtInHosts.
  ///
  /// In zh, this message translates to:
  /// **'内置 Hosts'**
  String get builtInHosts;

  /// No description provided for @builtInHostsHint.
  ///
  /// In zh, this message translates to:
  /// **'绕过 DNS 污染，直接连接 Cloudflare 节点'**
  String get builtInHostsHint;

  /// No description provided for @customIps.
  ///
  /// In zh, this message translates to:
  /// **'自定义 IP（逗号分隔，留空使用内置）'**
  String get customIps;

  /// No description provided for @dohServer.
  ///
  /// In zh, this message translates to:
  /// **'DoH 服务器'**
  String get dohServer;

  /// No description provided for @bootstrapIps.
  ///
  /// In zh, this message translates to:
  /// **'引导 IP'**
  String get bootstrapIps;

  /// No description provided for @timeout.
  ///
  /// In zh, this message translates to:
  /// **'超时'**
  String get timeout;

  /// No description provided for @dnsDiagnose.
  ///
  /// In zh, this message translates to:
  /// **'测试解析'**
  String get dnsDiagnose;

  /// No description provided for @proxy.
  ///
  /// In zh, this message translates to:
  /// **'代理'**
  String get proxy;

  /// No description provided for @proxyMode.
  ///
  /// In zh, this message translates to:
  /// **'代理模式'**
  String get proxyMode;

  /// No description provided for @proxySystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get proxySystem;

  /// No description provided for @proxyNone.
  ///
  /// In zh, this message translates to:
  /// **'不使用'**
  String get proxyNone;

  /// No description provided for @proxyHost.
  ///
  /// In zh, this message translates to:
  /// **'代理地址'**
  String get proxyHost;

  /// No description provided for @proxyPort.
  ///
  /// In zh, this message translates to:
  /// **'代理端口'**
  String get proxyPort;

  /// No description provided for @identity.
  ///
  /// In zh, this message translates to:
  /// **'设备身份'**
  String get identity;

  /// No description provided for @deviceProfile.
  ///
  /// In zh, this message translates to:
  /// **'随机设备'**
  String get deviceProfile;

  /// No description provided for @currentUserAgent.
  ///
  /// In zh, this message translates to:
  /// **'当前 UA'**
  String get currentUserAgent;

  /// No description provided for @followingWebview.
  ///
  /// In zh, this message translates to:
  /// **'跟随 WebView'**
  String get followingWebview;

  /// No description provided for @androidDisguise.
  ///
  /// In zh, this message translates to:
  /// **'Android 伪装'**
  String get androidDisguise;

  /// No description provided for @verifyNow.
  ///
  /// In zh, this message translates to:
  /// **'立即进行站点验证'**
  String get verifyNow;

  /// No description provided for @verifyNowHint.
  ///
  /// In zh, this message translates to:
  /// **'在内置浏览器中打开站点完成 Cloudflare 验证'**
  String get verifyNowHint;

  /// No description provided for @verifySuccess.
  ///
  /// In zh, this message translates to:
  /// **'验证成功'**
  String get verifySuccess;

  /// No description provided for @verifyCancelled.
  ///
  /// In zh, this message translates to:
  /// **'验证未完成'**
  String get verifyCancelled;

  /// No description provided for @manualCfImport.
  ///
  /// In zh, this message translates to:
  /// **'手动导入 cf_clearance'**
  String get manualCfImport;

  /// No description provided for @manualCfImportHint.
  ///
  /// In zh, this message translates to:
  /// **'从同一网络下的浏览器复制 cf_clearance 与该浏览器的 User-Agent，两者必须配对'**
  String get manualCfImportHint;

  /// No description provided for @clearCf.
  ///
  /// In zh, this message translates to:
  /// **'清除验证凭据'**
  String get clearCf;

  /// No description provided for @regenerateIdentity.
  ///
  /// In zh, this message translates to:
  /// **'重新生成设备身份'**
  String get regenerateIdentity;

  /// No description provided for @regenerateIdentityHint.
  ///
  /// In zh, this message translates to:
  /// **'会清除现有 cf_clearance，可能需要重新验证'**
  String get regenerateIdentityHint;

  /// No description provided for @proTitle.
  ///
  /// In zh, this message translates to:
  /// **'发电'**
  String get proTitle;

  /// No description provided for @proCenter.
  ///
  /// In zh, this message translates to:
  /// **'发电中心'**
  String get proCenter;

  /// No description provided for @proPowered.
  ///
  /// In zh, this message translates to:
  /// **'发电中'**
  String get proPowered;

  /// No description provided for @proNotPowered.
  ///
  /// In zh, this message translates to:
  /// **'未发电'**
  String get proNotPowered;

  /// No description provided for @proGuide.
  ///
  /// In zh, this message translates to:
  /// **'发电状态绑定的是登录后的用户名。\n\n「我曾经发过电」同步已有状态\n「我刚才发了电」兑换代码\n「Patreon」是另一种发电方式\n更换「发电方式」可能解决连接失败'**
  String get proGuide;

  /// No description provided for @proSignIn.
  ///
  /// In zh, this message translates to:
  /// **'签到/兑换'**
  String get proSignIn;

  /// No description provided for @proPatreon.
  ///
  /// In zh, this message translates to:
  /// **'Patreon'**
  String get proPatreon;

  /// No description provided for @proIHavePowered.
  ///
  /// In zh, this message translates to:
  /// **'我曾经发过电'**
  String get proIHavePowered;

  /// No description provided for @proIJustPowered.
  ///
  /// In zh, this message translates to:
  /// **'我刚才发了电'**
  String get proIJustPowered;

  /// No description provided for @proEnterCode.
  ///
  /// In zh, this message translates to:
  /// **'输入代码'**
  String get proEnterCode;

  /// No description provided for @proPowerMethod.
  ///
  /// In zh, this message translates to:
  /// **'发电方式'**
  String get proPowerMethod;

  /// No description provided for @proChooseMethod.
  ///
  /// In zh, this message translates to:
  /// **'选择发电方式'**
  String get proChooseMethod;

  /// No description provided for @proClickPatToChange.
  ///
  /// In zh, this message translates to:
  /// **'点击下面的 Patreon 进行变更'**
  String get proClickPatToChange;

  /// No description provided for @proUpdatePat.
  ///
  /// In zh, this message translates to:
  /// **'更新 Patreon 状态'**
  String get proUpdatePat;

  /// No description provided for @proBindAccount.
  ///
  /// In zh, this message translates to:
  /// **'绑定到此账号'**
  String get proBindAccount;

  /// No description provided for @proChangePatKey.
  ///
  /// In zh, this message translates to:
  /// **'更换 Patreon 密钥'**
  String get proChangePatKey;

  /// No description provided for @proClearPat.
  ///
  /// In zh, this message translates to:
  /// **'清除 Patreon 信息'**
  String get proClearPat;

  /// No description provided for @proClickToBind.
  ///
  /// In zh, this message translates to:
  /// **'点击绑定'**
  String get proClickToBind;

  /// No description provided for @proEnterAuthCode.
  ///
  /// In zh, this message translates to:
  /// **'请输入授权代码'**
  String get proEnterAuthCode;

  /// No description provided for @proPleaseWait.
  ///
  /// In zh, this message translates to:
  /// **'请稍后'**
  String get proPleaseWait;

  /// No description provided for @proKeyRecorded.
  ///
  /// In zh, this message translates to:
  /// **'密钥已录入'**
  String get proKeyRecorded;

  /// No description provided for @proPatAccount.
  ///
  /// In zh, this message translates to:
  /// **'Patreon 账号'**
  String get proPatAccount;

  /// No description provided for @proBoundAccount.
  ///
  /// In zh, this message translates to:
  /// **'绑定账号'**
  String get proBoundAccount;

  /// No description provided for @proBindTime.
  ///
  /// In zh, this message translates to:
  /// **'绑定时间'**
  String get proBindTime;

  /// No description provided for @proRebindTime.
  ///
  /// In zh, this message translates to:
  /// **'可以换绑时间'**
  String get proRebindTime;

  /// No description provided for @proPatBindHint.
  ///
  /// In zh, this message translates to:
  /// **'请点击这里绑定到当前账号'**
  String get proPatBindHint;

  /// No description provided for @proPatRebindHint.
  ///
  /// In zh, this message translates to:
  /// **'绑定账号与当前登录用户名不一致，请换绑'**
  String get proPatRebindHint;

  /// No description provided for @proPatNotDetected.
  ///
  /// In zh, this message translates to:
  /// **'未检测到入会'**
  String get proPatNotDetected;

  /// No description provided for @proPatNormal.
  ///
  /// In zh, this message translates to:
  /// **'状态正常'**
  String get proPatNormal;

  /// No description provided for @proSynced.
  ///
  /// In zh, this message translates to:
  /// **'已同步'**
  String get proSynced;

  /// No description provided for @proPageLimit.
  ///
  /// In zh, this message translates to:
  /// **'未发电只能看前 {pages} 页'**
  String proPageLimit(int pages);

  /// No description provided for @proGo.
  ///
  /// In zh, this message translates to:
  /// **'去发电'**
  String get proGo;

  /// No description provided for @proErrNetworkTimeout.
  ///
  /// In zh, this message translates to:
  /// **'网络超时，请检查网络或更换发电方式'**
  String get proErrNetworkTimeout;

  /// No description provided for @proErrNetworkUnreachable.
  ///
  /// In zh, this message translates to:
  /// **'连接不上服务器，请检查网络或更换发电方式'**
  String get proErrNetworkUnreachable;

  /// No description provided for @proErrServerFailed.
  ///
  /// In zh, this message translates to:
  /// **'服务器处理失败'**
  String get proErrServerFailed;

  /// No description provided for @proErrServerInvalid.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回异常'**
  String get proErrServerInvalid;

  /// No description provided for @proErrRequestInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请求无效'**
  String get proErrRequestInvalid;

  /// No description provided for @proErrOrderNotSynced.
  ///
  /// In zh, this message translates to:
  /// **'订单尚未同步，请稍后再试'**
  String get proErrOrderNotSynced;

  /// No description provided for @proErrOrderUsed.
  ///
  /// In zh, this message translates to:
  /// **'订单已被使用'**
  String get proErrOrderUsed;

  /// No description provided for @proErrOrderAmount.
  ///
  /// In zh, this message translates to:
  /// **'订单金额无效'**
  String get proErrOrderAmount;

  /// No description provided for @proErrTicketNotFound.
  ///
  /// In zh, this message translates to:
  /// **'兑换券不存在'**
  String get proErrTicketNotFound;

  /// No description provided for @proErrTicketUsed.
  ///
  /// In zh, this message translates to:
  /// **'兑换券已被使用'**
  String get proErrTicketUsed;

  /// No description provided for @proErrTicketEventUsed.
  ///
  /// In zh, this message translates to:
  /// **'活动兑换券已参与'**
  String get proErrTicketEventUsed;

  /// No description provided for @proErrDeviceTime.
  ///
  /// In zh, this message translates to:
  /// **'请检查设备时间'**
  String get proErrDeviceTime;

  /// No description provided for @proErrPatNotBound.
  ///
  /// In zh, this message translates to:
  /// **'尚未绑定密钥'**
  String get proErrPatNotBound;

  /// No description provided for @browserAddressHint.
  ///
  /// In zh, this message translates to:
  /// **'输入网址'**
  String get browserAddressHint;

  /// No description provided for @browserBack.
  ///
  /// In zh, this message translates to:
  /// **'后退'**
  String get browserBack;

  /// No description provided for @browserForward.
  ///
  /// In zh, this message translates to:
  /// **'前进'**
  String get browserForward;

  /// No description provided for @checkUpdate.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get checkUpdate;

  /// No description provided for @checkingUpdate.
  ///
  /// In zh, this message translates to:
  /// **'正在检查更新'**
  String get checkingUpdate;

  /// No description provided for @alreadyLatest.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本'**
  String get alreadyLatest;

  /// No description provided for @newVersionFound.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本 {version}'**
  String newVersionFound(String version);

  /// No description provided for @updateTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本'**
  String get updateTitle;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本 {version}，请立即更新后继续使用'**
  String forceUpdateMessage(String version);

  /// No description provided for @downloadUpdate.
  ///
  /// In zh, this message translates to:
  /// **'去下载'**
  String get downloadUpdate;

  /// No description provided for @updateLater.
  ///
  /// In zh, this message translates to:
  /// **'以后再说'**
  String get updateLater;

  /// No description provided for @updateRemind.
  ///
  /// In zh, this message translates to:
  /// **'更新提醒'**
  String get updateRemind;

  /// No description provided for @updateRemindHint.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本时显示红点和提示'**
  String get updateRemindHint;

  /// No description provided for @exportLog.
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get exportLog;

  /// No description provided for @exportLogHint.
  ///
  /// In zh, this message translates to:
  /// **'只包含 Dart 错误。播放器原生崩溃不在这个文件里，安卓用 adb logcat，iOS 用 Xcode 控制台'**
  String get exportLogHint;

  /// No description provided for @exportLogEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有日志'**
  String get exportLogEmpty;

  /// No description provided for @friendLinks.
  ///
  /// In zh, this message translates to:
  /// **'友情链接'**
  String get friendLinks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
