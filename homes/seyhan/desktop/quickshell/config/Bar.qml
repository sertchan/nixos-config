import Quickshell
import QtQuick

PanelWindow {

  id: root

  implicitWidth: width
  implicitHeight: 36
  
  anchors {
    top: true
    left: true
    right: true
  }

  Text {

    text: "Something"
    font {
      pixelSize: 12

    }
    anchors {
      centerIn: parent
    }
  }
}
