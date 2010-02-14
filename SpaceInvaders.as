package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.Timer;
	import com.greensock.*;				// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	import Player;						// Custom application classes
	import Invader;
	import Spaceship;
	import Defence;
	
	public class SpaceInvaders extends MovieClip
	{
		private static var _instance:SpaceInvaders;
		private static const NUMBER_OF_INVADERS:uint				= 55; //55
		private static const AMOUNT_OF_INVADERS_PER_LINE:uint		= 11; //11
		private static const INITIAL_INVADERS_SPEED:uint			= 1000;
		// Objects
		public var  player:Player;
		public var  invaders:Array;
		public var  invaderBullets:Array;								// Array of Invader bullets currently on screen
		private var defences:Array;
		private var spaceship:Spaceship;
		// States
		private var level:uint						= 1;
		private var highestScore:uint				= 0;
		private var invadersDirection:int;
		private var changingDirection:uint;							// Flag used to skip some code. invaders take 2 steps to change direction
		// Containers
		public var  invadersLayer:MovieClip;
		private var defencesLayer:MovieClip;
		private var introScreenMC:MovieClip;
		// Timers
		public var  moveInvadersTimer:Timer;
		public var  invaderShootTimer:Timer;
		private var spaceshipTimer:Timer;
		private var flashScoreTimer:Timer;
		private var invadersSpeed:uint;									// In milliseconds
		private var frequencyOfInvaderBullets:Number	= 500;			// How often do we fire the random bullet method?
		
		public function SpaceInvaders()
		{
			_instance = this;
			introScreen();
		}
		
		private function introScreen():void
		{
			// Clean up if coming from a finished game
			if (player) {
				player.deletePlayer();
				if (player.lives) player.removeExistingLives();
			}
			if (invaders) invaders.forEach(function(invader, index){
				invader.deleteInvader();	 
			});
			invaders 			= [];
			invaderBullets		= [];
			if (defencesLayer) { removeChild(defencesLayer); }
			
			currentLivesUI.text		= "0";		// Empty the UI text fields
			levelLabelTxt.text		= "LEVEL";
			currentLevelUI.text 	= "0";
			player1ScoreTxt.text 	= "0000";
			
			introScreenMC 		= new IntroScreen();		// Add the Info Screen clip
			introScreenMC.y		= 70;
			addChild( introScreenMC );
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);		// We await instruction...
		}
		
		private function startGame():void
		{
			if (introScreenMC) removeChild(introScreenMC);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);	
			
			player 				= new Player(stage, currentLivesUI);
			spaceship 			= new Spaceship(stage);
			invadersSpeed 		= INITIAL_INVADERS_SPEED;
			levelLabelTxt.text	= "LEVEL";
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			initDefenses();
			startNewLevel();
		}
		
		private function startNewLevel():void
		{
			initUI();
			initInvaders();
			initTimers();
		}
	
		private function continueGame():void
		{
			player.startNewLife();

			moveInvadersTimer.start();
			invaderShootTimer.start();
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function initUI():void
		{
			currentLevelUI.text		= level.toString();			
			//var feedbackText		= getChildByName("feedbackUI");
			//setChildIndex(feedbackText, 0);
		}
		
		private function initDefenses():void
		{
			this.defences		= new Array();
			
			defencesLayer		= new MovieClip();
			defencesLayer.name	= "defencesLayer";
			defencesLayer.x		= 80;
			defencesLayer.y		= 360;
			addChild( defencesLayer );
			
			var xOffset = 0;
			for (var i=1; i<5; i++) {
				var defenceObj	= new Defence(stage, defencesLayer);
				defences.push(defenceObj);
				defenceObj.defenceMC.x += xOffset;
				defenceObj.defenceMC.y = 0;
				defencesLayer.addChild( defenceObj.defenceMC );
				xOffset += 112;
			}
		}
		 
		private function initInvaders():void
		{
			invadersDirection	= 12;
			invaders			= new Array();
			
			invadersLayer		= new MovieClip();
			invadersLayer.name	= "invadersLayer";
			invadersLayer.x		= 140;
			invadersLayer.y		= 100;
			
			createInvaders();
			addChild( invadersLayer );
		}
		
		private function createInvaders():void
		{
			var xOffset	= 0, yOffset = 0;
			for (var i = 1; i < NUMBER_OF_INVADERS + 1; i++)
			{
				var row = (yOffset / 30) + 1;
				var col = (i % AMOUNT_OF_INVADERS_PER_LINE == 0) ? AMOUNT_OF_INVADERS_PER_LINE : i % AMOUNT_OF_INVADERS_PER_LINE;
				// Create a new invader object and add it to the invaders array
				var invaderObj	= new Invader(stage, row, col, invadersLayer);
				invaders.push(invaderObj);
				invaderObj.invaderMC.x	+= xOffset;
				invaderObj.invaderMC.y	+= yOffset;
				invadersLayer.addChild( invaderObj.invaderMC );
				
				// Adjust offsets
				if (i % AMOUNT_OF_INVADERS_PER_LINE == 0) {		// = New Line
					xOffset	= 0;
					yOffset += 30;
				} else {
					xOffset += 30;
				}
			}
			invaders.sortOn(["col","row"], Array.NUMERIC);
		}
		
		private function moveInvaders(e:TimerEvent):void
		{
			/* 	Change direction of invaders at the edges.
			 *	We work out the perceived left and right because of how movieclip containers 
			 *	behave when we remove contained elemnts from the left hand side.
			 *
			 *	For more info see -> http://www.actionscript.org/forums/showpost.php3?p=755924&postcount=5
			 */
			var perceivedLeft		= Math.ceil(invadersLayer.x + invaders[0].invaderMC.x);
			var perceivedRight		= Math.ceil(invadersLayer.x + invaders[invaders.length-1].invaderMC.x);
			var tweenTime 			= (moveInvadersTimer.delay / 4) / 1000;
			
			// We use a changingDirection var to handle changes of directions (which take 2 timed steps)
			if ( (perceivedLeft < 22 || perceivedRight > 510) && changingDirection > 5 ) {
				
				haveInvadersLanded();	//? - if so, gameOver()
				
				// Move down
				TweenMax.to(invadersLayer, tweenTime, {y:invadersLayer.y + 15, ease:Circ.easeIn, onComplete:animateInvaders});
				changingDirection		= 0;
				invadersDirection 		*= -1;
			} else {
				// Move left / right
				TweenMax.to(invadersLayer, tweenTime, {x:invadersLayer.x + invadersDirection, ease:Circ.easeIn, onComplete:animateInvaders});
				changingDirection++;
			}
		}
		
		private function animateInvaders():void
		{
			invaders.forEach(function(invader){ invader.animate(); });
		}
		
		private function removeInvader(deadInvader, index):void
		{
			// Was the dead invader a shooting alien?
			// If so pass the shooting power to the alien above his head (wherever possible)
			if (deadInvader.shooter && index) {
				if (invaders[index-1].col == deadInvader.col) invaders[index-1].shooter = true;
			}
			
			player.deleteBullet();
			deadInvader.explode();
			invaders.splice(index, 1);
			
			player.increaseScore(deadInvader.points);
			player1ScoreTxt.text = player.score.toString();
			
			if (!invaders.length) levelCompleted();
			
			// Speed up as a row's worth invaders are killed 
			if (invaders.length % AMOUNT_OF_INVADERS_PER_LINE == 0) moveInvadersTimer.delay = Math.ceil(moveInvadersTimer.delay * 0.7);
			if (invaders.length < 5) moveInvadersTimer.delay = Math.ceil(moveInvadersTimer.delay * 0.7);
		}
		
		private function removeSpaceship():void
		{
			player.deleteBullet()
			spaceship.explode();
			player.increaseScore(spaceship.points);
			player1ScoreTxt.text = player.score.toString();
		}
		
		private function levelCompleted():void
		{
			removeTimers();
			level++;
			invadersSpeed -= 50;
			startNewLevel();
		}

		private function initTimers():void
		{
			moveInvadersTimer = new Timer(invadersSpeed);
			moveInvadersTimer.addEventListener(TimerEvent.TIMER, moveInvaders);
			moveInvadersTimer.start();
			
			invaderShootTimer = new Timer(frequencyOfInvaderBullets);
			invaderShootTimer.addEventListener(TimerEvent.TIMER, invadersShoot);
			invaderShootTimer.start();
			
			spaceshipTimer = new Timer(5000);
			spaceshipTimer.addEventListener(TimerEvent.TIMER, spaceshipAppears);
			spaceshipTimer.start();
			
			flashScoreTimer = new Timer(100, 20);
			flashScoreTimer.addEventListener(TimerEvent.TIMER, flashScore);
			flashScoreTimer.start();
		}
		
		private function removeTimers():void
		{
			moveInvadersTimer.stop();
			moveInvadersTimer.removeEventListener(TimerEvent.TIMER, moveInvaders);
			
			invaderShootTimer.stop();
			invaderShootTimer.removeEventListener(TimerEvent.TIMER, invadersShoot);
			
			spaceshipTimer.stop();
			spaceshipTimer.removeEventListener(TimerEvent.TIMER, spaceshipAppears);
		}
		
		private function gameOver():void
		{
			removeTimers();
			stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			if (player.score > highestScore) highestScore = player.score;
			highScoreTxt.text = highestScore.toString();
			
			// This next chunk of code dynamically works out where the biggest gap on the stage is, to show "Game Over" feedback
			var feedbackPos:int;
			if ((invadersLayer.y + (invadersLayer.height/2)) > (stage.stageHeight/2 - 30))
				feedbackPos	= 60 + ((invadersLayer.y - 70) / 2); 	// 1/2 way between the scores and the top of the invaders
			else 
				feedbackPos = 360 - ((360 - (invadersLayer.y + invadersLayer.height)) / 2);		// 1/2 way between the bottom of the invaders and the green line
			feedback("Game Over", feedbackPos);
			
			// Dummy tween | 3 sec delay with go to intro callback
			TweenMax.to(feedbackUI, 1, {delay:3, alpha:0, onComplete:introScreen});
		}

		private function enterFrameHandler(e:Event):void
		{
			if (invaderBullets.length) playerHitCheck();
			if (player.bulletOnScreen) invadersHitTest();
			if (invaderBullets.length || player.bulletOnScreen) 	defencesHitTest();
			if (spaceship.inFlight && player.bulletOnScreen) 		spaceshipHitTest();
		}
		
		private function playerHitCheck():void		// First part of this Handler lives in the Bullet class
		{
			if (player.playerMC.currentFrame == 2 && !player.playerHit) {	// PlayerMC is moved to frame 2 by the Invader class..
				
				player.loseALife();
				initUI();

				if (player.lives == 0) gameOver();
				else TweenMax.to(player.playerMC, 2, {onComplete:continueGame});	// Dummy tween to create a 2 sec pause
			};
		}
		
		private function defencesHitTest():void
		{
			defences.forEach(function(defence, index) {
				if (player.bulletOnScreen) {
					if (player.bulletMC.hitTestObject(defence.defenceMC)) {
						defence.defenceHit(defence, player);
					}
				}
				if (invaderBullets.length > 0) {
					invaderBullets.forEach(function(invaderBullet){
						if (invaderBullet) {	
							if (invaderBullet.bulletMC.hitTestObject(defence.defenceMC)) {
								defence.defenceHit(defence, invaderBullet);
							}
						}
					});
				}
			});
		}
		
		private function invadersHitTest():void
		{
			invaders.forEach(function(invader, index) {
				if (invader) {
					if (player.bulletMC.hitTestObject(invader.invaderMC)) removeInvader(invader, index);
				}
			});
		}
		
		private function spaceshipHitTest():void
		{
			if (player.bulletMC.hitTestObject(spaceship.spaceshipMC)) {
				removeSpaceship();
			}			
		}
		
		private function haveInvadersLanded():void
		{
			if ( Math.ceil(invadersLayer.y + invadersLayer.height) > stage.stageHeight - 120)
			{
				player.playerHit = true;
				player.playerMC.gotoAndPlay("blowUp");		
				gameOver();
			}
		}
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == 49) startGame();
		}
		
		private function invadersShoot(e:TimerEvent):void
		{
			var bullet;
			// We shoot a bullet on average 1 in every 3 method calls
			if (Math.random() < 0.333) {
				var shooters = getShooterInvaders();
				if (shooters.length > 1) {
					var rand	= Math.round (Math.random () * (shooters.length - 1));
					var key		= shooters[rand];
					bullet 		= invaders[key].shootBullet();
				} else {
					// last invader
					bullet 		= invaders[0].shootBullet();
				}
			}
			if (bullet) invaderBullets.push(bullet);	// if a bullet is fired, we add it to our bullets array
		}
		
		private function spaceshipAppears(e:TimerEvent):void
		{
			if (!spaceship.inFlight && Math.random() < 0.333) {
				spaceship.flyAcross();
			}
		}
		
		private function flashScore(e:TimerEvent):void				// Flashes the players score at start of each go
		{
			if (!player.score)
				(player1ScoreTxt.text) ? player1ScoreTxt.text = "" : player1ScoreTxt.text = "0000";
			else
				player1ScoreTxt.text = player.score.toString();		// Override the flashing as soon as they hit something
		}

		private function feedback(message, ypos = null):void
		{
			feedbackUI.alpha	= 0;
			feedbackUI.y		= -30;
			feedbackUI.text		= message;
			var ypos = (!ypos) ? stage.stageHeight/2 : ypos;
			TweenMax.to(feedbackUI, 1, {alpha:1, y:ypos, ease:Bounce.easeOut});
		}
		
		private function getShooterInvaders():Array					// Returns an array of array keys for all invaders instructed to shoot
		{
			var shooterIds	= [];
			invaders.forEach(function(invader, index, arr){
				if (invader.shooter) shooterIds.push(index);  
			});
			return shooterIds;
		}
		
		public static function get instance():SpaceInvaders { return _instance; }

		/*
		 *
		 *			DEV UTILITIES		-> Delete these methods when we publish
		 *
		 */
		public function traceInvaders():void
		{
			for (var i=0, len=invaders.length; i<len; i++) {
				trace('Key: '+i+' invaderMC.x: '+invaders[i].invaderMC.x+' Row: '+invaders[i].row+' Col: '+invaders[i].col+' Shooter: '+invaders[i].shooter);
			}
		}
		
		private function debugDump():void
		{
			trace('-----');
			trace('Invaders left: '+invaders.length);
			trace('Timer speed: '+moveInvadersTimer.delay);
			trace('Amount to move: '+invadersDirection);
			//trace('perceivedRight (> 520?): '+perceivedRight);
			//trace('perceivedLeft (< 25?): '+perceivedLeft);
			trace('changingDirection: '+changingDirection);
		}
		
		/* draws a border around any movie clip */
		public static  function doDrawRect(clip):void 
		{
            var child:Shape = new Shape();
            child.graphics.beginFill(0xffffff);
            child.graphics.lineStyle(1, 0x000000);
            child.graphics.drawRect(clip.x, clip.y, clip.width, clip.height);
            child.graphics.endFill();
            clip.parent.addChildAt(child, 0);
        }
		
		/* Static function to trace out the display list tree */
		public static function traceDisplayList(container:DisplayObjectContainer, indentString:String = ""):void
		{
			var child:DisplayObject;
			for (var i:uint=0; i < container.numChildren; i++)
			{
				child = container.getChildAt(i);
				trace(indentString, child, child.name); 
				if (container.getChildAt(i) is DisplayObjectContainer)
				{
					traceDisplayList(DisplayObjectContainer(child), indentString + "    ")
				}
			}
		}
	}
}