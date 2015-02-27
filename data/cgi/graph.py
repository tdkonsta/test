#!/usr/bin/env python

import os
import re

print "Content-type: text/html"

print """
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
  <html>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.6.0/jquery.min.js"></script>
    <script src="../js/javascriptrrd.wlibs.js" language="javascript"></script>
    <body>
      <form>
        <select id="graphs" name="graph"></select>
      </form>

      <div id="mygraph"></div>
 
    </body>
    <script>
      var rrdFiles=[];
"""

for root, subFolders, files in os.walk(".",topdown=True):
  for file in files:
    if re.search('rrd',file):
      print "rrdFiles.push('"+root+"/"+file+"');"

print """
      var desc = {};
      rrdFiles.forEach(function(file){
	var parts = file.split("/");	
	var d = parts[1] + " " + parts[2];

	if(parts[3] && /\-/.test(parts[3])){
	        d+=" "+parts[3].split("-")[0];
	        if(!desc[d]){ 
 			desc[d]=[];
	 	}

		name = parts[3].split("-")[1].replace(".rrd","");;
		
		desc[d].push([name,"../"+file]);

	} else if(parts[3]) {

	        if(!desc[d]){ 
 			desc[d]=[];
	 	} 
	

		name = parts[3].replace(".rrd","");
		desc[d].push([name,"../"+file]);
	}
      }); 


      Object.keys(desc).forEach(function(file){
        $("#graphs").append("<option value='"+file+"'>"+file+"</option>");
      }); 

      var load=function(){
        var graph  =($('#graphs').find(":selected").text());
	if(desc[graph].length>1){
	        flot = new rrdFlotMatrixAsync("mygraph",desc[graph]);
	} else {
	        flot = new rrdFlotAsync("mygraph",desc[graph][0][1]);
	}
      }

      $("#graphs").change(function(){
	load();
      });



    </script>
  </html>
""" 
