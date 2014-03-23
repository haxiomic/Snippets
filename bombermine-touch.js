/* 
	Touchscreen Controls for bombermine.com
	haxiomic@gmail.com
	- Todo: 
		> Fix overlay width issue when added, setting the meta tags caused a width change which isn't handled by the code
		  currently using a time to call handleresize to fix this
*/

(function( touchControls, $, undefined ) {
	if(window.touchControlsAdded!=true)window.touchControlsAdded = true;else return;
	//Check device support and set touchscreen locks
	var iOS = ( navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? true : false );
	var touchable = 'createTouch' in document;//Does device support touch?
	//Lock screen
	$('head').append('<meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />'); //No Zoom
	document.body.addEventListener('touchmove', function(e){e.preventDefault();});	//No Scroll
	window.scrollTo(0,0);

	//Settings
	//Center of joystick, measured from bottom left
	var joystickCenterX = 110;
	var joystickCenterY = 190;
	var joystickRadius = 100;
	var joystickInnerRadius = 0;

	// ---- Setup ----
	//Create Controller Canvas
	var joyCanvasElement;
	var joyCtx;
	var joyCanvasElement = document.createElement('canvas');
	joyCanvasElement.id = "joystickCanvas";
	joyCanvasElement.width = 290;
	joyCanvasElement.height = 290;
	joyCtx = joyCanvasElement.getContext('2d'); 
	joyCtx.strokeStyle = "rgba(100, 100, 100,0.1)";

    //Keyboard Emulation
    //w = 87, s = 83, a = 65, d = 68, space = 32
    var isWDown = false;var isSDown = false;var isADown = false;var isDDown = false;
    touchControls.wDown = function(){touchControls.keydown(87);isWDown = true;}
    touchControls.sDown = function(){touchControls.keydown(83);isSDown = true;}
    touchControls.aDown = function(){touchControls.keydown(65);isADown = true;}
    touchControls.dDown = function(){touchControls.keydown(68);isDDown = true;}
    touchControls.spaceDown = function(){touchControls.keydown(32);}
    touchControls.qDown = function(){touchControls.keydown(81);}
    touchControls.lDown = function(){touchControls.keydown(76);}
    touchControls.wUp = function(){touchControls.keyup(87);isWDown = false;}
    touchControls.sUp = function(){touchControls.keyup(83);isSDown = false;}
    touchControls.aUp = function(){touchControls.keyup(65);isADown = false;}
    touchControls.dUp = function(){touchControls.keyup(68);isDDown = false;}
    touchControls.spaceUp = function(){touchControls.keyup(32);}
    touchControls.qUp = function(){touchControls.keyup(81);}
    touchControls.lUp = function(){touchControls.keyup(76);}
    touchControls.keydown = function(keyCode){jQuery("body").trigger(jQuery.Event("keydown", { keyCode: keyCode }));}
    touchControls.keyup = function(keyCode){jQuery("body").trigger(jQuery.Event("keyup", { keyCode: keyCode }));}

    //Touch Input
   	var joyTouchID = -1;
   	var joyTouchX = NaN;
   	var joyTouchY = NaN;
   	var joyActiveSegment = -1;

   	function onTouchStart(e) {
		for(var i = 0; i<e.changedTouches.length; i++){
			var touch = e.changedTouches[i]; 
			dx = touch.clientX-joystickCenterX;
			dy = touch.clientY-(document.documentElement.clientHeight-joystickCenterY);
			d = Math.sqrt(dx*dx+dy*dy);	
			console.log('start:  '+'touchID:'+touch.identifier+' joyID:'+joyTouchID);
			if(joyTouchID<0  && d<=joystickRadius){
				joyTouchID = touch.identifier;
				handleJoystickTouch(touch);
				break;
			}
		}
	}
	function onTouchMove(e) {
		for(var i = 0; i<e.changedTouches.length; i++){
			var touch = e.changedTouches[i]; 
			if(joyTouchID == touch.identifier)
			{
				handleJoystickTouch(touch);
				break;
			}
		}
	}
	function onTouchEnd(e) {
		for(var i = 0; i<e.changedTouches.length; i++){
			var touch = e.changedTouches[i];
			console.log('end:  '+'touchID:'+touch.identifier+' joyID:'+joyTouchID);
			if(joyTouchID == touch.identifier)
			{
				joyTouchID = -1;
				joyActiveSegment = -1;
				setDirection(joyActiveSegment);
				touchControls.wUp();
				touchControls.sUp();
				touchControls.aUp();
				touchControls.dUp();
				break;
			}
		}
	}

	function handleJoystickTouch(touch){
		dx = touch.clientX-joystickCenterX;
		dy = touch.clientY-(document.documentElement.clientHeight-joystickCenterY);
		var a = Math.atan2(-dy,dx);
		joyActiveSegment = -1;//0->7, clockwise from east, each 45degs
		
		if(a>0){
			a+=Math.PI/8;
			if(a<Math.PI/4)			joyActiveSegment = 0; 	// 	East
			else if(a<Math.PI/2)	joyActiveSegment = 7; 	// 	North East
			else if(a<3*Math.PI/4)	joyActiveSegment = 6;	//	North
			else if(a<Math.PI)		joyActiveSegment = 5;	//	North West
			else 					joyActiveSegment = 4;	//	West
		}else{
			a*=-1;
			a+=Math.PI/8;
			if(a<Math.PI/4)			joyActiveSegment = 0; 	// 	East
			else if(a<Math.PI/2)	joyActiveSegment = 1; 	// 	South East
			else if(a<3*Math.PI/4)	joyActiveSegment = 2;	//	South
			else if(a<Math.PI)		joyActiveSegment = 3;	//	South West
			else 					joyActiveSegment = 4;	//	West
		}

		setDirection(joyActiveSegment);
	}

	var lastDir = -1;
	function setDirection(dirIndex){
		var dir;//w,s,a,d
		switch (dirIndex){
			case -1: dir = [0,0,0,0];
			case 0: dir = [0,0,0,1];break;
			case 1: dir = [0,1,0,1];break;
			case 2: dir = [0,1,0,0];break;
			case 3: dir = [0,1,1,0];break;
			case 4: dir = [0,0,1,0];break;
			case 5: dir = [1,0,1,0];break;
			case 6: dir = [1,0,0,0];break;
			case 7: dir = [1,0,0,1];break;
			default:dir = [0,0,0,0];
		}
		(dir[0]==1 ? touchControls.wDown():  touchControls.wUp());
		(dir[1]==1 ? touchControls.sDown():  touchControls.sUp());
		(dir[2]==1 ? touchControls.aDown():  touchControls.aUp());
		(dir[3]==1 ? touchControls.dDown():  touchControls.dUp());
		//Redraw
		if(lastDir != dirIndex)drawJoystick();
		lastDir = dirIndex;
	}

	function drawJoystick(){
		var x,y, r, color = "rgba(255, 255, 255, 0.1)";
		r = joystickRadius;
		x = joystickCenterX;
		y = joyCanvasElement.height-joystickCenterY;

		joyCtx.clearRect(0,0,joyCanvasElement.width, joyCanvasElement.height); 

		if(joyActiveSegment<0)return;
		a=Math.PI*.25*joyActiveSegment;
		color = "rgba(56, 255, 89, 0.6)";
		joyCtx.beginPath();
		joyCtx.moveTo(x,y);
		joyCtx.arc(x,y,r,a-Math.PI/8,a + Math.PI/8);
		joyCtx.lineTo(x,y);
		joyCtx.fillStyle = color;
		joyCtx.fill();
		joyCtx.stroke();
	}
	drawJoystick();

	//Button Functions
    touchControls.makeActive = function(el){el = $(el);el.addClass("active");}
    touchControls.makeInactive = function(el){el = $(el);el.removeClass("active");}

   	// --- Interface ---
    if(!touchable)
    	window.onmouseup = function(){
			touchControls.wUp(); 
			touchControls.sUp(); 
			touchControls.aUp(); 
			touchControls.dUp(); 
			touchControls.spaceUp();
			touchControls.qUp();
    	}

	//Add onscreen buttons
	var onScreenControls = document.createElement('div');
	onScreenControls.id = "on-screen-controls";
	onScreenControls.innerHTML = '\
			<div class="on-screen-button" id="space" ontouchstart="touchControls.spaceDown();touchControls.makeActive(this)" ontouchend="touchControls.spaceUp();touchControls.makeInactive(this)"><p>Place Bomb</p></div>\
			<div class="on-screen-button" id="zoom" ontouchstart="touchControls.qDown();touchControls.makeActive(this)" ontouchend="touchControls.qUp();touchControls.makeInactive(this)"><p>Zoom</p></div>\
			<div class="on-screen-button" id="detonate" ontouchstart="touchControls.lDown();touchControls.makeActive(this)" ontouchend="touchControls.lUp();touchControls.makeInactive(this)"><p>Detonate</p></div>\
	';
	//Make circle to contain joystick
	var joystickActiveCircle = document.createElement('div');
	joystickActiveCircle.id = "joystick-active-circle";
	joystickActiveCircle.style.position = "absolute";
	joystickActiveCircle.style.left = (joystickCenterX-joystickRadius)+"px";
	joystickActiveCircle.style.bottom = (joystickCenterY-joystickRadius)+"px";
	joystickActiveCircle.style.width = joystickRadius*2+"px";
	joystickActiveCircle.style.height = joystickRadius*2+"px";
	joystickActiveCircle.style.webkitBorderRadius = joystickRadius+"px";
	joystickActiveCircle.style.mozBorderRadius = joystickRadius+"px";
	joystickActiveCircle.style.borderRadius = joystickRadius+"px";


	onScreenControls.appendChild(joyCanvasElement);
	onScreenControls.appendChild(joystickActiveCircle);
	document.body.appendChild(onScreenControls);

	//Enable controls for desktop
	if(!touchable) $('.on-screen-button').each(function(i, el){ 
		el=$(el);
		el.attr("onmousedown", el.attr("ontouchstart"));
		el.attr("onmouseup", el.attr("ontouchend"));
	});

	//Replace respawn text
	$('#scoreboard-new .respawn-text').html('<a href="javascript:touchControls.keydown(32);">Click to Respawn</a>');

	//Add touch listeners
	window.addEventListener( 'touchstart', onTouchStart, false );
	window.addEventListener( 'touchmove', onTouchMove, false );
	window.addEventListener( 'touchend', onTouchEnd, false ); 



	//---------------------------//
	//Add CSS
	var css = document.createElement("style");
	css.type = "text/css";
	css.innerHTML = "\
		html{\
			-webkit-touch-callout: none;\
			-webkit-user-select: none;\
			-khtml-user-select: none;\
			-moz-user-select: none;\
			-ms-user-select: none;\
			user-select: none;\
		}\
		.enter, input, #scoreboard-new{\
			-webkit-touch-callout: default !important;\
			-webkit-user-select: auto !important;\
			-khtml-user-select: auto !important;\
			-moz-user-select: auto !important;\
			-ms-user-select: auto !important;\
			user-select: auto !important;\
		}\
		#viewport {\
			z-index:0;\
		}\
		.viewport-outer {\
			right:0px !important;\
		}\
		.chat{\
			visibility:hidden;\
			display:none;\
		}\
		#on-screen-controls{\
			width: 100%;\
			height: 100%;\
			top: 0px;\
			left: 0px;\
			z-index: 9999;\
		}\
		.on-screen-button {\
			position:absolute;\
			width:100px;\
			height:100px;\
			background-color: rgba(255,255,255,0.4);\
			border: 1px solid rgba(100,100,100,0.4);\
			text-align:center;\
			font-size: 20px;\
			font-weight:bold;\
			color:rgb(71, 71, 71);\
			-webkit-touch-callout: none;\
			-webkit-user-select: none;\
			-khtml-user-select: none;\
			-moz-user-select: none;\
			-ms-user-select: none;\
			user-select: none;\
			display: table;\
		}\
		.on-screen-button p{\
			display: table-cell;\
			vertical-align: middle;\
			text-align: center;\
			-webkit-touch-callout: none;\
			-webkit-user-select: none;\
			-khtml-user-select: none;\
			-moz-user-select: none;\
			-ms-user-select: none;\
			user-select: none;\
		}\
		#joystickCanvas {\
			position:absolute;\
			bottom:0;\
			left:0;\
			background-color:rgba(0,0,255,0.0);\
			pointer-events:none\
			z-index:1002;\
		}\
		#joystick-active-circle{\
			background-color:#ffffff;\
			opacity:0.2;\
			border: 1px solid rgba(100,100,100,1);\
			z-index:1001;\
		}\
		.active{\
			background-color:rgba(56, 255, 89, 0.6);\
			color:rgb(26, 167, 77);\
		}\
		#space{\
			right:0;\
			bottom:0;\
			width:200px;\
			height:200px;\
		}\
		#zoom{\
			bottom:200px;\
			right:0px;\
			width:70px;\
			height:70px;\
			font-size:14px\
		}\
		#detonate{\
			bottom:200px;\
			right:72px;\
			width:128px;\
			height:70px;\
			font-size:16px\
		}\
	";
	document.body.appendChild(css);

	function handleResize(){
		//Fix viewport size
		var vp = $('.viewport-outer');
		gameSetViewportSize(vp.width(),vp.height());
	}
	
	window.onresize = handleResize;
	
	handleResize();

	//#! Lazy screen bug fix - replace
	setTimeout(handleResize,500);

	console.log('Touchscreen controls ready');
})( window.touchControls = window.touchControls || {}, jQuery );