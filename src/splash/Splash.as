package splash 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.MultiVarTween;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.World;
	
	/**
	 * This object displays the FlashPunk splash screen.
	 */
	public class Splash extends Entity
	{
		/**
		 * Embedded graphics.
		 */
		[Embed(source = 'data/lines.png')] private const SPLASH_LINES:Class;
		[Embed(source = 'data/cogs.png')] private const SPLASH_COGS:Class;
		[Embed(source = 'data/powered.png')] private const SPLASH_POWERED:Class;
		[Embed(source = 'data/flashpunk.png')] private const SPLASH_FLASHPUNK:Class;
		
		/**
		 * Image objects.
		 */
		public var list:Graphiclist;
		public var lines:Image;
		public var cogs:Spritemap = new Spritemap(SPLASH_COGS, 68, 41);
		public var powered:Image = new Image(SPLASH_POWERED);
		public var poweredMask:BitmapData;
		public var flashpunkText:Spritemap = new Spritemap(SPLASH_FLASHPUNK, 51, 12);
		public var fadeOverlay:Image = Image.createRect(FP.width, FP.height, 0);
		
		/**
		 * Tween information.
		 */
		public var fadeTween:NumTween = new NumTween(fadeLogoEnd);
		
		/**
		 * Splash constructor
		 * 
		 * @param	color			foreground color
		 * @param	bgColor			background color
		 * @param	fadeTime		duration of fade
		 * @param	logoTime		duration of logo
		 * @param	poweredByTime	duration of "powered by"
		 * @param	scale			splash scale
		 * @param	xPercent		position at which place the splash (percent of screen width)
		 * @param	yPercent		position at which place the splash (percent of screen height)
		 */
		public function Splash(color:uint = 0xf03060, bgColor:uint = 0x252525, fadeTime:Number = 1, logoTime:Number = 4.5, poweredByTime:Number = .3, scale:Number = 1, xPercent:Number = .5, yPercent:Number = .6) 
		{
			_scale = scale;
			
			// Set the entity information.
			x = FP.width * xPercent;
			y = FP.height * yPercent - FP.height * .02 * scale;
			
			// Create the lines image.
			var data:BitmapData = new BitmapData(FP.width, FP.height, false, 0x353535),
				g:Graphics = FP.sprite.graphics;
			g.clear();
			g.beginGradientFill(GradientType.RADIAL, [0, 0], [1, 0], [0, 255]);
			g.drawCircle(0, 0, 100);
			FP.matrix.identity();
			FP.matrix.scale(FP.width / 200 * scale, FP.height / 200 * scale);
			FP.matrix.translate(FP.screen.width / 2, FP.screen.height / 2); //(x, y);
			data.draw(FP.sprite, FP.matrix);
			g.clear();
			g.beginBitmapFill((new SPLASH_LINES).bitmapData);
			g.drawRect(0, 0, FP.width, FP.height);
			data.draw(FP.sprite);
			lines = new Image(data);
			
			// Add graphics
			graphic = new Graphiclist(cogs, flashpunkText, powered, lines, fadeOverlay);
			
			// Store colors
			_color = color;
			_bgColor = bgColor;
			FP.screen.color = 0;
			
			// Set the lines properties.
			lines.blend = BlendMode.SUBTRACT;
			lines.smooth = true;
			lines.x -= x;
			lines.y -= y;
			lines.visible = true;
			
			// Set the cogs animation properties.
			cogs.scale = scale;
			cogs.visible = false;
			cogs.color = color;
			cogs.smooth = true;
			cogs.originX = cogs.width / 2;
			cogs.originY = cogs.height / 2;
			cogs.add("shoot", FP.frames(0, cogs.frameCount - 1), 8);
			
			// Set "FlashPunk" animation properties
			flashpunkText.scale = scale;
			flashpunkText.visible = false;
			flashpunkText.color = color;
			flashpunkText.smooth = true;
			flashpunkText.originX = flashpunkText.width / 2;
			flashpunkText.originY = flashpunkText.height / 2;
			flashpunkText.x = 0;
			flashpunkText.y += (cogs.scaledHeight + flashpunkText.scaledHeight) * .6;
			flashpunkText.add("scribble", FP.frames(0, flashpunkText.frameCount - 1), 20, false);
			
			// Set "powered by" properties
			powered.scale = scale;
			powered.visible = false;
			powered.color = color;
			powered.smooth = true;
			powered.alpha = 1;
			powered.originX = powered.width / 2;
			powered.originY = powered.height / 2;
			powered.x = 0;
			powered.y = powered.originY + cogs.scaledHeight * .3;
			
			// Mask for "powered by" overlay effect
			poweredMask = new BitmapData(lines.width, lines.height, true, 0x00000000);
			powered.render(poweredMask, new Point(x, y), FP.zero);

			// Set the fade cover properties.
			fadeOverlay.x -= x;
			fadeOverlay.y -= y;
			fadeOverlay.alpha = fadeTween.value = 1;
			
			// Set the timing properties.
			_fadeTime = fadeTime;
			_logoTime = logoTime;
			_poweredByTime = poweredByTime;
			
			// Add the tweens.
			addTween(fadeTween);
			
			// Make invisible until you start it.
			visible = false;
		}
		
		/**
		 * Start the splash screen.
		 * 
		 * @param onComplete 	Function callback or World object to execute at splash end
		 */
		public function start(onComplete:* = null):void
		{
			_onComplete = onComplete;
			visible = true;
			// fade in/out "powered by"
			if (_poweredByTime > 0) {
				powered.visible = true;
				powered.alpha = 1;
				lines.drawMask = poweredMask;
				FP.tween(fadeOverlay, { alpha:0 }, _fadeTime, { ease:Ease.expoIn, complete: 
					function():void { 
						FP.tween(fadeOverlay, { alpha:1 }, _fadeTime, { delay:_fadeTime, ease:Ease.expoOut, complete:
							function ():void 
							{
								lines.drawMask = null;
								powered.visible = false;
								FP.screen.color = _bgColor;
								fadeInLogo();
							}
						});
					} 
				}); 
			}
			else {	// no "powered by" is shown
				FP.screen.color = _bgColor;
				fadeInLogo();
			}
		}
		
		/**
		 * Update the splash screen.
		 */
		override public function update():void 
		{
						
			// fade in/out alpha control.
			if (fadeTween.active) fadeOverlay.alpha = fadeTween.value;
			
			// slow down text animation for 'PUNK'
			flashpunkText.rate = (flashpunkText.frame >= 39 ? .3 : 1);
			
			// spit a heart
			if (cogs.frame == 3 && !_spit) {
				FP.world.add(new SplashHeart(x + cogs.scaledWidth * .6, y - cogs.scaledHeight * .6, _scale, _color));
				_spit = true;
			}
			if (cogs.frame != 3) _spit = false;
			
		}
		
		/**
		 * Show screen center and splash position
		 *
		override public function render():void 
		{
			super.render();
			Draw.circle(FP.screen.width / 2, FP.screen.height / 2, 2);
			Draw.circlePlus(x, y, 2, 0xff0000, .2, false);
		}*/
		
		/**
		 * When the fade tween completes.
		 */
		private function fadeLogoEnd():void
		{
			if (fadeTween.value != 0) splashEnd();
		}
		
		/**
		 * Fades the splash screen in.
		 */
		private function fadeInLogo():void
		{	
			cogs.visible = true;
			fadeTween.tween(1, 0, _fadeTime, Ease.expoIn);
			FP.alarm(_fadeTime * .8, function ():void {	// wait a bit before animating the cogs
				flashpunkText.visible = true;
				cogs.play("shoot", true);
				flashpunkText.play("scribble", true);
			});
			// set fade out to start after some time
			FP.alarm(_logoTime + _fadeTime * 2, function ():void {
				fadeTween.tween(0, 1, _fadeTime, Ease.expoOut);
			});
		}
				
		/**
		 * When the splash screen has completed.
		 */
		private function splashEnd():void
		{
			cogs.visible = flashpunkText.visible = false;
			if (_onComplete == null) return;
			else if (_onComplete is Function) _onComplete();
			else if (_onComplete is World) FP.world = _onComplete;
			else throw new Error("The onComplete parameter must be a Function callback or World object.");
		}
				
		/**
		 * Private variables
		 */
		private var _spit:Boolean = false;
		private var _scale:Number;
		private var _bgColor:int;
		private var _color:int;
		private var _fadeTime:Number;
		private var _logoTime:Number;
		private var _poweredByTime:Number;
		private var _onComplete:*;
	}
}