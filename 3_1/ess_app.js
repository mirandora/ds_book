'use strict'
var app = require('http').createServer(handler),
 io = require('socket.io')(app),
 fs = require('fs'); 
var SPI = require('pi-spi');
var rpio = require('rpio');
var spawn = require('child_process').spawn;
const vision = require('node-cloud-vision-api');
vision.init({auth: '取得したAPIキー'}); 

var camera_image_url = '/images/raspi_camera.jpg';
var sensor_array = [];
var gcv_json_data;

var spi = SPI.initialize("/dev/spidev0.0"),
    MCP3002 = Buffer([1,(8+0) << 4, 0]);

setInterval(function(){
    spi.transfer(MCP3002,MCP3002.length,function(e,d){
        if(e) console.error(e);

        else{
			var val = ((((d[1] & 3) << 8) + d[2]) * 3.3 ) / 1023
			sensor_array.push(val);
        }
    });
},100);

app.listen(1337);

function handler(req,res){
	if(!req.url.indexOf(camera_image_url)){
		fs.readFile(__dirname + '/images/raspi_camera.jpg', 'binary', 
			function(err,data){
				res.writeHead(200,{'Content-Type':'image/jpg'});
				res.write(data,'binary');
				res.end();
			});
	}
	else{
		fs.readFile(__dirname + '/index.html', function(err,data){
			if(err){
				res.writeHead(500);
				return res.end('Error');
			}
			res.writeHead(200);
			res.write(data);
			res.end();
		})		
	}
}

io.sockets.on('connection',function(socket){
	socket.on('emit_from_client',function(data){
		socket.emit('emit_from_server',sensor_array[sensor_array.length-1]);
	});

	socket.on('emit_from_client_with_camera',function(data){
		var raspistill = spawn('raspistill', [ '-o' , './images/raspi_camera.jpg','-w' , '320', '-h', '240', '-t','100']);

		const req1 = new vision.Request({
			image: new vision.Image('./images/raspi_camera.jpg'),
			features: [
				new vision.Feature('FACE_DETECTION', 4),
			]
		});

		vision.annotate(req1).then((res) => {
			gcv_json_data = JSON.stringify(res.responses);
			socket.emit('emit_from_server_with_camera',gcv_json_data);
		}, (e) => {
			console.log('Error: ', e)
		});
	});
});