/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  eran <email>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
//import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3


Item {
	id:loadingPage

	signal reloadButtonPressed()

	property bool hasLoadError: false
	property alias progressBar: _progressBar

    Rectangle {

		anchors.fill: parent
		color: theme.palette.normal.background

		onVisibleChanged: if(visible) {
			reloadButton.visible = false;
		}

		Timer {
			interval: 5000
			running: visible
			onTriggered: {
				reloadButton.visible = true;
			}
		}


		Label {
			id: progressLabel
			color: theme.palette.normal.backgroundText
			text: i18n.tr('Loading ') + appSettings.instance
			anchors.centerIn: parent
			textSize: Label.XLarge
		}

		ProgressBar {
			id: _progressBar
			value: 0
			indeterminate: value == 0
			minimumValue: 0
			maximumValue: 100
			anchors.top: progressLabel.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.topMargin: 10
			StyleHints {
				foregroundColor: loadingPage.hasLoadError ?
									theme.palette.normal.negative :
									theme.palette.normal.progress
			}
		}

		Button {
			id:reloadButton
			visible: loadingPage.hasLoadError
			anchors.top: _progressBar.bottom
			anchors.topMargin: units.gu(2)
			anchors.horizontalCenter: parent.horizontalCenter
			color: loadingPage.hasLoadError ? theme.palette.normal.negative : theme.palette.normal.focus
			width:height + units.gu(1)
			iconName:"reload"
			onClicked: {
				reloadButtonPressed();
			}
		}

		Button {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: height

			anchors.horizontalCenter: parent.horizontalCenter
			width:Math.min(parent.width*0.66,units.gu(28))
			color: UbuntuColors.orange
			text: "Choose another Instance"
			iconPosition:"left"
			iconName:"swap"
			onClicked: {
				appSettings.instance = undefined
				mainStack.clear ()
				mainStack.push (Qt.resolvedUrl("./InstancePicker.qml"))
			}
		}
	}
}
