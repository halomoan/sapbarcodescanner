import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoKeyboardEditableText extends EditableText {
  NoKeyboardEditableText(
      {@required TextEditingController controller,
      TextStyle style = const TextStyle(),
      Color cursorColor = Colors.black,
      bool autofocus = true,
      Color selectionColor})
      : super(
            controller: controller,
            focusNode: NoKeyboardEditableTextFocusNode(),
            style: style,
            cursorColor: cursorColor,
            autofocus: autofocus,
            showCursor: false,
            selectionColor: selectionColor,
            backgroundCursorColor: Colors.white);

  @override
  EditableTextState createState() {
    return NoKeyboardEditableTextState();
  }
}

class NoKeyboardEditableTextState extends EditableTextState {
  @override
  Widget build(BuildContext context) {
    Widget widget = super.build(context);
    return Container(
      decoration:
          UnderlineTabIndicator(borderSide: BorderSide(color: Colors.blueGrey)),
      child: widget,
    );
  }

  @override
  void requestKeyboard() {
    super.requestKeyboard();
    //hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}

class NoKeyboardEditableTextFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    // prevents keyboard from showing on first focus
    return false;
  }
}
