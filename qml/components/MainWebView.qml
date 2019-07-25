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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0
import QtWebEngine 1.7

WebEngineView {
	id: webView
	width: parent.width
	height: parent.height
	visible: false
	property var lastStatus:WebEngineView.LoadSucceededStatus
	property var isLoaded: false
	property var  preferences : {}
	property bool fullscren: isFullScreen

	zoomFactor: units.gu(1) / 8

	profile:  mainWebProfile

	onLoadProgressChanged: {
		//visible |= !loading
	}

	onLoadingChanged:{
		lastStatus = loadRequest.status
		visible |= (lastStatus == WebEngineLoadRequest.LoadSucceededStatus && loadProgress == 100) && ( !loading )
		isLoaded |= !loading
	}
	anchors.fill: parent

	property var oldPropToNewMapping : {
		"preferences" : {
			"localStorageEnabled" : ["settings","localStorageEnabled"],
			"allowFileAccessFromFileUrls" : ["settings","localContentCanAccessFileUrls"],
			"allowUniversalAccessFromFileUrls" : ["settings","localContentCanAccessRemoteUrls"],
			"appCacheEnabled" :false,
			"javascriptCanAccessClipboard" : ["settings","javascriptCanAccessClipboard"],
			"shrinksStandaloneImagesToFit" : false
		}
	}
	onPreferencesChanged : {
		for(var key in preferences ) {
			if( propToSettMapping['preferences'][key] ) {
				settings[propToSettMapping[key]] = preferences[key];
			}
		}
	}

	property var  contextualActions: ActionList {
		Action {
			id: linkAction
			text: i18n.tr("Copy Link")
			enabled: webView.contextualData.href.toString()
			onTriggered: Clipboard.push([webView.contextualData.href])
		}

		Action {
			id: imageAction
			text: i18n.tr("Copy Image")
			enabled: webView.contextualData.img.toString()
			onTriggered: Clipboard.push([webView.contextualData.img])
		}

		Action {
			text: i18n.tr("Open in browser")
			enabled: webView.contextualData.href.toString()
			onTriggered: linkAction.enabled ? Qt.openUrlExternally( webView.contextualData.href ) : Qt.openUrlExternally( webView.contextualData.img )
		}
	}

	property var contextualMenu: ActionSelectionPopover {

	}

	Component.onCompleted: {
		contextualMenu.actions = contextualActions;
	}

	property var filePicker: null
	property var confirmDialog: null
	property var alertDialog: null
	property var promptDialog: null

	onJavaScriptDialogRequested: {
//  		switch(request.type)
//  			case Qt.JavaScriptDialogRequest.DialogTypeAlert
// 				request.accept = true;
	}

	onFileDialogRequested : if(filePicker) {
			request.accepted = true;
			var fakeModel = {
					allowMultipleFiles: request.mode == FileDialogRequest.FileModeOpenMultiple,
					reject: function() {
						request.dialogReject();
					},
					accept: function(files) {
							request.dialogAccept(files);
					}
			};
			var  pickerInstance = filePicker.createObject(webView,{model:fakeModel});
	}

	onContextMenuRequested: {
		request.accepted = true;
		contextualMenu.show();
	}

	onContextualActionsChanged: {
		contextualMenu.actions = contextualActions;
	}

	onQuotaRequested:{
		if(request.requestedSize < 2^24) {
			request.accept();
		} else  {
			request.reject();
		}

		return request.requestedSize < 2^24;

	}


	function goHome() {
		webView.url = helperFunctions.getInstanceURL();
	}
}
