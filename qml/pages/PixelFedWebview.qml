
import QtQml 2.2
import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0
import QtWebEngine 1.7

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
	
	Flickable {
		id:webContainer
		anchors {
			top:parent.top
			left:parent.left
			right:parent.right
			bottom: parent.bottom
			bottomMargin: instancBottomEdge.hint.status == BottomEdgeHint.Locked  ? units.gu(6) : 0;
		}
		MainWebView {
			id:webView
			url: helperFunctions.getInstanceURL()
			filePicker: pickerComponent
			confirmDialog: ConfirmDialog {}
			alertDialog: AlertDialog {}
			promptDialog:PromptDialog {}
			onLoadProgressChanged: {
				loadingPage.progressBar.value = loadProgress
			}
			settings.showScrollBars:false

			onLoadingChanged: if(!loading && webviewPage.isOnMainSite()) {
				zoomFactor = units.gu(1) / 8
			}

			// Open external URL's in the browser and not in the app
			onNavigationRequested: {
// 				console.log ( Object.keys(request) )
				console.log ( request.url, ("" + request.url).indexOf ( appSettings.instance ) !== -1 )
				if ( ("" + request.url).indexOf ( appSettings.instance ) !== -1 || !appSettings.openLinksExternally ) {
					request.action = 0
				} else {
					request.action = 1
					Qt.openUrlExternally( request.url )
				}
			}

			onNewViewRequested: {
// 				console.log ( Object.keys(request) )
				request.action = 1
				if ( !appSettings.openLinksExternally ) {
					webView.url = request.requestedUrl
				} else {
					Qt.openUrlExternally( request.requestedUrl )
				}
			}

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
	

	ProgressBar {
			id: _bottomProgressBar
			z:2
			anchors.bottom:instancBottomEdge.status !== BottomEdge.Committed ? parent.bottom : instancBottomEdge.top
			anchors.bottomMargin: 1
			width: instancBottomEdge.width

			visible: webviewPage.currentView().visible && webviewPage.currentView().loading

			value:  webviewPage.currentView().loadProgress
			indeterminate: value == 0
			minimumValue: 0
			maximumValue: 100
			StyleHints {
				foregroundColor: loadingPage.hasLoadError ?
									theme.palette.normal.negative :
									theme.palette.normal.progress
			}
			layer.enabled: true
			layer.effect:DropShadow {
				radius: 5
				transparentBorder:true
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
		visible: webviewPage.currentView().visible
		height:units.gu(7)
		hint.iconName: "go-down"
		hint.visible:visible
 		hint.deactivateTimeout:10
		hint.flickable: webContainer
		preloadContent: true
		hint.text: i18n.tr('Navigation panel')
 		hint.opacity:  0.25
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
		return (currentView().url.toString().indexOf(appSettings.instance) !== -1)
	}
	
	function isLoggedin() {
		var loginPage = helperFunctions.getInstanceURL() + "/users/sign_in"
		return currentView().url != loginPage;
	}

}
