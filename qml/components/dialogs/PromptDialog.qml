/*
* <one line to give the program's name and a brief idea of what it does.>
* Copyright (C) 2018  eran <email>
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3 as Popups

Popups.Dialog {
	id: _dialog
	title: i18n.tr("Prompt Action")
	text:model.message
	
	TextField {
		id: input
		objectName: "inputTextField"
		text: model.defaultValue
		onAccepted: model.accept(input.text)
	}
	
	Button {
		text: "Accept"
		onClicked: {
			model.accept(input.text);
		}
	}
	Button {
		text: "Reject"
		onClicked: {
			model.reject();
		}
	}

	Component.onCompleted: show()
	
	Binding {
		target: model
		property: "currentValue"
		value: input.text
	}
}
