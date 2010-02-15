package {
	import flash.display.*;
	import com.greensock.*;							// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	
	public class InvaderBullet extends Sprite
	{
		private var _dc:SpaceInvaders;				// Instance of the Document Class
		public var  bulletMC:MovieClip;
		
		public function InvaderBullet(invaderMC:MovieClip)
		{
			_dc 			= SpaceInvaders.instance;
			this.bulletMC	= new InvaderBulletMC();
			bulletMC.x		= invaderMC.x + invaderMC.parent.x + (invaderMC.width/2);
			bulletMC.y		= invaderMC.y + invaderMC.parent.y + (invaderMC.height/2);
			shoot();
		}
		
		public function shoot():void
		{
			_dc.addChild( bulletMC );
			// Tween time is dynamic, based upon how far the bullet has to go
			var distance = 440 - bulletMC.y;	
			TweenMax.to( bulletMC, distance/212, {y:440, ease:Linear.easeNone, onUpdate:playerHitTest, onComplete:deleteBullet} );
		}
		
		private function playerHitTest():void
		{
			if (bulletMC.hitTestObject(_dc.player.playerMC)) {
				deleteBullet();
				_dc.playerHit();	// Fire the method in the Document Class
			}
		}
		
		public function deleteBullet():void
		{
			TweenMax.killTweensOf(bulletMC);
			
			var toDelete; // Remove this bullet from the document class invaderBullets array
			_dc.invaderBullets.forEach(function(_dcBullet, index){
				if (_dcBullet.bulletMC === this.bulletMC) toDelete = index;
			});
			_dc.invaderBullets.splice(toDelete, 1);
			
			if (bulletMC.parent) _dc.removeChild(bulletMC);
		}
	}
}