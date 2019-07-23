
import QtQml 2.2
import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0

import "../components"
import "../components/dialogs"

Page {
	id: webviewPage
	width: parent.width
	height: parent.height

	header:Item {
		height: 0
		visible: false
	}
	
	Component {
		id: pickerComponent
		PickerDialog {}
	}
	
	Item {
		id:webContainer
		anchors {
			top:parent.top
			left:parent.left
			right:parent.right
			bottom:parent.bottom
			bottomMargin: instancBottomEdge.hint.status == BottomEdgeHint.Locked ? units.gu(4) : 0;
		}
		MainWebView {
			id:webView
			url: helperFunctions.getInstanceURL()
			filePicker: pickerComponent
			confirmDialog: ConfirmDialog {}
			alertDialog: AlertDialog {}
			promptDialog:PromptDialog {}
			z: settings.incognitoMode ? -1 : 1
			onLoadProgressChanged: {
				loadingPage.progressBar.value = loadProgress
			}
			settings.showScrollBars:false
		}
	}

	LoadingPage {
		id:loadingPage
		anchors.fill: parent

		hasLoadError:  ( typeof(webviewPage.currentView()) !== 'undefined' && !webviewPage.currentView().loading && webviewPage.currentView().lastStatus == WebEngineView.LoadFailedStatus )

		visible: opacity != 0
		opacity: !webviewPage.currentView().isLoaded ? 1 : 0
		Behavior on opacity { NumberAnimation { duration:UbuntuAnimation.BriskDuration} }

		onReloadButtonPressed: webviewPage.currentView().reload();
	}
	
	Rectangle {
		color: theme.palette.highlighted.selectedText
		anchors.bottom:instancBottomEdge.status !== BottomEdge.Committed ? parent.bottom : instancBottomEdge.top
		anchors.bottomMargin: 1
		width: parent.width * webviewPage.currentView().loadProgress / 100
		height: units.gu(0.1)
		visible: webviewPage.currentView().visible && webviewPage.currentView().loading
		z:2
		layer.enabled: true
		layer.effect:DropShadow {
			 radius: 5
			 color:theme.palette.highlighted.selected
		}
	}

	InverseMouseArea {
		anchors {
			bottom:parent.bottom
			left:parent.left
			right:parent.right
		}
		height:units.gu(25)
		enabled:instancBottomEdge.status != BottomEdge.Hidden
		visible:enabled
		topmostItem:true
		onClicked:instancBottomEdge.collapse();
	}
	Rectangle {
		anchors {
			fill:parent
		}
		visible: opacity != 0
		color:theme.palette.normal.overlay
		opacity: instancBottomEdge.status != BottomEdge.Hidden ? 0.33 : 0
		Behavior on opacity { NumberAnimation { duration:UbuntuAnimation.BriskDuration} }
	}

	BottomEdge {
		id: instancBottomEdge
		visible: webviewPage.currentView().visible  && webviewPage.isOnMainSite()
		height:units.gu(7)
		hint.iconName: "go-up"
		hint.visible:visible
 		hint.deactivateTimeout:10
		preloadContent: true
		hint.opacity:  instancBottomEdge.hint.status != BottomEdgeHint.Inactive ? 1 : 0.1
		contentComponent: Component {
			BottomEdgeControlsHeader {
				anchors.fill:instancBottomEdge
				height:instancBottomEdge.height
				width:instancBottomEdge.width
				leadingActionBar {
					actions:[
						Action {
							iconName:"down"
							onTriggered:instancBottomEdge.collapse()
						}
					]
				}
				callOnAction: function(actionName) {
					instancBottomEdge.collapse();
				}
			}
		}
	}
	
	//========================== Functions =======================
	function currentView() {
		return webView;
	}
	
	function  isOnMainSite() {
		return (currentView().url.toString().indexOf(settings.instance) !== -1)
	}
	
	function isLoggedin() {
		var loginPage = helperFunctions.getInstanceURL() + "/users/sign_in"
		return currentView().url != loginPage;
	}

}
