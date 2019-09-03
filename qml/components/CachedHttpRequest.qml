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
import U1db 1.0 as U1db

Item {
   id:_cachedHttpReq

   signal requestStarted(var request, var id);
   signal responseDataUpdated(var response, var id);
   signal requestError(var error, var errorResults, var id);

   property var url: null
   property var postData: null
   property var getData: null
   property bool isResultJSON: true
   property int cachingTimeMiliSec: 3600000 // 1 hour
   property real recachingFactor: 0.95 // how much (percentage wise) of the caching time can pass before trying sending the response again.

   function send(id) {
	   var requestURL = url + (getData ? "?" + _internal.mapJsonToRequest(getData) : "");


		if(_internal.retriveFromCache(requestURL,id) < recachingFactor) {
			// we have the cached response no need to  query the server again
			return;
		}


		// Send request to the configured URL
		var http = new XMLHttpRequest();

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
								console.log("CachedHttpRequest: got response for: "+ requestURL +" , associated id : "+id);
								// Update DB with the new results and add the current timestamp to it
								var docId = cachedReqDbInstance.putDoc({"request":requestURL,"response": http.responseText,"timestamp":Date.now(),"isResultJSON":_cachedHttpReq.isResultJSON});
								console.log("CachedHttpRequest: cached response to  :"+docId);
								responseDataUpdated(response, id);
							}
						} else {
							console.log("CachedHttpRequest: got response for: "+ requestURL +" , associated id : "+id);
							// Update DB with the new results and add the current timestamp to it
							var docId = cachedReqDbInstance.putDoc({"request":requestURL,"response": http.responseText,"timestamp":Date.now(),"isResultJSON":_cachedHttpReq.isResultJSON});
							console.log("CachedHttpRequest: cached response to  :"+docId);
							// On returned results fire resultsUpdated
							resultsUpdated(http.responseText, id);
						}
					} catch (error) {
						console.log("CachedHttpRequest: got error when quering: "+ requestURL +" , associated id : "+id );
						requestError(error, http.responseText, id);
					}
				}
			}

			// On Error send requestError signal
			http.onerror = function(event) {
				requestError(event,http.responseText, id);
			}

			//Send Request
 			http.send();
			//update the  sending app that  we are queiring for the request
 			requestStarted(http.request,id)
   }

	//---------------------------------------------------

	U1db.Database {
		id:cachedReqDbInstance
		path: "cached-requests-db"
	}

	U1db.Index {
		id:requestIndex
		database:cachedReqDbInstance
			name:"requestIndex"
			expression: [ "request" ]
		}
	U1db.Query {
		id:getPreviousResponses
		index: requestIndex
		query: ["*"]
	}

	//---------------------------------------------------

	QtObject {
	   id:_internal

		// check if we allread have a response to a give request/query in the cache and send an update if we have it.
	   function retriveFromCache(requestURL, id) {
			//check DB if theres a cache response for the requested URL
		   console.log(requestURL)
			getPreviousResponses.query = [ requestURL ]
			if(getPreviousResponses.results.length) {
				for(var i in getPreviousResponses.documents) {
					var prvResponse = cachedReqDbInstance.getDoc(getPreviousResponses.documents[i]);
					var howOld = Date.now() - prvResponse.timestamp;
					console.log(cachingTimeMiliSec, howOld)
					if( cachingTimeMiliSec > howOld ) {
						// If so send  resultsUpdated withthe stored getData
						console.log("CachedHttpRequest: Loading response for: "+ requestURL +" from cache" );
						var response = prvResponse.isResultJSON ? JSON.parse(prvResponse.response) : prvResponse.response;
						_cachedHttpReq.responseDataUpdated(response,id);
						return howOld/cachingTimeMiliSec;
					} else {
						//If the response if too old delete it
						console.log("CachedHttpRequest: Timestamp too old : "+  prvResponse.timestamp +" to load from cache" );
						cachedReqDbInstance.deleteDoc(getPreviousResponses.documents[i]);
					}
				}
			}
			return 1;
	   }

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
