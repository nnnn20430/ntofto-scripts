#!/usr/bin/env node

/*jshint node: true*/
/*jshint evil: true*/
/*jshint loopfunc: true */

"use strict";
//variables
var https = require('https');
var fs = require('fs');
var url = require('url');

var page = 1;
var clone_script = '';
var running = true;

clone_script += '#!/bin/bash\n';

function getGithubLinks() {
	var request_data = url.parse('https://api.github.com/users/w3c/repos?page='+page);
	request_data.headers = {'User-Agent': 'nnnn20430'};
	https.get(request_data, function(res) {
		console.log('Starting on page: '+page);
		var data = '';
		res.setEncoding('utf8');
		res.on('data', function (chunk) {data += chunk;});
		res.on('end', function () {
			var parsedData = '';
			try {
				parsedData = JSON.parse(data);
			} catch (e) {
				console.log('Error parsing json: '+e);
			}
			if (parsedData.length) {
				page++;
				for (var repo in parsedData) {
					console.log('Adding: '+parsedData[repo].git_url);
					clone_script += 'git clone --bare '+parsedData[repo].git_url+'\n';
				}
				getGithubLinks();
			} else {
				fs.writeFile('github_clone_links.sh', clone_script, {encoding: 'utf8', mode: 502}, function (err) {
					if (err) throw err;
					console.log('written to github_clone_links.sh');
				});
			}
		});
	}).on('error', function(e) {console.log('Error:'+e.message);});	
}

getGithubLinks();
