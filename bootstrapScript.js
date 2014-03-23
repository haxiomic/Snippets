//Bootstrap
(function(){
	function loadScript(url, callback){
	    var script = document.createElement("script");
	    script.type = "text/javascript";
	    if (script.readyState) /* IE Fix */ script.onreadystatechange = function(){
	            if (script.readyState == "loaded" || script.readyState == "complete"){
	            	script.onreadystatechange = null;
	                callback();
	            }
	        };
	    else script.onload = function(){callback();};
	    script.src = url;
	    document.getElementsByTagName("head")[0].appendChild(script);
	}

	//Entry Point
	loadScript("http://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js", function(){
		//do js
	});
})();