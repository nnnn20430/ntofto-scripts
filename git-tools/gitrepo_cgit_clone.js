#!/usr/bin/env node

/*jshint node: true*/
/*jshint evil: true*/
/*jshint loopfunc: true */

"use strict";
//variables
var http = require('http');
var https = require('https');
var fs = require('fs');
var url = require('url');
var exec = require('child_process').exec;
var path = require('path');

var repo_url = '';
var index_url = '';
var target_dir = '';
var trimtop = '';

process.argv.forEach(function(val, index, array) {
	if (val == '-r' || val == '--repo') {//git url to clone from
		repo_url = array[index+1].charAt(0)!='-'?array[index+1]:'';
	}
	if (val == '-i' || val == '--index') {//cgit repo url for index
		index_url = array[index+1].charAt(0)!='-'?array[index+1]:'';
	}
	if (val == '-d' || val == '--dir') {//target cloning directory
		target_dir = array[index+1].charAt(0)!='-'?array[index+1]:'';
	}
	if (val == '-t' || val == '--trimtop') {//trim top dir when cloning
		trimtop = array[index+1].charAt(0)!='-'?array[index+1]:'';
	}
});

function getRepoIndex(repo_url, callback) {
	var request_data = url.parse(repo_url);
	var repo_index = [];
	var protocol = request_data.protocol == 'http:' ? http : https;
	protocol.get(request_data, function(res) {
		var data = '';
		res.setEncoding('utf8');
		res.on('data', function (chunk) {data += chunk;});
		res.on('end', function () {
			var lines = data.split('\n');
			var repo;
			for (var line in lines) {
				if (lines[line].indexOf('-repo') != -1) {
					repo = lines[line].split('</td>');
					while (repo[0] &&
					repo[0].indexOf('reposection') != -1) {
						repo = repo.slice(1);
					}
					repo=repo[0].split("'");
					if (repo[1] == 'toplevel-repo' ||
					repo[1] == 'sublevel-repo') {
						if (repo[4] == ' href=') {
							repo_index = repo_index.concat([repo[5]]);
						}
					}
					
				}
			}
			if (callback !== undefined) {callback(repo_index);}
		});
	});
}

//https://github.com/substack/node-mkdirp
var mkdirPSync = function sync (p, opts, made) {
	if (!opts || typeof opts !== 'object') {
		opts = { mode: opts };
	}
	
	var mode = opts.mode;
	var xfs = opts.fs || fs;
	
	if (mode === undefined) {
		mode = parseInt('0777', 8) & (~process.umask());
	}
	if (!made) made = null;
	
	p = path.resolve(p);
	
	try {
		xfs.mkdirSync(p, mode);
		made = made || p;
	}
	catch (err0) {
		switch (err0.code) {
			case 'ENOENT' :
				made = sync(path.dirname(p), opts, made);
				sync(p, opts, made);
				break;
			
			// In the case of any other error, just see if there's a dir
			// there already.  If so, then hooray!  If not, then something
			// is borked.
			default:
				var stat;
				try {
					stat = xfs.statSync(p);
				}
				catch (err1) {
					throw err0;
				}
				if (!stat.isDirectory()) throw err0;
				break;
		}
	}
	
	return made;
};

function gitCloneRepositories(repoArr) {
	var absolute_dest_path = path.resolve(target_dir);
	function gitClone(index) {
		if (repoArr[index]) {
			var repo_path = repoArr[index].indexOf(trimtop)==0?repoArr[index].substr(trimtop.length):repoArr[index];
			var clone_url = url.resolve(repo_url, repo_path);
			var absolute_repo_path = absolute_dest_path+path.resolve('/', repo_path, '..');
			console.log('Cloning '+clone_url);
			mkdirPSync(absolute_repo_path);
			exec('git clone --bare '+clone_url, {
					cwd: absolute_repo_path,
					env: {
						GIT_TERMINAL_PROMPT: 0,
						GIT_ASKPASS: 'true'
					}
					timeout: 0,
					maxBuffer: 5*1024*1024
				}, function (error, stdout, stderr) {
					if (error !== null) {
						console.log('Failed');
					}
					gitClone(index+1);
				}
			);
		}
	}
	gitClone(0);
}

if (!repo_url || !index_url || !target_dir) {
	console.log("Specify the git clone url, cgit repo index url and destination directory");
	console.log("Example: $ script.js -r 'git://example.tld/' -i 'http://cgit.example.tld/cgit/' -d '/destination/dir' -t '/cgit/'");
} else {
	console.log('Getting index...');
	getRepoIndex(index_url, function (repoArr) {
		gitCloneRepositories(repoArr);
	});
}
