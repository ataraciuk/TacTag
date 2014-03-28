var noble = require('noble'), osc = require('node-osc');

var myBlunos = {};

var client = new osc.Client('127.0.0.1', 28000);

noble.on('stateChange', function(state) {
  if (state === 'poweredOn') {
    noble.startScanning();
  } else {
    noble.stopScanning();
  }
});

noble.on('discover', function(peripheral) {
  if(peripheral.advertisement.localName == 'DFBLUnoV1.6') {
  	myBlunos[peripheral.uuid] = {peripheral : peripheral};
  	console.log('bluno found');
	peripheral.connect(function(error) {
		peripheral.discoverSomeServicesAndCharacteristics([], ['dfb1'], function(error, services, characteristics){
			if(characteristics.length > 0) {
				var characteristic = characteristics[0];
				characteristic.notify(true);
				myBlunos[peripheral.uuid][characteristic] = characteristic;
				var buffer = new Buffer([5]);
				characteristic.write(buffer, false);
				characteristic.on('read', function(data, isNotification) {
					client.send('/newPlayer', 0);
					console.log('received data: '+ data.readUInt8(0));
				});
			}
		});
	});
  }
});