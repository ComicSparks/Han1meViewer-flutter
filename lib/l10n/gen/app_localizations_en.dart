// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'HaVF';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get downloads => 'Downloads';

  @override
  String get mine => 'Me';

  @override
  String get settings => 'Settings';

  @override
  String get more => 'More';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get rename => 'Rename';

  @override
  String get add => 'Add';

  @override
  String get clear => 'Clear';

  @override
  String get cleared => 'Cleared';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get open => 'Open';

  @override
  String get all => 'All';

  @override
  String get empty => 'Nothing here';

  @override
  String get share => 'Share';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get playing => 'Playing';

  @override
  String get removed => 'Removed';

  @override
  String get description => 'Description';

  @override
  String get followSystem => 'Follow system';

  @override
  String get errTimeout => 'Connection timed out';

  @override
  String get errDns => 'DNS resolution failed. Try built-in hosts or DoH';

  @override
  String get errTls => 'TLS handshake failed';

  @override
  String get errProxy => 'Proxy connection failed';

  @override
  String get errNetwork => 'Network error';

  @override
  String get errCfChallenge => 'Cloudflare verification failed';

  @override
  String get errCfMismatch =>
      'Clearance does not match the current network, please verify again';

  @override
  String get errIpBlocked =>
      'Your IP is blocked by the site. Try another network or proxy';

  @override
  String get errNotFound => 'Not found';

  @override
  String get errNotLoggedIn => 'Please log in first';

  @override
  String get errLoginExpired => 'Login expired, please log in again';

  @override
  String get errLoginFailed => 'Login failed';

  @override
  String get errParse => 'Failed to parse the page. The site may have changed';

  @override
  String get errExists => 'Already downloaded';

  @override
  String get errInvalid => 'Invalid input';

  @override
  String get errInvalidImage => 'Invalid image';

  @override
  String errHttp(String code) {
    return 'Server returned $code';
  }

  @override
  String get cfVerifyTitle => 'Site verification';

  @override
  String get cfVerifyHint =>
      'Complete the Cloudflare check. This page closes automatically afterwards';

  @override
  String get login => 'Log in';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Log out?';

  @override
  String get loginSuccess => 'Logged in';

  @override
  String get webLogin => 'Web login';

  @override
  String get webLoginHint =>
      'Recommended. Log in inside the built-in browser, which also passes the human check';

  @override
  String get formLogin => 'Email & password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get cookieLogin => 'Import cookies';

  @override
  String get cookieLoginHint =>
      'Paste the site cookies copied from your browser';

  @override
  String get importCookie => 'Import';

  @override
  String get searchHint => 'Search videos, artists…';

  @override
  String get pasteLink => 'Open link from clipboard';

  @override
  String get noLinkInClipboard => 'No video link in clipboard';

  @override
  String get filter => 'Filter';

  @override
  String get searchEmptyHint => 'Type a keyword or use filters';

  @override
  String get browseAll => 'Browse all';

  @override
  String get searchHistory => 'Search history';

  @override
  String get genre => 'Genre';

  @override
  String get sort => 'Sort';

  @override
  String get releaseDate => 'Release date';

  @override
  String get duration => 'Duration';

  @override
  String get broadMatch => 'Broad match';

  @override
  String get broadMatchHint => 'Match any of the selected tags';

  @override
  String get brands => 'Brands';

  @override
  String get tagVideoAttributes => 'Video attributes';

  @override
  String get tagRelationships => 'Relationships';

  @override
  String get tagCharacteristics => 'Characteristics';

  @override
  String get tagAppearance => 'Appearance';

  @override
  String get tagLocation => 'Location';

  @override
  String get tagPlot => 'Plot';

  @override
  String get tagPositions => 'Positions';

  @override
  String get intro => 'Info';

  @override
  String get comments => 'Comments';

  @override
  String get noComments => 'No comments yet';

  @override
  String get commentHint => 'Write a comment…';

  @override
  String get commentSent => 'Sent';

  @override
  String get reply => 'Reply';

  @override
  String viewReplies(int count) {
    return 'View $count replies';
  }

  @override
  String get report => 'Report';

  @override
  String get reportSent => 'Reported';

  @override
  String get favorite => 'Like';

  @override
  String get favorites => 'Liked videos';

  @override
  String get watchLater => 'Watch later';

  @override
  String get addedToWatchLater => 'Added to Watch later';

  @override
  String get playlist => 'Playlist';

  @override
  String get playlists => 'Playlists';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get editPlaylist => 'Edit playlist';

  @override
  String get playlistTitle => 'Playlist title';

  @override
  String get playlistCreated => 'Playlist created';

  @override
  String get deletePlaylistConfirm => 'Delete this playlist?';

  @override
  String get removeFromList => 'Remove from list?';

  @override
  String videoCount(int count) {
    return '$count videos';
  }

  @override
  String get download => 'Download';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloadAdded => 'Added to downloads';

  @override
  String get chooseQuality => 'Choose quality';

  @override
  String get related => 'Related';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get playError => 'Playback failed';

  @override
  String get brightness => 'Brightness';

  @override
  String get volume => 'Volume';

  @override
  String get speed => 'Speed';

  @override
  String get quality => 'Quality';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get hKeyframes => 'H keyframes';

  @override
  String addKeyframeAt(String time) {
    return 'Add keyframe at $time';
  }

  @override
  String get keyframePromptHint => 'Note (optional)';

  @override
  String get keyframeAdded => 'Keyframe added';

  @override
  String get keyframesEmptyHint =>
      'No keyframes yet. Long-press the bookmark button while playing to add one';

  @override
  String sharedBy(String author) {
    return 'Shared keyframes · by $author';
  }

  @override
  String get localKeyframes => 'My keyframes';

  @override
  String get sharedKeyframes => 'Shared keyframes';

  @override
  String get sharedKeyframesFirst => 'Prefer shared keyframes';

  @override
  String get enableKeyframes => 'Enable H keyframes';

  @override
  String get enableKeyframesHint =>
      'Mark keyframes on the progress bar and count down before them';

  @override
  String get keyframeShowPrompt => 'Show index and note in countdown';

  @override
  String get keyframeCountdown => 'Countdown seconds';

  @override
  String keyframeCount(int count) {
    return '$count keyframes';
  }

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get tapToLogin => 'Log in to sync likes, playlists and history';

  @override
  String get tapToManageAccount => 'Manage account';

  @override
  String get localHistory => 'Watch history (local)';

  @override
  String get onlineHistory => 'Watch history (online)';

  @override
  String get clearHistoryConfirm => 'Clear all watch history?';

  @override
  String get deleteHistory => 'Delete this record?';

  @override
  String get sortLatest => 'Latest';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get account => 'Account';

  @override
  String accountStats(int subs, int videos) {
    return '$subs subscribers · $videos videos';
  }

  @override
  String get profile => 'Profile';

  @override
  String get username => 'Username';

  @override
  String get changePassword => 'Change password';

  @override
  String get oldPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get downloading => 'Downloading';

  @override
  String get noDownloading => 'No active downloads';

  @override
  String get queued => 'Queued';

  @override
  String get paused => 'Paused';

  @override
  String get failed => 'Failed';

  @override
  String get pauseAll => 'Pause all';

  @override
  String get resumeAll => 'Resume all';

  @override
  String get newGroup => 'New group';

  @override
  String get ungrouped => 'Ungrouped';

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get deleteGroupHint =>
      'Videos in this group will be moved to Ungrouped';

  @override
  String get moveToGroup => 'Move to group';

  @override
  String get deleteDownloadConfirm => 'Delete this download and its file?';

  @override
  String get saveToGallery => 'Save to gallery';

  @override
  String get exportFile => 'Export file';

  @override
  String get exported => 'Exported';

  @override
  String get exportFailed => 'Export failed';

  @override
  String downloadingNotification(int count, String title) {
    return '$count tasks in progress $title';
  }

  @override
  String get general => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get videoLanguage => 'Site subtitle language';

  @override
  String get simplifiedChinese => 'Simplified Chinese';

  @override
  String get traditionalChinese => 'Traditional Chinese';

  @override
  String get hideComments => 'Hide comments';

  @override
  String get clipboardDetect => 'Detect links in clipboard';

  @override
  String get clipboardDetectHint =>
      'Check the clipboard for video links when returning to the app (iOS shows a paste prompt)';

  @override
  String clipboardDetected(String code) {
    return 'Video $code detected';
  }

  @override
  String get networkSettings => 'Network settings';

  @override
  String get player => 'Player';

  @override
  String get defaultQuality => 'Default quality';

  @override
  String get longPressSpeed => 'Long-press speed';

  @override
  String get gestures => 'Gestures';

  @override
  String get gesturesHint =>
      'Swipe horizontally to seek, vertically for brightness (left) or volume (right)';

  @override
  String get resumePlayback => 'Resume from last position';

  @override
  String get fullscreenLandscape => 'Landscape in fullscreen';

  @override
  String get downloadConcurrency => 'Concurrent downloads';

  @override
  String get speedLimit => 'Speed limit';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get privacy => 'Privacy';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockHint => 'PIN with optional biometrics';

  @override
  String get changePin => 'Change PIN';

  @override
  String get setPin => 'Set PIN';

  @override
  String get pinSetupHint => 'Enter 4–8 digits';

  @override
  String get pinConfirm => 'Enter again to confirm';

  @override
  String get pinMismatch => 'Entries do not match';

  @override
  String get enterPin => 'Enter PIN to unlock';

  @override
  String get pinWrong => 'Wrong PIN';

  @override
  String get unlockReason => 'Unlock HaVF';

  @override
  String get biometric => 'Biometric unlock';

  @override
  String get lockDelay => 'Relock';

  @override
  String get lockImmediately => 'Immediately';

  @override
  String get lockAfter1Min => 'After 1 minute';

  @override
  String get lockAfter5Min => 'After 5 minutes';

  @override
  String get blurInBackground => 'Blur in app switcher';

  @override
  String get blurInBackgroundHint => 'Hide content in the app switcher';

  @override
  String get disguiseIcon => 'Disguise icon';

  @override
  String get disguiseIconHint => 'The launcher may take a moment to update';

  @override
  String get iconDefault => 'Default';

  @override
  String get iconCalc => 'Calculator';

  @override
  String get iconXxt => 'Xuebutong';

  @override
  String get storage => 'Storage';

  @override
  String get imageCache => 'Image cache';

  @override
  String get imageCacheLimit => 'Image cache limit';

  @override
  String get pageCache => 'Page cache';

  @override
  String get webviewData => 'Built-in browser data';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheHint =>
      'Clears image, page and browser caches. Downloads and login are kept';

  @override
  String get about => 'About';

  @override
  String get originalProject => 'Original project';

  @override
  String get discardChanges => 'Discard unsaved changes?';

  @override
  String get domain => 'Site domain';

  @override
  String get customMirror => 'Custom mirror';

  @override
  String get dns => 'DNS';

  @override
  String get builtInHosts => 'Built-in hosts';

  @override
  String get builtInHostsHint =>
      'Bypass DNS poisoning by connecting to Cloudflare IPs directly';

  @override
  String get customIps => 'Custom IPs (comma separated, empty = built-in)';

  @override
  String get dohServer => 'DoH server';

  @override
  String get bootstrapIps => 'Bootstrap IPs';

  @override
  String get timeout => 'Timeout';

  @override
  String get dnsDiagnose => 'Test resolution';

  @override
  String get proxy => 'Proxy';

  @override
  String get proxyMode => 'Proxy mode';

  @override
  String get proxySystem => 'System';

  @override
  String get proxyNone => 'None';

  @override
  String get proxyHost => 'Proxy host';

  @override
  String get proxyPort => 'Proxy port';

  @override
  String get identity => 'Device identity';

  @override
  String get deviceProfile => 'Random device';

  @override
  String get currentUserAgent => 'Current UA';

  @override
  String get followingWebview => 'WebView';

  @override
  String get androidDisguise => 'Android';

  @override
  String get verifyNow => 'Verify now';

  @override
  String get verifyNowHint =>
      'Open the site in the built-in browser to pass Cloudflare';

  @override
  String get verifySuccess => 'Verified';

  @override
  String get verifyCancelled => 'Verification not completed';

  @override
  String get manualCfImport => 'Import cf_clearance manually';

  @override
  String get manualCfImportHint =>
      'Copy cf_clearance and the matching User-Agent from a browser on the same network';

  @override
  String get clearCf => 'Clear clearance';

  @override
  String get regenerateIdentity => 'Regenerate identity';

  @override
  String get regenerateIdentityHint =>
      'Clears cf_clearance; you may need to verify again';

  @override
  String get userSortDefault => 'Default';

  @override
  String get userSortLatest => 'Latest';

  @override
  String get userSortPopular => 'Popular';

  @override
  String get userSortOldest => 'Oldest';
}
