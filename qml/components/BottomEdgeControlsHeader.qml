/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright 2018  eran <email>
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

PageHeader {
		id:_headersControls
		
		property var trailingSlots: !webviewPage.isOnMainSite() ? 4 : 3
		property var callOnAction: null

		StyleHints {
			backgroundColor: settings.incognitoMode ? UbuntuColors.purple : theme.palette.normal.background
		}
		

		function callbackOnAction(actionNnme) {
			if(callOnAction) {
				callOnAction(actionNnme)
			}
		}

		trailingActionBar {
			numberOfSlots: trailingSlots
			
			actions:[
				Action {
					text:i18n.tr("Go home")
					iconName:"home"
					onTriggered: {
						webviewPage.currentView().goHome();
						//_headersControls.callbackOnAction("home");
					}
					visible:!webviewPage.isOnMainSite()
				},
				Action {
					text:i18n.tr("Reload")
					iconName:"reload"
					onTriggered: {
						webviewPage.currentView().reload();
						//_headersControls.callbackOnAction("reload");
					}
				},
				Action {
					text:i18n.tr("Go Back")
					iconName:"back"
					enabled:webviewPage.currentView().canGoBack
					onTriggered: {
						webviewPage.currentView().goBack()
						//_headersControls.callbackOnAction("back");
					}
				},
				//-------------------------------------------------------------
				Action {
					text: i18n.tr("Info")
					iconName: "info"
					onTriggered: {
						mainStack.push(Qt.resolvedUrl("../pages/Information.qml"))
						_headersControls.callbackOnAction("info");
					}
				},
				Action {
					text: checked ? i18n.tr("Links open externally") : i18n.tr("Links open internally")
					iconName:checked ? "external-link" : "stock_link"
					checkable:true
					checked: settings.openLinksExternally
					onToggled:{
						settings.openLinksExternally = checked;
						_headersControls.callbackOnAction("external-links");
					}
				},
// 				Action {
// 					text: checked ? i18n.tr("Show Bottom Controls") : i18n.tr("Hide Bottom Controls")
// 					iconName:checked ? "select" : "select-undefined"
// 					checkable:true
// 					checked: settings.hideBottomControls
// 					onToggled:{
// 						settings.hideBottomControls = checked;
// 					}
// 				},
				Action {
					text:i18n.tr("Change Node")
					iconName:"swap"
					onTriggered: {
						settings.instance = undefined
						mainStack.clear();
						mainStack.push (Qt.resolvedUrl("../pages/InstancePicker.qml"))

					}	
				}
			]
		}
	}
