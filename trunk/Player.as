package {
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import com.greensock.*;						// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	
	public class Player extends MovieClip
	{
		private static const PLAYER_SPEED:uint				= 5;
		private static const BULLET_SPEED:uint				= 8;
		// PROPERTIES
		private var swfStage:Stage;
		public var playerMC:MovieClip;
		public var bulletMC:MovieClip;
		// States
		public var lives:uint;
		private var currentLivesUI:TextField;
		public var score:uint;
		public var bulletOnScreen:Boolean;
		public var playerHit:Boolean;
		public var extraLifeAt:uint		= 5000;
		// Controls
		private var rightArrow:Boolean;
		private var leftArrow:Boolean;
		
		public function Player(swfStage:Stage, currentLivesUI:TextField)
		{
			this.swfStage		= swfStage;
			this.currentLivesUI = currentLivesUI;
			this.lives			= 3;
			this.score			= 0;
			
			this.playerMC		= new PlayerMC();
			playerMC.name		= "playerMC";
			playerMC.x			= 0;
			
			initPlayer();
		}
		
		public function initPlayer():void
		{
			playerHit 	= false;
			
			playerMC.y	= swfStage.stageHeight - 80;
			positionPlayer();
			swfStage.addChild( playerMC );
			
			initLivesInReserve();
			
			swfStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            swfStage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			swfStage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function positionPlayer():void
		{
			TweenMax.to(this.playerMC, 1, {x:104, ease:Bounce.easeOut});
		}
		
		public function initLivesInReserve():void
		{
			// Remove any existing lives icons, so we can rebuild
			removeExistingLives();
			
			// Create icons for remaining lives
			var offset = 0;
			for (var i=1; i<lives; i++) {
				var defender 	= new PlayerMC();
				defender.name	= "livesLeftIcon";
				defender.x		= 80 + offset;
				defender.y		= 466;
				swfStage.addChild(defender);
				
				offset += 30;
			}
			currentLivesUI.text	= lives.toString();
		}
		
		public function removeExistingLives():void
		{
			for (var x=0; x<lives; x++) {
				var ref = swfStage.getChildByName("livesLeftIcon");
				if (ref) swfStage.removeChild(ref);
			}
		}
		
		private function shootBullet():void
		{
			if (!playerHit) {
				bulletMC			= new BulletMC();
				bulletMC.name		= "bulletMC";
				bulletMC.x			= playerMC.x;
				bulletMC.y			= playerMC.y;
				swfStage.addChild( bulletMC );
				bulletOnScreen 		= true;
			}
		}
		
		private function moveBullet():void
		{	
			if (bulletMC.y > 70) bulletMC.y -= BULLET_SPEED;
			else 
			{
				deleteBullet();
				bulletOnScreen = false;
			}
		}
		
		public function deleteBullet():void
		{
			// Clean up memory by removing bullet clips when they are off the screen
			var bullet = swfStage.getChildByName("bulletMC");
			if (bullet) swfStage.removeChild( bullet );
			
			bulletOnScreen = false;
		}
		
		public function increaseScore(points:uint):void
		{
			score += points;
			if (score > extraLifeAt) extraLife(); 
		}
		
		private function extraLife():void
		{
			lives++;
			extraLifeAt += 5000;
			initLivesInReserve();
		}
		
		public function loseALife():void
		{
			playerHit = true;
			lives--;
			initLivesInReserve();
		}
		
		public function startNewLife():void
		{
			playerMC.gotoAndStop(1);
			playerHit = false;
			positionPlayer();
		}
		
		public function deletePlayer():void
		{
			swfStage.removeChild(playerMC);
		}
		
		private function enterFrameHandler(event:Event):void
		{
			if (!playerHit) {	
				if (rightArrow && (playerMC.x < (swfStage.stageWidth - playerMC.width))) 	playerMC.x += PLAYER_SPEED;
				if (leftArrow && (playerMC.x > (0 + playerMC.width))) 						playerMC.x -= PLAYER_SPEED;
			}
			if (bulletOnScreen) moveBullet();
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.RIGHT) 	rightArrow = true;
			if (event.keyCode == Keyboard.LEFT) 	leftArrow = true;
			if (event.keyCode == Keyboard.SPACE && bulletOnScreen == false)
			{
				shootBullet();
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.RIGHT) 	rightArrow = false;
			if (event.keyCode == Keyboard.LEFT) 	leftArrow = false;
		}
	}
}