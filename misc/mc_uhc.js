#!/usr/bin/env node
var exec = require('child_process');
var interval = null;
var gameRunning = false;
var count = 0;
var deadPlayers = {};
var shortlog = [];

var mc_process = exec.spawn(
	'java',
	['-Xms2048M', '-Xmx2048M', '-jar', 'minecraft_server.jar', 'nogui'],
	{ cwd: process.cwd() }
);

mc_process.stdout.setEncoding('utf8');
mc_process.stderr.setEncoding('utf8');

mc_process.stdout.on('data', function(data) {
	data = data.replace(/\n|\r/g, '');
	data = data.replace(/§./g, '');
	var message = data.split(' ').slice(3).join(' ');
	if (message.match('!start') !== null) {
		if (!gameRunning) {
			gameRunning = true;
			deadPlayers = {};
			shortlog = [];
			interval = setInterval(function () {
				count++;
				mc_process.stdin.write('/tellraw @a {text:"'+20*count+' Minutes passed!", color:light_purple}\r');
			}, 1000*60*20);
			mc_process.stdin.write('/setworldspawn 0 256 0\r');
			mc_process.stdin.write('/spawnpoint @a 0 256 0\r');
			mc_process.stdin.write('/worldborder center 0 0\r');
			mc_process.stdin.write('/worldborder set 2000\r');
			mc_process.stdin.write('/scoreboard players reset @a\r');
			mc_process.stdin.write('/spreadplayers 0 0 500 1000 true @a\r');
			mc_process.stdin.write('/gamemode 0 @a\r');
			mc_process.stdin.write('/clear @a\r');
			mc_process.stdin.write('/effect @a clear\r');
			mc_process.stdin.write('/effect @a minecraft:regeneration 10 255\r');
			mc_process.stdin.write('/effect @a minecraft:saturation 10 255\r');
			mc_process.stdin.write('/tellraw @a {text:"Started", color:light_purple}\r');
		}
	}
	if (message.match('!stop') !== null) {
		if (gameRunning) {
			gameRunning = false;
			mc_process.stdin.write('/tp @a 0 256 0\r');
			mc_process.stdin.write('/gamemode 0 @a\r');
			mc_process.stdin.write('/effect @a minecraft:resistance 60 5\r');
			mc_process.stdin.write('/tellraw @a {text:"Stopped", color:light_purple}\r');
			clearInterval(interval);
			interval = null;
			count = 0;
		}
	}
	if (message.match('fell from a high place') !== null) {
		if (gameRunning) {
			var name = message.split(' ')[0];
			var deathReason = 'fell from a high place';
			mc_process.stdin.write('/spawnpoint '+name+' 0 0 0\r');
			mc_process.stdin.write('/gamemode 3 '+name+'\r');
			for (var logEntry in shortlog) {
				if (shortlog[logEntry].match(name) &&
				shortlog[logEntry].match(/<|>/) === null) {
					deathReason = shortlog[logEntry];
				}
			}
			deadPlayers[name] = deathReason;
		}
	}
	if (message.match('!deaths') !== null) {
		for (var deadPlayer in deadPlayers) {
			mc_process.stdin.write('/tellraw @a {text:"'+deadPlayer+', info: '+deadPlayers[deadPlayer]+'", color:dark_red}\r');
		}
	}
	if (gameRunning) {
		shortlog = shortlog.slice(1);
		shortlog.push(data);
	}
	console.log(data);
});

mc_process.stderr.on('data', function(data) {
	console.log('Error: '+data);
});

mc_process.on('exit', function(data) {
	mc_process = null;
	console.log('server stopped');
	process.exit(0);
});
