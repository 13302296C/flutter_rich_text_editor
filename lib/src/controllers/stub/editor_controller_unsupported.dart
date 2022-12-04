import 'package:flutter/material.dart';
import 'package:flutter_rich_text_editor/flutter_rich_text_editor.dart';
import 'package:meta/meta.dart';
// speech to text
import 'package:speech_to_text/speech_to_text.dart';

/// Fallback controller (should never be used)
class HtmlEditorController extends ChangeNotifier {
  HtmlEditorController(
      {this.processInputHtml = true,
      this.processNewLineAsBr = false,
      this.processOutputHtml = true,
      HtmlEditorOptions? editorOptions,
      HtmlToolbarOptions? toolbarOptions})
      : editorOptions = editorOptions ?? HtmlEditorOptions(),
        toolbarOptions = toolbarOptions ?? HtmlToolbarOptions();

  /// Defines options for the html editor
  late HtmlEditorOptions editorOptions;

  /// Defines options for the editor toolbar
  late HtmlToolbarOptions toolbarOptions;

  //late List<Plugins> plugins;

  /// Puts editor in read-only mode, hiding its toollbar
  bool isReadOnly = false;

  ///
  bool initialized = false;

  ///
  bool isDisabled = false;

  ///
  bool hasFocus = false;

  /// Toolbar widget state to call various methods. For internal use only.
  @internal
  ToolbarWidgetState? toolbar;

  /// Sets & activates Summernote's callbacks. See the functions available in
  /// [Callbacks] for more details.
  Callbacks? callbacks;

  ///
  GlobalKey toolbarKey = GlobalKey();

  ///
  ValueNotifier<double> contentHeight = ValueNotifier(64);
  double get actualHeight => contentHeight.value;

  double? _toolbarHeight;
  double? get toolbarHeight => _toolbarHeight;
  set toolbarHeight(double? height) {
    _toolbarHeight = height;
    notifyListeners();
  }

  /// The editor will automatically adjust its height once the page is loaded to
  /// ensure there is no vertical scrolling or empty space. It will only perform
  /// the adjustment when the editor is the loaded page.
  ///
  /// It will also disable vertical scrolling on the webview, so scrolling on
  /// the webview will actually scroll the rest of the page rather than doing
  /// nothing because it is trying to scroll the webview container.
  ///
  /// The default value is true. It is recommended to leave this as true because
  /// it significantly improves the UX.
  bool get autoAdjustHeight => editorOptions.height == null;

  /// Determines whether text processing should happen on input HTML, e.g.
  /// whether a new line should be converted to a <br>.
  ///
  /// The default value is true.
  final bool processInputHtml;

  /// Determines whether newlines (\n) should be written as <br>. This is not
  /// recommended for HTML documents.
  ///
  /// The default value is false.
  final bool processNewLineAsBr;

  /// Determines whether text processing should happen on output HTML, e.g.
  /// whether <p><br></p> is returned as "". For reference, Summernote uses
  /// that HTML as the default HTML (when no text is in the editor).
  ///
  /// The default value is true.
  final bool processOutputHtml;

  /// Internally tracks the character count in the editor
  int _characterCount = 0;

  /// Gets the current character count
  // ignore: unnecessary_getters_setters
  int get characterCount => _characterCount;

  /// Sets the current character count. Marked as internal method - this should
  /// not be used outside of the package itself.
  // ignore: unnecessary_getters_setters
  @internal
  set characterCount(int count) => _characterCount = count;

  /// Allows the [InAppWebViewController] for the Html editor to be accessed
  /// outside of the package itself for endless control and customization.
  dynamic get editorController => null;

  /// Internal method to set the [InAppWebViewController] when webview initialization
  /// is complete
  @internal
  set editorController(dynamic controller) => {};

  /// Internal method to set the view ID when iframe initialization
  /// is complete
  String? _viewId;
  set viewId(String? viewId) => _viewId = viewId;
  String get viewId => _viewId!;

  // ignore: prefer_final_fields
  String _buffer = '';
  bool get isContentEmpty => _buffer == '';

  /// Dictation controller
  SpeechToText? speechToText;

  /// is dictation available
  bool sttAvailable = false;

  /// is dictation running
  bool isRecording = false;

  /// Dictation result buffer
  String sttBuffer = '';

  /// Disposes controller
  @override
  void dispose() {
    super.dispose();
  }

  /// Add a notification to the bottom of the editor. This is styled similar to
  /// Bootstrap alerts. You can set the HTML to be displayed in the alert,
  /// and the notificationType determines how the alert is displayed.
  void addNotification(String html, NotificationType notificationType) {}

  /// Clears the editor of any text.
  Future<void> clear() async {}

  /// Clears the focus from the webview by hiding the keyboard, calling the
  /// clearFocus method on the [InAppWebViewController], and resetting the height
  /// in case it was changed.
  void clearFocus() {}

  /// disables the Html editor
  Future<void> initEditor(BuildContext initBC, double initHeight) async {}

  /// disables the Html editor
  Future<void> disable() async {}

  /// enables the Html editor
  Future<void> enable() async {}

  /// A function to quickly call a document.execCommand function in a readable format
  Future<void> execCommand(String command, {String? argument}) async {}

  /// A function to execute JS passed as a [WebScript] to the editor. This should
  /// only be used on Flutter Web.
  Future<dynamic> evaluateJavascriptWeb(String name,
          {bool hasReturnValue = false}) =>
      Future.value();

  /// Gets the text from the editor and returns it as a [String].
  Future<String> getText() => Future.value('');

  /// Gets selection and returns it as a [String].
  Future<String> getSelectedText() => Future.value('');

  /// Gets the selected HTML from the editor. You should use
  /// [controller.editorController.getSelectedText()] on mobile.
  ///
  /// [withHtmlTags] may not work properly when the selected text is entirely
  /// within one HTML tag. However if the selected text spans multiple different
  /// tags, it should work as expected.
  Future<String> getSelectedTextWeb({bool withHtmlTags = false}) =>
      Future.value('');

  /// Insert HTML at the position of the cursor in the editor
  /// Note: This method should not be used for plaintext strings
  Future<void> insertHtml(String html) async {}

  /// Insert a link at the position of the cursor in the editor
  Future<void> insertLink(String text, String url, bool isNewWindow) async {}

  /// Remove a link at the position of the cursor in the editor
  Future<void> removeLink() async {}

  /// Insert a network image at the position of the cursor in the editor
  void insertNetworkImage(String url, {String filename = ''}) {}

  /// Insert text at the end of the current HTML content in the editor
  /// Note: This method should only be used for plaintext strings
  Future<void> insertText(String text) async {}

  /// Recalculates the height of the editor to remove any vertical scrolling.
  /// This method will not do anything if [autoAdjustHeight] is turned off.
  Future<void> recalculateHeight() async {}

  /// Redoes the last action
  void redo() {}

  /// Refresh the page
  ///
  /// Note: This should only be used in Flutter Web!!!
  void reloadWeb() {}

  /// Remove the current notification from the bottom of the editor
  void removeNotification() {}

  /// Resets the height of the editor back to the original if it was changed to
  /// accommodate the keyboard. This should only be used on mobile, and only
  /// when [adjustHeightForKeyboard] is enabled.
  void resetHeight() {}

  /// Sets the hint for the editor.
  void setHint(String text) {}

  /// Sets the focus to the editor.
  void setFocus() {}

  /// Sets the editor to full-screen mode.
  void setFullScreen() {}

  /// Sets the text of the editor. Some pre-processing is applied to convert
  /// [String] elements like "\n" to HTML elements.
  void setText(String text) {}

  /// toggles the codeview in the Html editor
  void toggleCodeView() {}

  /// Undoes the last action
  void undo() {}

  /// Internal function to change list style on Web
  @internal
  void changeListStyle(String changed) {}

  /// Internal function to change line height on Web
  @internal
  void changeLineHeight(String changed) {}

  /// Internal function to change text direction on Web
  @internal
  void changeTextDirection(String changed) {}

  /// Internal function to change case on Web
  @internal
  void changeCase(String changed) {}

  /// Internal function to insert table on Web
  @internal
  void insertTable(String dimensions) {}

  ///
  // ignore: unused_element
  Future<bool> _initSpeechToText() async {
    return false;
  }

  ///
  Future<void> convertSpeechToText(Function(String v) onResult) async {}

  /// Triggers result from recognition
  Future<void> stopRecording() async {}

  /// Does not trigger result from recognition
  Future<void> cancelRecording() async {}
}