var noble = require('noble'), osc = require('node-osc');
var myBlunos = {};
var oscPort = 28000, oscIP = '127.0.0.1';
var client = new osc.Client(oscIP, oscPort), oscServer = new osc.Server(28001, oscIP);
var neutralChoosing = 90;
var playing = true;

oscServer.on("message", function (msg, rinfo) {
	console.log('OSC message:');
	console.log(msg);
	var route = msg[0];
	switch(route) {
		case '/setColor':
			getBlunoFromCode(msg[1]).characteristic.write(new Buffer([msg[2]]),false);
			break;
		case '/endRound':
			getBlunoFromCode(msg[1]).characteristic.write(new Buffer([100]),false);
			getBlunoFromCode(msg[2]).characteristic.write(new Buffer([101]),false);
			break;
		case '/endTime':
			for(var key in myBlunos) {
				myBlunos[key].characteristic.write(new Buffer([neutralChoosing]),false);
			}
			break;
		case '/reset':
			for(var key in myBlunos) {
				if (myBlunos[key].characteristic){
					myBlunos[key].code = null;
					myBlunos[key].characteristic.write(new Buffer([200]),false);
				}
			}
			break;
		case '/quit':
			playing = false;
			for(var key in myBlunos) {
				if (myBlunos[key].characteristic){
					myBlunos[key].characteristic.write(new Buffer([201]),false);
					setTimeout(function(p){return function(){
						p.disconnect();}
					}(myBlunos[key].peripheral),1000);
				}
			}
			setTimeout(process.exit, 2000);
			break;
		case '/connect':
			console.log(myBlunos.length);
			for(var key in myBlunos) {
				myBlunos[key].peripheral.disconnect();
			}
			break;
		default:
			break;
	}
});

noble.on('stateChange', function(state) {
  if (state === 'poweredOn') {
    noble.startScanning();
  } else {
    noble.stopScanning();
  }
});

noble.on('discover', function(peripheral) {
  if(peripheral.advertisement.localName == 'DFBLUnoV1.6') {
  	myBlunos[peripheral.uuid] = myBlunos[peripheral.uuid] || {peripheral : peripheral, connected: false};
  	console.log('bluno found');
	peripheral.on('disconnect', function(error){
		myBlunos[peripheral.uuid].connected = false;
		console.log('disconnected peripheral: '+peripheral.uuid);
		if(playing) connectPeripheral(peripheral);
	});
  	connectPeripheral(peripheral);
	setTimeout(function(){
		if(!myBlunos[peripheral.uuid].connected) {
			peripheral.disconnect();
		}
	},2000);
  }
});

function connectPeripheral(peripheral) {
	console.log('trying to connect to: '+peripheral.uuid);
	peripheral.connect(function(error) {
		console.log(error);
		myBlunos[peripheral.uuid].connected = true;
		console.log('connected peripheral: '+peripheral.uuid);
		peripheral.discoverSomeServicesAndCharacteristics([], ['dfb1'], function(error, services, characteristics){
			if(characteristics.length > 0) {
				var characteristic = characteristics[0];
				characteristic.notify(true);
				myBlunos[peripheral.uuid].characteristic = characteristic;
				console.log('characteristic');
				characteristic.write(new Buffer([200]),false);
				//var buffer = new Buffer([5]);
				//characteristic.write(buffer, false);
				characteristic.on('read', function(data, isNotification) {
					var code = data.readUInt8(0);
					if(code >= 100 && code < 200) { //contact
						var myCode = myBlunos[peripheral.uuid].code;
						if(!myCode) {
							//we didn't have a code, this means this will be ours
							myBlunos[peripheral.uuid].code = code;
							myBlunos[peripheral.uuid].characteristic.write(new Buffer([neutralChoosing]),false);
							client.send('/newPlayer', code);
							console.log('player joined: '+code);
						} else if(code != myCode) {
							//we had a code, let's check it's not us and game has started
							client.send('/playerTouch', myCode, code);
							console.log('player '+myCode+' touched by '+code);
						}
					} else if(code >= 200 && code < 203) {
						var myCode = myBlunos[peripheral.uuid].code;
						if(myCode) client.send('/playerElement', myCode, code);
					}
					console.log('received message: '+code);
					/*
					client.send('/newPlayer', 0);
					console.log('received data: '+ data.readUInt8(0));
					*/
				});
			}
		});
	});
}

function getBlunoFromCode(code) {
	for(var key in myBlunos) {
		var elem = myBlunos[key];
		if(elem.code === code) return elem;
	}
	return null;
}

console.log('run');