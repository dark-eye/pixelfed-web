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

Item {
   id:_cachedHttpReq

   signal requestStarted(var request, var id);
   signal responseDataUpdated(var response, var id);
   signal requestError(var error, var errorResults, var id);

   property var url: null
   property var postData: null
   property var getData: null
   property bool isResultJSON: true

   function send(id) {
		//check DB if theres old
			// If so send  resultsUpdated withthe stored getData
		// Send request to the configured URL
		var http = new XMLHttpRequest();
		var requestURL = url +
						 (getData ? "?" + _internal.mapJsonToRequest(getData) : "");
		console.log("CachedHttpRequest request URL:"+requestURL);
 		http.open("GET", requestURL, true);
 		http.setRequestHeader('Content-type', 'text/html; charset=utf-8')
			http.onreadystatechange = function() {
				if (http.readyState === XMLHttpRequest.DONE) {
					//console.log(http.responseText);
					try {
						if(_cachedHttpReq.isResultJSON) {
							var response = JSON.parse(http.responseText);
							if(response) {
								responseDataUpdated(response, id);
							}
						} else {
							resultsUpdated(http.responseText, id);
						}
					} catch (error) {
						requestError(error, http.responseText, id);
					}
				}
			}
			http.onerror = function(event) {
				requestError(event,http.responseText, id);
			}

			//Send Request
 			http.send();
 			requestStarted(http.request,id)
			// On returned results fire resultsUpdated
				// Update DB with the new results and add the current timestamp to it
			// On Error send requestError signal
   }

   QtObject {
	   id:_internal

	   function mapJsonToRequest(json) {
		    var retStr="";
			for(var i in json) {
				if(typeof(json[i]) == "object") {
					retStr += i + "[]" + _internal.mapJsonToRequest(json[i]);
				} else {
					retStr += i + "=" + json[i];
				}
				retStr += "&";
			}

			return retStr;
	   }
   }
}
