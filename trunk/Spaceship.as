package {
	import flash.display.*;
	import com.greensock.*;									// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	
	public class Spaceship extends MovieClip
	{
		private var swfStage:Stage;
		public var spaceshipMC:SpaceshipMC;
		public var points:uint;
		public var inFlight:Boolean;
		
		public function Spaceship(swfStage:Stage)
		{
			this.swfStage		= swfStage;
			spaceshipMC			= new SpaceshipMC();
		}
		
		public function flyAcross():void
		{
			points 		= Math.ceil((Math.random() * 5)) * 50;	// 50 | 100 | 150 | 200 | 250
			inFlight	= true;
			
			var xDestination:int;
			if (Math.random() < 0.5) {
				spaceshipMC.x	= swfStage.stageWidth + 50;
				xDestination 	= -50;
			} else {
				spaceshipMC.x	= -50;
				xDestination 	= swfStage.stageWidth + 50;
			}
			spaceshipMC.y		= 80;
			swfStage.addChild(spaceshipMC);
			
			TweenMax.to(spaceshipMC, 6, {x:xDestination, ease:Linear.easeNone, onComplete:flightComplete});
		}
		
		public function flightComplete():void
		{
			inFlight	= false;
		}
		
		public function explode():void
		{
			var explosion	= new SpaceshipExplosion();
			explosion.x		= spaceshipMC.x;
			explosion.y		= spaceshipMC.y;
			swfStage.addChild(explosion);
			
			var scoreText 	= new SpaceshipExplosionText();
			scoreText.x		= explosion.x;
			scoreText.y		= explosion.y;
			scoreText.alpha	= 0;
			scoreText.spaceshipScoreTxt.text = points.toString();
			swfStage.addChild(scoreText);
			
			TweenMax.from(explosion, 0.2, {scaleX:0, scaleY:0});
			TweenMax.to(explosion, 0.6, {delay:0.05, alpha:0, onComplete:deleteExplosion, onCompleteParams:[explosion, scoreText]});
			TweenMax.to(scoreText, 1, {alpha:1});
			
			swfStage.removeChild(this.spaceshipMC);
		}
		
		private function deleteExplosion(explosion, scoreText):void
		{
			explosion.parent.removeChild(explosion);
			TweenMax.to(scoreText, 0.6, {delay:2, alpha:0, onComplete:deletePointsText, onCompleteParams:[scoreText]});
		}
		
		private function deletePointsText(scoreText):void
		{
			swfStage.removeChild(scoreText);
		}
	}
}