import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "mcwehner.pcalc"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function toggleOverlay() {
    if (root.bar && root.bar.shell && typeof root.bar.shell.toggle === "function")
      root.bar.shell.toggle(root.moduleName)
    else if (root.bar)
      root.bar.run("omarchy-shell shell toggle " + root.moduleName)
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf1ec"
    tooltipText: "Programmer calculator"
    onPressed: root.toggleOverlay()
  }
}
