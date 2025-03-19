
WorkerScript.onMessage =  function(message) {
	var list = message.inData;
	var retList = [];
	for(var i in list) {
		if(message.onlyReg && list[i].open_registration != message.onlyReg ) {
			continue;
		}
		if(message.searchTerm == "" || list[i].domain && list[i].domain.match(new RegExp(message.searchTerm,'i'))
			|| list[i].location.city && list[i].location.city.match(new RegExp(message.searchTerm,'i'))
			|| list[i].description && list[i].description.match(new RegExp(message.searchTerm,'i'))
		|| list[i].location.country && list[i].location.country.match(new RegExp(message.searchTerm,'i')))
		{
			retList.push(list[i]);
		}
	}
	 var results = retList;
	 WorkerScript.sendMessage({reply: results});
}

 
 
