package {
	import flash.display.*;
	
	public class Defence
	{
		private var swfStage:Stage;
		private var defencesLayer:MovieClip;
		public var defenceMC:MovieClip;
		public var blocks:Array;						// Each defence barrier is made up of smaller movieclip blocks
		
		public function Defence(swfStage:Stage, defencesLayer:MovieClip)
		{
			this.swfStage		= swfStage;
			this.defencesLayer	= defencesLayer;
			this.defenceMC		= new DefenceBlock();
			
			this.blocks			= new Array();
			for (var i=0; i<defenceMC.numChildren; i++) {
				blocks.push(defenceMC.getChildAt(i));
			}
		}
		
		public function defenceHit(defence, player):void
		{
			blocks.forEach(function(block, index){
				if (player.bulletMC.hitTestObject(block)) {
					player.deleteBullet();
					blockHit(block);
				}
			});
		}
		
		public function blockHit(blockMC):void
		{
			if (blockMC.currentFrame < 4) blockMC.nextFrame();
			else deleteBlock(blockMC);
		}
		
		public function deleteBlock(blockMC:MovieClip):void
		{
			defenceMC.removeChild(blockMC);
		}
	}
}