package 
{
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Input;
	import flash.system.System;
	import net.flashpunk.Engine;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.utils.Key;
	import net.flashpunk.graphics.Text;
	import splash.Splash;
	
	/**
	 * ...
	 * @author azrafe7
	 */
	[SWF(width = "640", height = "480")]
	public class Main extends Engine 
	{
		
		public function Main():void 
		{
			super(640, 480, 60, false);
			
			FP.world = new World;
		}
		
		override public function init():void 
		{
			super.init();
			
			var s:Splash = new Splash();
			FP.world.add(s);
			s.start();
		}
		
		override public function update():void
		{
			super.update();
			
			// press ESCAPE to exit debug player
			if (Input.check(Key.ESCAPE)) {
				System.exit(1);
			}
		}
	}
}