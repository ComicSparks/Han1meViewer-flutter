// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'HaVF';

  @override
  String get home => 'ホーム';

  @override
  String get search => '検索';

  @override
  String get downloads => 'ダウンロード';

  @override
  String get mine => 'マイページ';

  @override
  String get settings => '設定';

  @override
  String get more => 'もっと見る';

  @override
  String get retry => '再試行';

  @override
  String get refresh => '更新';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get saved => '保存しました';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get rename => '名前を変更';

  @override
  String get add => '追加';

  @override
  String get clear => 'クリア';

  @override
  String get cleared => '削除しました';

  @override
  String get apply => '適用';

  @override
  String get reset => 'リセット';

  @override
  String get open => '開く';

  @override
  String get all => 'すべて';

  @override
  String get empty => '何もありません';

  @override
  String get share => '共有';

  @override
  String get linkCopied => 'リンクをコピーしました';

  @override
  String get copied => 'コピーしました';

  @override
  String get needPro => '発電後に使えます';

  @override
  String get exportNameTooLong => 'ファイル名またはパスが長すぎます。タイトルを短くしてから書き出します';

  @override
  String get multiSelect => '選択';

  @override
  String selectedCount(int count) {
    return '$count 件選択';
  }

  @override
  String downloadQueued(int added, int skipped) {
    return '$added 件追加、$skipped 件はスキップ';
  }

  @override
  String get subscriptionUpdates => '購読の更新';

  @override
  String get subscriptionUpdatesHint => '前回以降の新しい動画に印を付ける';

  @override
  String get playing => '再生中';

  @override
  String get removed => '削除しました';

  @override
  String get description => '説明';

  @override
  String get followSystem => 'システムに従う';

  @override
  String get errTimeout => '接続がタイムアウトしました';

  @override
  String get errDns => '名前解決に失敗しました。内蔵 Hosts または DoH をお試しください';

  @override
  String get errTls => 'TLS ハンドシェイクに失敗しました';

  @override
  String get errProxy => 'プロキシ接続に失敗しました';

  @override
  String get errNetwork => 'ネットワークエラー';

  @override
  String get errCfChallenge => 'Cloudflare の認証に失敗しました';

  @override
  String get errCfMismatch => '認証情報が現在のネットワークと一致しません。再認証してください';

  @override
  String get errIpBlocked => 'この IP はブロックされています。ネットワークまたはプロキシを変更してください';

  @override
  String get errNotFound => '見つかりません';

  @override
  String get errNotLoggedIn => '先にログインしてください';

  @override
  String get errLoginExpired => 'ログインの有効期限が切れました';

  @override
  String get errLoginFailed => 'ログインに失敗しました';

  @override
  String get errParse => 'ページの解析に失敗しました';

  @override
  String get errExists => 'ダウンロード済みです';

  @override
  String get errInvalid => '無効な入力です';

  @override
  String get errInvalidImage => '無効な画像です';

  @override
  String errHttp(String code) {
    return 'サーバーが $code を返しました';
  }

  @override
  String get cfVerifyTitle => 'サイト認証';

  @override
  String get cfVerifyHint => 'Cloudflare の認証を完了してください。完了後に自動で戻ります';

  @override
  String get login => 'ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => 'ログアウトしますか？';

  @override
  String get loginSuccess => 'ログインしました';

  @override
  String get webLogin => 'Web ログイン';

  @override
  String get webLoginHint => '推奨。内蔵ブラウザでログインし、認証も同時に行えます';

  @override
  String get formLogin => 'メールとパスワード';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get cookieLogin => 'Cookie をインポート';

  @override
  String get cookieLoginHint => 'ブラウザからコピーした Cookie を貼り付けてください';

  @override
  String get importCookie => 'インポート';

  @override
  String get searchHint => '動画・作者を検索…';

  @override
  String get pasteLink => 'クリップボードのリンクを開く';

  @override
  String get noLinkInClipboard => 'クリップボードに動画リンクがありません';

  @override
  String get filter => 'フィルター';

  @override
  String get searchEmptyHint => 'キーワードを入力するかフィルターを使ってください';

  @override
  String get browseAll => 'すべて見る';

  @override
  String get searchHistory => '検索履歴';

  @override
  String get genre => 'ジャンル';

  @override
  String get sort => '並び替え';

  @override
  String get releaseDate => '公開日';

  @override
  String get duration => '長さ';

  @override
  String get broadMatch => 'あいまい検索';

  @override
  String get broadMatchHint => '選択したタグのいずれかに一致';

  @override
  String get brands => 'ブランド';

  @override
  String get tagVideoAttributes => '動画の属性';

  @override
  String get tagRelationships => '人間関係';

  @override
  String get tagCharacteristics => 'キャラ設定';

  @override
  String get tagAppearance => '外見・体型';

  @override
  String get tagLocation => 'シチュエーション';

  @override
  String get tagPlot => 'ストーリー';

  @override
  String get tagPositions => '体位';

  @override
  String get intro => '概要';

  @override
  String get comments => 'コメント';

  @override
  String get noComments => 'コメントはまだありません';

  @override
  String get commentHint => 'コメントを書く…';

  @override
  String get commentSent => '送信しました';

  @override
  String get reply => '返信';

  @override
  String viewReplies(int count) {
    return '$count 件の返信を表示';
  }

  @override
  String get report => '通報';

  @override
  String get reportSent => '通報しました';

  @override
  String get favorite => 'いいね';

  @override
  String get favorites => 'いいねした動画';

  @override
  String get watchLater => '後で見る';

  @override
  String get addedToWatchLater => '後で見るに追加しました';

  @override
  String get playlist => 'プレイリスト';

  @override
  String get playlists => 'プレイリスト';

  @override
  String get addToPlaylist => 'プレイリストに追加';

  @override
  String get newPlaylist => '新規プレイリスト';

  @override
  String get editPlaylist => 'プレイリストを編集';

  @override
  String get playlistTitle => 'プレイリスト名';

  @override
  String get playlistCreated => 'プレイリストを作成しました';

  @override
  String get deletePlaylistConfirm => 'このプレイリストを削除しますか？';

  @override
  String get removeFromList => 'リストから削除しますか？';

  @override
  String videoCount(int count) {
    return '$count 本の動画';
  }

  @override
  String get download => 'ダウンロード';

  @override
  String get downloaded => 'ダウンロード済み';

  @override
  String get downloadAdded => 'ダウンロードに追加しました';

  @override
  String get chooseQuality => '画質を選択';

  @override
  String get related => '関連動画';

  @override
  String get subscribe => '登録';

  @override
  String get subscribed => '登録済み';

  @override
  String get subscriptions => '登録チャンネル';

  @override
  String get playError => '再生に失敗しました';

  @override
  String get brightness => '明るさ';

  @override
  String get volume => '音量';

  @override
  String get speed => '再生速度';

  @override
  String get quality => '画質';

  @override
  String get fullscreen => '全画面';

  @override
  String get hKeyframes => 'H キーフレーム';

  @override
  String addKeyframeAt(String time) {
    return '$time にキーフレームを追加';
  }

  @override
  String get keyframePromptHint => 'メモ（任意）';

  @override
  String get keyframeAdded => 'キーフレームを追加しました';

  @override
  String get keyframesEmptyHint => 'キーフレームはありません。再生中にブックマークボタンを長押しで追加できます';

  @override
  String sharedBy(String author) {
    return '共有キーフレーム · 作者 $author';
  }

  @override
  String get localKeyframes => 'マイキーフレーム';

  @override
  String get sharedKeyframes => '共有キーフレーム';

  @override
  String get sharedKeyframesFirst => '共有キーフレームを優先';

  @override
  String get enableKeyframes => 'H キーフレームを有効化';

  @override
  String get enableKeyframesHint => 'シークバーに表示し、直前にカウントダウンします';

  @override
  String get keyframeShowPrompt => 'カウントダウンに番号とメモを表示';

  @override
  String get keyframeCountdown => 'カウントダウン秒数';

  @override
  String keyframeCount(int count) {
    return '$count 個のキーフレーム';
  }

  @override
  String get notLoggedIn => '未ログイン';

  @override
  String get tapToLogin => 'ログインしていいね・リスト・履歴を同期';

  @override
  String get tapToManageAccount => 'アカウント管理';

  @override
  String get localHistory => '視聴履歴（ローカル）';

  @override
  String get onlineHistory => '視聴履歴（オンライン）';

  @override
  String get clearHistoryConfirm => '視聴履歴をすべて削除しますか？';

  @override
  String get deleteHistory => 'この履歴を削除しますか？';

  @override
  String get sortLatest => '新しい順';

  @override
  String get sortPopular => '人気順';

  @override
  String get sortOldest => '古い順';

  @override
  String get userSortDefault => 'デフォルト';

  @override
  String get userSortLatest => '新しい順';

  @override
  String get userSortPopular => '人気順';

  @override
  String get userSortOldest => '古い順';

  @override
  String get account => 'アカウント';

  @override
  String accountStats(int subs, int videos) {
    return '登録者 $subs · 動画 $videos';
  }

  @override
  String get profile => 'プロフィール';

  @override
  String get username => 'ユーザー名';

  @override
  String get changePassword => 'パスワード変更';

  @override
  String get oldPassword => '現在のパスワード';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmPassword => '新しいパスワード（確認）';

  @override
  String get downloading => 'ダウンロード中';

  @override
  String get noDownloading => '進行中のダウンロードはありません';

  @override
  String get queued => '待機中';

  @override
  String get paused => '一時停止';

  @override
  String get failed => '失敗';

  @override
  String get pauseAll => 'すべて一時停止';

  @override
  String get resumeAll => 'すべて再開';

  @override
  String get newGroup => '新規グループ';

  @override
  String get ungrouped => '未分類';

  @override
  String get deleteGroup => 'グループを削除';

  @override
  String get deleteGroupHint => 'グループ内の動画は未分類に移動します';

  @override
  String get moveToGroup => 'グループに移動';

  @override
  String get deleteDownloadConfirm => 'ダウンロードとファイルを削除しますか？';

  @override
  String get saveToGallery => '写真に保存';

  @override
  String get exportFile => 'ファイルを書き出す';

  @override
  String get exported => '書き出しました';

  @override
  String get exportFailed => '書き出しに失敗しました';

  @override
  String downloadingNotification(int count, String title) {
    return '$count 件のタスクを実行中 $title';
  }

  @override
  String get general => '一般';

  @override
  String get theme => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get videoLanguage => 'サイトの字幕言語';

  @override
  String get simplifiedChinese => '簡体字中国語';

  @override
  String get traditionalChinese => '繁体字中国語';

  @override
  String get hideComments => 'コメントを非表示';

  @override
  String get clipboardDetect => 'クリップボードのリンク検出';

  @override
  String get clipboardDetectHint => 'アプリに戻った時にリンクを検出します（iOS では確認が表示されます）';

  @override
  String clipboardDetected(String code) {
    return '動画 $code を検出しました';
  }

  @override
  String get networkSettings => 'ネットワーク設定';

  @override
  String get player => 'プレーヤー';

  @override
  String get defaultQuality => 'デフォルト画質';

  @override
  String get longPressSpeed => '長押し倍速';

  @override
  String get gestures => 'ジェスチャー';

  @override
  String get gesturesHint => '左右でシーク、左側上下で明るさ、右側上下で音量';

  @override
  String get resumePlayback => '前回の位置から再生';

  @override
  String get fullscreenLandscape => '全画面で横向きにする';

  @override
  String get downloadConcurrency => '同時ダウンロード数';

  @override
  String get speedLimit => '速度制限';

  @override
  String get unlimited => '無制限';

  @override
  String get privacy => 'プライバシー';

  @override
  String get appLock => 'アプリロック';

  @override
  String get appLockHint => 'PIN と生体認証でロック';

  @override
  String get changePin => 'PIN を変更';

  @override
  String get setPin => 'PIN を設定';

  @override
  String get pinSetupHint => '4〜8 桁の数字を入力';

  @override
  String get pinConfirm => 'もう一度入力';

  @override
  String get pinMismatch => '入力が一致しません';

  @override
  String get enterPin => 'PIN を入力して解除';

  @override
  String get pinWrong => 'PIN が違います';

  @override
  String get unlockReason => 'HaVF のロックを解除';

  @override
  String get biometric => '生体認証';

  @override
  String get lockDelay => '再ロック';

  @override
  String get lockImmediately => 'すぐに';

  @override
  String get lockAfter1Min => '1 分後';

  @override
  String get lockAfter5Min => '5 分後';

  @override
  String get blurInBackground => 'バックグラウンドでぼかす';

  @override
  String get blurInBackgroundHint => 'アプリ切替画面で内容を隠す';

  @override
  String get disguiseIcon => 'アイコン偽装';

  @override
  String get disguiseIconHint => 'ホーム画面の更新に少し時間がかかる場合があります';

  @override
  String get iconDefault => 'デフォルト';

  @override
  String get iconCalc => '電卓';

  @override
  String get iconXxt => '学不通';

  @override
  String get storage => 'ストレージ';

  @override
  String get imageCache => '画像キャッシュ';

  @override
  String get imageCacheLimit => '画像キャッシュ上限';

  @override
  String get pageCache => 'ページキャッシュ';

  @override
  String get webviewData => '内蔵ブラウザのデータ';

  @override
  String get clearCache => 'キャッシュを削除';

  @override
  String get clearCacheHint => '画像・ページ・ブラウザのキャッシュを削除します（ダウンロードとログインは保持）';

  @override
  String get about => 'このアプリについて';

  @override
  String get discardChanges => '保存していない変更を破棄しますか？';

  @override
  String get domain => 'サイトドメイン';

  @override
  String get customMirror => 'カスタムミラー';

  @override
  String get dns => 'DNS';

  @override
  String get builtInHosts => '内蔵 Hosts';

  @override
  String get builtInHostsHint => 'DNS 汚染を回避して Cloudflare に直接接続';

  @override
  String get customIps => 'カスタム IP（カンマ区切り、空欄で内蔵）';

  @override
  String get dohServer => 'DoH サーバー';

  @override
  String get bootstrapIps => 'ブートストラップ IP';

  @override
  String get timeout => 'タイムアウト';

  @override
  String get dnsDiagnose => '名前解決テスト';

  @override
  String get proxy => 'プロキシ';

  @override
  String get proxyMode => 'プロキシモード';

  @override
  String get proxySystem => 'システム';

  @override
  String get proxyNone => '使用しない';

  @override
  String get proxyHost => 'プロキシホスト';

  @override
  String get proxyPort => 'プロキシポート';

  @override
  String get identity => 'デバイス ID';

  @override
  String get deviceProfile => 'ランダムデバイス';

  @override
  String get currentUserAgent => '現在の UA';

  @override
  String get followingWebview => 'WebView';

  @override
  String get androidDisguise => 'Android 偽装';

  @override
  String get verifyNow => '今すぐ認証';

  @override
  String get verifyNowHint => '内蔵ブラウザで Cloudflare 認証を行います';

  @override
  String get verifySuccess => '認証しました';

  @override
  String get verifyCancelled => '認証が完了しませんでした';

  @override
  String get manualCfImport => 'cf_clearance を手動インポート';

  @override
  String get manualCfImportHint =>
      '同じネットワークのブラウザから cf_clearance と対応する User-Agent をコピーしてください';

  @override
  String get clearCf => '認証情報を削除';

  @override
  String get regenerateIdentity => 'デバイス ID を再生成';

  @override
  String get regenerateIdentityHint => 'cf_clearance が削除され、再認証が必要になる場合があります';

  @override
  String get proTitle => '発電';

  @override
  String get proCenter => '発電センター';

  @override
  String get proPowered => '発電中';

  @override
  String get proNotPowered => '未発電';

  @override
  String get proGuide =>
      '発電状態はログイン後のユーザー名に紐づきます。\n\n「以前発電した」で既存の状態を同期します\n「今発電した」でコードを引き換えます\nPatreon は別の発電方法です\n「発電方法」を変えると接続失敗が解消することがあります';

  @override
  String get proSignIn => '交換';

  @override
  String get proPatreon => 'Patreon';

  @override
  String get proIHavePowered => '以前発電した';

  @override
  String get proIJustPowered => '今発電した';

  @override
  String get proEnterCode => 'コードを入力';

  @override
  String get proPowerMethod => '発電方法';

  @override
  String get proChooseMethod => '発電方法を選択';

  @override
  String get proClickPatToChange => '下の Patreon から変更してください';

  @override
  String get proUpdatePat => 'Patreon の状態を更新';

  @override
  String get proBindAccount => 'このアカウントに紐づける';

  @override
  String get proChangePatKey => 'Patreon キーを変更';

  @override
  String get proClearPat => 'Patreon 情報を削除';

  @override
  String get proClickToBind => 'タップして紐づけ';

  @override
  String get proEnterAuthCode => '認証コードを入力してください';

  @override
  String get proPleaseWait => 'お待ちください';

  @override
  String get proKeyRecorded => 'キーを保存しました';

  @override
  String get proPatAccount => 'Patreon アカウント';

  @override
  String get proBoundAccount => '紐づけアカウント';

  @override
  String get proBindTime => '紐づけ日時';

  @override
  String get proRebindTime => '再紐づけ可能日時';

  @override
  String get proPatBindHint => 'タップして現在のアカウントに紐づけてください';

  @override
  String get proPatRebindHint => '紐づけアカウントが現在のユーザー名と一致しません。付け替えてください';

  @override
  String get proPatNotDetected => '入会が検出されませんでした';

  @override
  String get proPatNormal => '正常';

  @override
  String get proSynced => '同期しました';

  @override
  String proPageLimit(int pages) {
    return '未発電では先頭 $pages ページまでです';
  }

  @override
  String get proGo => '発電する';

  @override
  String get proErrNetworkTimeout => 'タイムアウトしました。ネットワークを確認するか、発電方法を変えてください';

  @override
  String get proErrNetworkUnreachable =>
      'サーバーに接続できません。ネットワークを確認するか、発電方法を変えてください';

  @override
  String get proErrServerFailed => 'サーバーで処理できませんでした';

  @override
  String get proErrServerInvalid => 'サーバーの応答が不正です';

  @override
  String get proErrRequestInvalid => 'リクエストが無効です';

  @override
  String get proErrOrderNotSynced => '注文がまだ同期されていません。しばらくしてから再試行してください';

  @override
  String get proErrOrderUsed => 'この注文は使用済みです';

  @override
  String get proErrOrderAmount => '注文金額が無効です';

  @override
  String get proErrTicketNotFound => '引き換え券が見つかりません';

  @override
  String get proErrTicketUsed => 'この引き換え券は使用済みです';

  @override
  String get proErrTicketEventUsed => 'このイベント券は使用済みです';

  @override
  String get proErrDeviceTime => '端末の時刻を確認してください';

  @override
  String get proErrPatNotBound => 'キーがまだ紐づいていません';

  @override
  String get browserAddressHint => 'アドレスを入力';

  @override
  String get browserBack => '戻る';

  @override
  String get browserForward => '進む';

  @override
  String get checkUpdate => '更新を確認';

  @override
  String get checkingUpdate => '更新を確認しています';

  @override
  String get alreadyLatest => '最新バージョンです';

  @override
  String newVersionFound(String version) {
    return '新しいバージョン $version';
  }

  @override
  String get updateTitle => '新しいバージョン';

  @override
  String forceUpdateMessage(String version) {
    return '新しいバージョン $version があります。更新してから続けてください';
  }

  @override
  String get downloadUpdate => 'ダウンロード';

  @override
  String get updateLater => '後で';

  @override
  String get updateRemind => '更新のお知らせ';

  @override
  String get updateRemindHint => '新しいバージョンがあるときに印と案内を表示します';

  @override
  String get friendLinks => 'リンク';
}
