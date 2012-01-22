package splash 
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Spritemap;
	
	/**
	 * ...
	 * @author azrafe7
	 */
	public class SplashHeart extends Entity 
	{
		
		[Embed(source = 'data/heart.png')] private const SPLASH_HEART:Class;

		public var heart:Spritemap = new Spritemap(SPLASH_HEART, 11, 9);

		
		public function SplashHeart(x:Number, y:Number, scale:Number, color:Number) 
		{
			heart.x = x;
			heart.y = y;
			heart.scale = scale;
			heart.visible = true;
			heart.color = color;
			heart.smooth = true;
			heart.originX = heart.width / 2;
			heart.originY = heart.height / 2;
			heart.add("pop", FP.frames(0, heart.frameCount - 1).concat(heart.frameCount-1), 10, false);
			heart.play("pop");
			addGraphic(heart);
			_spdX = FP.random * 150 + 60;
			_spdY = FP.random * 130 + 25;
			_slow = FP.random * 30 + 10;
			layer = 1;
			FP.alarm(1, function():void { _fade = true; } );	// fade after one second
		}
		
		override public function update():void 
		{
			super.update();
			heart.x += _spdX * FP.elapsed;
			heart.y -= _spdY * FP.elapsed;
			
			if (_spdX > 0) _spdX -= _slow;
			else _spdX = 0;

			if (_fade) {
				heart.alpha *= .9;
			}
			if (heart.y < 0) {
				FP.world.remove(this);
			}
		}
		
		private var _fade:Boolean = false;
		private var _spdX:Number;
		private var _spdY:Number;
		private var _slow:Number;
	}

}