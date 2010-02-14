package {
	import flash.display.*;
	import com.greensock.*;							// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	
	public class InvaderBullet extends Sprite
	{
		private var _dc:SpaceInvaders;				// Instance of the Document Class
		public var bulletMC:MovieClip;
		
		public function InvaderBullet(invaderMC:MovieClip)
		{
			_dc 			= SpaceInvaders.instance;
			this.bulletMC	= new InvaderBulletMC();
			bulletMC.x		= invaderMC.x + invaderMC.parent.x + (invaderMC.width/2);	// TODO: move registration point of alien
			bulletMC.y		= invaderMC.y + invaderMC.parent.y + (invaderMC.height/2);
			shoot();
		}
		
		public function shoot():void
		{
			_dc.addChild( bulletMC );
			// Tween time is dynamic, based upon how far the bullet has to go
			var distance = (_dc.stage.stageHeight-60) - bulletMC.y;	
			TweenMax.to( bulletMC, distance/212, {y:_dc.stage.stageHeight-60, ease:Linear.easeNone, onUpdate:playerHitTest, onComplete:deleteBullet} );
		}
		
		private function playerHitTest():void
		{
			if (bulletMC.hitTestObject(_dc.player.playerMC)) {
				
				_dc.moveInvadersTimer.stop();
				_dc.invaderShootTimer.stop();
				
				deleteBullet();
				_dc.player.playerMC.gotoAndPlay("blowUp");
			}
		}
		
		public function deleteBullet():void
		{
			TweenMax.killTweensOf(bulletMC);
			
			// Remove this bullet from the document class invaderBullets array
			var toDelete;
			_dc.invaderBullets.forEach(function(_dcBullet, index){
				if (_dcBullet.bulletMC === bulletMC) toDelete = index;
			});
			_dc.invaderBullets.splice(toDelete, 1);
			
			if (bulletMC.parent) {
				_dc.removeChild(bulletMC);
			}
		}
	}
}