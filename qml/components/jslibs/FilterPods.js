
WorkerScript.onMessage =  function(message) {
	var list = message.inData;
	var retList = [];
	for(var i in list) {
		if(message.onlyReg && list[i].openSignups != message.onlyReg ) {
			continue;
		}
		if(message.searchTerm == "" || list[i].name && list[i].name.match(new RegExp(message.searchTerm,'i'))
			|| list[i].host && list[i].host.match(new RegExp(message.searchTerm,'i'))
		|| list[i].countryCode && list[i].countryCode.match(new RegExp(message.searchTerm,'i')))
		{
			retList.push(list[i]);
		}
	}
	 var results =retList;
	 WorkerScript.sendMessage({reply: results});
}

 
 
