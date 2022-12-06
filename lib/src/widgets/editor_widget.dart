import 'dart:math' as math;
import 'dart:async';
import 'package:flutter_rich_text_editor/src/widgets/toolbar_widget.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rich_text_editor/src/controllers/editor_controller.dart';
import 'package:flutter_rich_text_editor/src/models/callbacks.dart';
import 'package:flutter_rich_text_editor/src/models/html_editor_options.dart';
import 'package:flutter_rich_text_editor/src/models/html_toolbar_options.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// HTML rich text editor
class HtmlEditor extends StatefulWidget {
  HtmlEditor({
    Key? key,
    this.height,
    this.minHeight,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.isReadOnly = false,
    this.enableDicatation,
    this.controller,
    this.callbacks,
    //this.plugins = const [],
  }) : super(key: key);

  /// Shortcut for onChanged callback
  final void Function(String?)? onChanged;

  /// Provides access to all options and features
  final HtmlEditorController? controller;

  /// Sets the list of Summernote plugins enabled in the editor.
  //final List<Plugins> plugins;

  /// Puts editor in read-only mode, hiding its toollbar
  final bool isReadOnly;

  /// If enabled - shows microphone icon and allows to use dictation within
  /// the editor
  final bool? enableDicatation;

  /// Desired hight. 'Auto' if null.
  final double? height;

  /// If height is omited, the editor height
  /// will be equal or greater than `minHeight`.
  final double? minHeight;

  /// Initial text to load into the editor
  final String? initialValue;

  /// Hint text to display when the editor is empty.
  ///
  /// Defaults to [ ***Your text here...*** ]
  final String? hint;

  /// Sets & activates callbacks. See the functions available in
  /// [Callbacks] for more details.
  final Callbacks? callbacks;

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> with TickerProviderStateMixin {
  late final HtmlEditorController _controller;
  Callbacks? get callbacks => _controller.callbacks;

  //List<Plugins> get plugins => widget.controller.plugins;

  HtmlEditorOptions get editorOptions => _controller.editorOptions!;

  HtmlToolbarOptions get toolbarOptions => _controller.toolbarOptions!;

  /// if height if fixed = return fixed height, otherwise return
  /// greatest of `minHeight` and `contentHeight`.
  double get _height =>
      editorOptions.height ??
      widget.height ??
      math.max(
          widget.minHeight ?? 0,
          _controller.contentHeight.value +
              (toolbarOptions.toolbarPosition == ToolbarPosition.custom ||
                      !toolbarOptions.fixedToolbar
                  ? 0
                  : (_controller.toolbarHeight ?? 0)));

  ///
  bool showToolbar = false;

  ///
  @internal
  Timer? timer;

  @override
  void initState() {
    _initializeController();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.toolbarHeight == null) {
      if (_controller.isReadOnly) {
        _controller.toolbarHeight = 0;
        if (!_controller.initialized) {
          _controller.initEditor(context, editorOptions.height ?? _height);
        }
      } else {
        if (!_controller.initialized) {
          _controller.initEditor(
              context, _height - (_controller.toolbarHeight ?? 0));
        }
        _controller.toolbarHeight = _controller.isReadOnly ||
                toolbarOptions.toolbarPosition == ToolbarPosition.custom
            ? 0
            : 51;
      }
    }
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: editorOptions.decoration,
            height: _height,
            child: Column(
              verticalDirection:
                  toolbarOptions.toolbarPosition == ToolbarPosition.aboveEditor
                      ? VerticalDirection.down
                      : VerticalDirection.up,
              children: <Widget>[
                if (toolbarOptions.toolbarPosition != ToolbarPosition.custom)
                  _toolbar(),
                Expanded(
                    child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Stack(
                    children: [
                      _backgroundWidget(context),
                      _hintTextWidget(context),
                      _controller.initialized &&
                              _controller.toolbarHeight != null
                          ? _controller.view(_controller)
                          : SizedBox(),
                      _scrollPatch(context),
                      _sttDictationPreview(),
                    ],
                  ),
                )),
              ],
            ),
          );
        });
  }

  ///
  Widget _toolbar() {
    return ToolbarWidget(
      key: _controller.toolbarKey,
      controller: _controller,
    );
  }

  ///STT popup
  Widget _sttDictationPreview() {
    if (!_controller.isRecording) return SizedBox();
    var textColor = editorOptions.dictationPreviewTextColor ??
        Theme.of(context).textTheme.bodyText1?.color;
    return PointerInterceptor(
      child: Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: Container(
            decoration: editorOptions.dictationPreviewDecoration ??
                BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 0,
                          color: Colors.black38)
                    ]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: textColor,
                      ),
                      Text(':',
                          style: TextStyle(
                            color: textColor,
                          )),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(_controller.sttBuffer,
                            style: TextStyle(
                              color: textColor,
                            )),
                      ),
                    ],
                  ),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black26
                          : Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _controller.cancelRecording,
                          child: Text('Discard',
                              style: TextStyle(
                                color: textColor,
                              ))),
                      SizedBox(width: 24),
                      TextButton(
                          onPressed: _controller.stopRecording,
                          child: Text('Insert',
                              style: TextStyle(
                                color: textColor,
                              ))),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  ///
  Widget _scrollPatch(BuildContext context) {
    // if (_controller.hasFocus && !_controller.alreadyDisabled) {
    return SizedBox();
    // }
    // return GestureDetector(
    //     onTap: () {
    //       _controller.setFocus();
    //     },
    //     child: PointerInterceptor(child: Positioned.fill(child: SizedBox())));
  }

  ///
  Widget _hintTextWidget(BuildContext context) {
    if (_controller.isContentEmpty && !_controller.hasFocus) {
      return Positioned.fill(
          child: Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 56),
        child: Text(editorOptions.hint ?? '',
            style: editorOptions.hintStyle ??
                TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(.3))),
      ));
    } else {
      return SizedBox();
    }
  }

  ///
  Widget _backgroundWidget(BuildContext context) {
    return Positioned.fill(
        child: Container(
            decoration: editorOptions.backgroundDecoration,
            color: editorOptions.backgroundColor));
  }

  /// If controller is provided to the editor - initialize its values
  /// otherwise create internal controller with the values provided
  void _initializeController() {
    _controller = widget.controller ?? HtmlEditorController();
    _controller.context = context;
    // if (initialValue != null &&
    //     controller!.editorOptions!.initialText != null &&
    //     !controller!.initialized) {
    //   throw Exception(
    //       'Cannot have both [initialValue] and [editorOptions.initialText]. Please choose one.');
    // }
    if (widget.initialValue != null) {
      _controller.setInitialText(widget.initialValue!);
    }
    if (widget.hint != null) {
      _controller.editorOptions!.hint = widget.hint;
    }

    if (widget.height != null) {
      _controller.editorOptions!.height = widget.height;
    }

    if (widget.enableDicatation != null) {
      _controller.enableDicatation = widget.enableDicatation!;
    }

    if (_controller.isReadOnly != widget.isReadOnly) {
      _controller.isReadOnly = widget.isReadOnly;
      _controller.toolbarHeight = null; // trigger recalc
      if (widget.isReadOnly) {
        _controller.disable();
      } else {
        _controller.enable();
      }
    }

    _controller.callbacks = widget.callbacks;
    //_controller.plugins = plugins;
    if (widget.callbacks == null) {
      _controller.callbacks = Callbacks(onChangeContent: widget.onChanged);
    } else {
      if (_controller.callbacks!.onChangeContent != null &&
          widget.onChanged != null) {
        throw Exception(
            'Cannot have both onChanged and Callbacks.onChangeContent. Please pick one.');
      }
      if (widget.onChanged != null) {
        _controller.callbacks!.onChangeContent = widget.onChanged;
      }
    }
  }
}