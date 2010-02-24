package {
	import flash.display.*;
	import flash.geom.Point;
	import flash.media.Sound;
	import com.greensock.*;									// Greensock tweening library	-> see http://blog.greensock.com/
	import com.greensock.easing.*;
	import InvaderBullet;
	
	public class Invader extends MovieClip
	{
		private var swfStage:Stage;
		private var invadersLayer:MovieClip;
		public var  invaderMC:MovieClip;
		public var  points:uint;
		public var  row:uint;
		public var  col:uint;
		public var  shooter:Boolean;
		public var  bulletMC:MovieClip;
		
		public function Invader(swfStage:Stage, row:uint, col:uint, invadersLayer:MovieClip)
		{
			this.swfStage		= swfStage;
			this.invadersLayer	= invadersLayer;
			this.row			= row;
			this.col			= col;
			
			if (row == 5) { this.shooter = true; }
			
			switch(row) {
				case 1:
					invaderMC		= new InvaderMC_40();
					points			= 40;
					break;
				case 2:
				case 3:
					invaderMC		= new InvaderMC_20();
					points			= 20;
					break;
				case 4:
				case 5:
					invaderMC		= new InvaderMC_10();
					points			= 10;
					break;
			}
		}
		
		public function animate():void
		{
			switch(invaderMC.currentFrame) 
			{
				case 1:
					invaderMC.gotoAndStop(2);
					break;
				case 2:
					invaderMC.gotoAndStop(1)
					break;
			}
		}
		
		public function shootBullet():Object
		{
			var bulletObj	= new InvaderBullet(invaderMC);
			return bulletObj;
		}
		
		public function explode():void
		{
			var explosion	= new InvaderExplosion();
			explosion.x		= invaderMC.x + (explosion.width / 2);
			explosion.y		= invaderMC.y + (explosion.height / 2);
			
			invadersLayer.addChild(explosion);
			TweenMax.from(explosion, 0.2, {scaleX:0, scaleY:0});
			TweenMax.to(explosion, 0.6, {delay:0.05, alpha:0, onComplete:function(){invadersLayer.removeChild(explosion);}});
			
			var snd:Sound = new InvaderHitWav();
			snd.play();
			
			invadersLayer.removeChild(invaderMC);
		}
		
		public function deleteInvader():void
		{
			invadersLayer.removeChild(invaderMC);
		}
	}
}