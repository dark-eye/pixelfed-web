import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0

import "components"
import "pages"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'pixelfed-web.darkeye'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    readonly property var version: "0.1.0"

    property var token: "4r45tg"

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    PageStack {
        id: mainStack
    }

    Settings {
        id: appSettings
        property var instance
        property bool openLinksExternally: false
        property bool incognitoMode: false
        property bool hideBottomControls: false
    }

    QtObject {
		id:helperFunctions
		
		function getInstanceURL() {
			return appSettings.instance.indexOf("http") != -1 ? appSettings.instance : "https://" + appSettings.instance
		}
	}

    Component.onCompleted: {
        if ( appSettings.instance ) {
           mainStack.push(Qt.resolvedUrl("./pages/PixelFedWebview.qml"))
        } else {
           mainStack.push(Qt.resolvedUrl("./pages/InstancePicker.qml"))
        }
    }
}
