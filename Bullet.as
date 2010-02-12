package {
	import flash.display.*;
	import com.greensock.*;									// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	
	public class Bullet extends Sprite
	{
		private var swfStage:Stage;
		public var bulletMC:MovieClip;
		
		public function Bullet(swfStage:Stage, invaderMC:MovieClip)
		{
			this.swfStage		= swfStage;
			this.bulletMC		= new InvaderBullet();
			bulletMC.x			= invaderMC.x + invaderMC.parent.x + (invaderMC.width/2);	// TODO: move registration point of alien
			bulletMC.y			= invaderMC.y + invaderMC.parent.y + (invaderMC.height/2);
			
			shoot();
		}
		
		public function shoot():void
		{
			swfStage.addChild( bulletMC );
			
			// Tween time is dynamic, based upon how far the bullet has to go
			var distance 	= (swfStage.stageHeight-60) - bulletMC.y;
			TweenMax.to( bulletMC, distance/212, {y:swfStage.stageHeight-60, ease:Linear.easeNone, onUpdate:playerHitTest, onUpdateParams:[bulletMC], onComplete:deleteBullet, onCompleteParams:[bulletMC]} );
		}
		
		private function playerHitTest(bulletMC):void
		{
			var player = swfStage.getChildByName("playerMC");
			if (player) { 
				if (bulletMC.hitTestObject(player)) {
					deleteBullet(bulletMC);
					player.gotoAndPlay("blowUp");
				}
			}
		}
		
		private function deleteBullet(bulletMC):void
		{
			TweenMax.killChildTweensOf(bulletMC);
			swfStage.removeChild(bulletMC);
		}
	}
}