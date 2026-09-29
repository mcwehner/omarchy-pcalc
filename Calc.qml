import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property var result: ({})
  property int selectedFormat: 0
  property string evalExpr: ""
  property bool evalPending: false
  property bool evalStopping: false
  readonly property string pcalcPath: decodeURIComponent(String(Qt.resolvedUrl("bin/pcalc")).replace(/^file:\/\//, ""))

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property int contentMargin: Style.spacing.panelPadding
  property string fontFamily: Style.font.menuFamily
  property int cardWidth: Math.min(Style.space(420), panel.width - Style.gapsOut * 2)

  readonly property var formats: {
    var out = ["dec"]
    if (root.result && root.result.hex)
      out.push("hex")
    if (root.result && root.result.bin)
      out.push("bin")
    return out
  }

  function open(payloadJson) {
    root.result = ({})
    root.selectedFormat = 0
    root.evalExpr = ""
    root.evalPending = false
    root.opened = true
    Qt.callLater(function() {
      if (inputField) {
        inputField.text = ""
        inputField.forceActiveFocus()
      }
    })
  }

  function close() {
    root.opened = false
    if (evalProc.running) {
      root.evalStopping = true
      evalProc.running = false
    }
  }

  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "mcwehner.pcalc")
  }

  function toggle() {
    if (root.opened)
      root.dismiss()
    else
      root.open("{}")
  }

  function selectedKey() {
    var list = root.formats
    if (list.length === 0)
      return "dec"
    var index = root.selectedFormat
    if (index < 0 || index >= list.length)
      return list[0]
    return list[index]
  }

  function selectedValue() {
    var key = root.selectedKey()
    if (!root.result || !root.result[key])
      return ""
    return String(root.result[key])
  }

  function cycleFormat(direction) {
    var list = root.formats
    if (list.length < 2)
      return
    var next = root.selectedFormat + direction
    if (next < 0)
      next = list.length - 1
    else if (next >= list.length)
      next = 0
    root.selectedFormat = next
  }

  function copyToClipboard(value) {
    if (!value)
      return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(value) + " | wl-copy"])
  }

  function copyAndDismiss() {
    var expr = inputField.text.trim()
    if (!expr) {
      root.dismiss()
      return
    }
    var value = root.selectedValue()
    if (!value)
      return
    root.copyToClipboard(value)
    root.dismiss()
  }

  function scheduleEval() {
    debounce.restart()
  }

  function startEval() {
    var expr = inputField ? inputField.text.trim() : ""
    if (!expr) {
      root.result = ({})
      root.selectedFormat = 0
      root.evalExpr = ""
      return
    }
    root.evalExpr = expr
    if (evalProc.running) {
      root.evalPending = true
      root.evalStopping = true
      evalProc.running = false
      return
    }
    root.evalStopping = false
    evalProc.running = true
  }

  function applyOutput(raw) {
    if (root.evalStopping || !root.opened)
      return
    var text = String(raw || "").trim()
    if (!text)
      return
    try {
      var parsed = JSON.parse(text)
    } catch (e) {
      return
    }
    if (!parsed || !parsed.ok)
      return
    root.result = parsed
    if (root.selectedFormat >= root.formats.length)
      root.selectedFormat = 0
  }

  Timer {
    id: debounce
    interval: 50
    repeat: false
    onTriggered: root.startEval()
  }

  Process {
    id: evalProc
    command: ["python3", root.pcalcPath, "--json", "--", root.evalExpr]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyOutput(text)
    }
    onExited: function(exitCode) {
      if (root.evalPending) {
        root.evalPending = false
        Qt.callLater(root.startEval)
      }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    color: "transparent"
    WlrLayershell.namespace: "mcwehner-pcalc"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: content.implicitHeight + contentTopInset + contentBottomInset
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea {
        anchors.fill: parent
        onClicked: {}
      }

      Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: card.contentTopInset
        anchors.leftMargin: card.contentLeftInset
        anchors.rightMargin: card.contentRightInset
        spacing: Style.spacing.lg

        TextField {
          id: inputField
          width: parent.width
          placeholderText: "expression"
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          foreground: root.foreground
          onTextChanged: root.scheduleEval()
          onAccepted: root.copyAndDismiss()
          Keys.onEscapePressed: root.dismiss()
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
              root.cycleFormat((event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab ? -1 : 1)
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              root.cycleFormat(1)
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              root.cycleFormat(-1)
              event.accepted = true
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.spacing.xs
          visible: !!(root.result && root.result.dec)

          Repeater {
            model: root.formats
            Rectangle {
              required property string modelData
              required property int index
              width: parent.width
              height: rowText.implicitHeight + Style.spacing.sm * 2
              radius: Math.min(4, root.cornerRadius)
              color: index === root.selectedFormat ? root.selectedBackground : "transparent"

              Text {
                id: rowText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Style.spacing.sm
                anchors.rightMargin: Style.spacing.sm
                textFormat: Text.PlainText
                text: root.result && root.result[modelData] ? String(root.result[modelData]) : ""
                color: index === root.selectedFormat ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                elide: Text.ElideRight
              }

              MouseArea {
                anchors.fill: parent
                onClicked: {
                  root.selectedFormat = index
                  root.copyToClipboard(String(root.result[modelData] || ""))
                }
              }
            }
          }
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: "enter copy · tab cycle · esc"
          color: root.foreground
          opacity: 0.58
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
