//18x19?
//FF = 255, 1111 1111 = 1 byte = 8 bits
//FF FF FF = 3 bytes = 24 bits
//rgba = FF FF FF | FF = 4 bytes = 32 bits 


// --- Header decoding ---
//01000100 seems to mean header start?
//0000747E seems to mean header end?

//header for 18x18 image (hex 12x12):
//01000100 02000300 0F000F00 02000300 0E000D00 02000300 0E000D00 0300|1200 00000000| 12000000 0000|747E 0000

//header for 14x? image (hex 0Ex ):
//01000100 01000300 0C000B00 01000300 0C000B00 01000300 0C000B00 0300|1000 00000000| 0E000000 0000|747E 0000

//01000100 02000200 0D000E00 01000200 0E000E00 01000200 0E000E00 0200|1000 00000000| 10000000 0000|747E 

//last two bytes 
//12000000 0000747E
//[WIDTH 34->37] [TERMINATION]

//Work in progress
function readNextHeader(data:ByteArray):Object{
	//Header Config
	//example header for 18x18 image (hex 12x12):
	//01000100 02000300 0F000F00 02000300 0E000D00 02000300 0E000D00 0300|1200 00000000| 12000000 0000|747E
	var startSeq = [0x01,0x00,0x01,0x00];//may actually be [0x00, 0x00, 0x01,0x00,0x01,0x00]
	var endSeq = [0x74,0x7E];
	var bytesBetween = 38;//bytes between, not always 38!!!

	var widthLocation:Int = 32;
	var heightLocation:Int = 26;
	var widthLength:Int = 4, heightLength:Int = 4;//maybe 6

	//loop setup
	var validHeader = false;
	var byte:Int;
	var sRegime:Int = 0;
	var seqI:Int = 0;
	var bbI = 0;

	var width:Int = 0, height:Int = 0;//filled from header data
	while(data.bytesAvailable>0){
		byte = data.readByte();

		switch (sRegime) {
			case 0:	//start sequence
				if(byte == startSeq[seqI]){
					seqI++;
				}else{
					seqI=0;
				}

				//Check to see if we've completed the sequence
				if(seqI >= startSeq.length){
					seqI = 0;
					bbI = 0;
					sRegime = 1;
				}
			case 1:	//image information
				//extract data from header
				//Width
				if(bbI >= widthLocation && bbI < widthLocation+widthLength){
					//Assuming big endian
					width+= byte*(0x1 << (bbI - widthLocation)*8);
				}
				//Height
				if(bbI >= heightLocation && bbI < heightLocation+heightLength){
					//Assuming big endian
					height+= byte*(0x1 << (bbI - heightLocation)*8);
				}
				bbI++;

				//end of bytes between
				if(bbI >= bytesBetween){
					seqI = 0;
					bbI = 0;
					sRegime = 2;
				}
			case 2: //end sequence
				if(byte == endSeq[seqI]){
					seqI++;
				}else if(seqI>0){
					var op = data.position;
					data.position -=8;
					//trace("false end "+data.readByte()+" "+data.readByte()+" "+data.readByte()+" "+data.readByte()+" "+data.readByte()+" "+data.readByte()+" "+data.readByte()+" "+data.readByte());
					data.position = op;
					seqI = 0;
					bbI = 0;
					sRegime = 0;
				}

				//Check to see if we've complete the end sequence
				if(seqI >= endSeq.length){
					//HEADER COMPLETED
					//trace("complete");
					validHeader = true;
					break;
				}
			default:
				seqI = 0;
				bbI = 0;
				sRegime = 0;
		}
	}

	if(validHeader == false)return null;//didn't find anything

	return {width:width,height:height};
}

function bytesToBitmapData(bytes:ByteArray, w):BitmapData{
	bytes.endian = flash.utils.Endian.LITTLE_ENDIAN;
	//RGBA
	var numBytesPerColor = 4;
	var numBytesPerRow = w * numBytesPerColor;
	//Compute num rows
	var h:Int = Math.ceil(bytes.bytesAvailable/numBytesPerRow);
	//Create bitmap data
	var bd:BitmapData = new BitmapData(w,h, false, 0x00FFFF);
	//given 4-byte index i4, find x,y
	var rgba:Int, i4:Int = 0;
	while(bytes.bytesAvailable>0){
		rgba = bytes.readInt();
		bd.setPixel32(i4%w,Math.floor(i4/w),rgba);
		i4++;
	}

	return bd;
}

function readBitmapData(bytes:ByteArray, w:Int, h:Int):BitmapData{
	//RR GG BB AA = 4 bytes
	var bd:BitmapData = new BitmapData(w,h, true, 0xFF00FFFF);
	var nColorsToRead = w*h;
	
	var rgba:Int, i4:Int = 0;
	while(i4<nColorsToRead && bytes.bytesAvailable>=4){
		rgba = bytes.readInt();
		bd.setPixel32(i4%w,Math.floor(i4/w),rgba);
		i4++;
	}
	return bd;
}


//Start
var data = Assets.getBytes("assets/ArtFile.bin");
data.endian = flash.utils.Endian.LITTLE_ENDIAN;

var images:Array<Bitmap> = new Array<Bitmap>();
//Find images
var header:Object;
header = readNextHeader(data);
while(header!=null){
	//1296 = w*h*4 :)
	//trace("valid header found, w = "+header.width+" h = "+header.height);
	if(header.width>0 && header.width<=100 && header.height > 0 && header.height <= 100){//check to see if the image looks reasonable (only care about small images)
		var bitmapData:BitmapData = readBitmapData(data, header.width, header.height);
		images.push(new Bitmap(bitmapData));
	}
	header = readNextHeader(data);
}

//Display images
var display:Bitmap;
var i = 0;
var tryX, row = 0, yOffset:Float = 0, nextYOffset:Float = 0;
for(i in 0...images.length){
	display = images[i];
	display.scaleX = display.scaleY = 1;
	if(i>0){
		tryX = images[i-1].width+images[i-1].x;
		if(tryX + display.width>stage.stageWidth){	//new row
			tryX = 0;
			yOffset = nextYOffset;
			row++;
		}
		if(yOffset+display.height > nextYOffset) nextYOffset = yOffset+display.height;//push down row offset
		display.x = tryX;
		display.y = yOffset;
	}
	this.addChild(display);
}
