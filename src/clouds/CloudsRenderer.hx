package clouds;
import haxe.remoting.FlashJsConnection;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import ru.stablex.ui.misc.ColorUtils;

/**
 * ...
 * @author IAP
 */
class CloudsRenderer extends Sprite {

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE,init);
	}
	/*
	We are declaring variables that we need. 'display' is a Sprite container that will contain all elements of our animation which are:

	perlinData - a BitmapData to which a Perlin noise will be applied as well as a ColorMatrixFilter, cmf;
	perlinBitmap - a Bitmap corresponding to perlinData;
	blueBackground - a Shape with sky-colored fill.

	In addition, 'display' contains the text 'flash&math' which is stored in the Library as a MovieClip and linked to AS3 under the name of mcText.
	*/
	var display:Sprite;
	var perlinData:BitmapData;
	var perlinBitmap:Bitmap;
	var cmf:ColorMatrixFilter;
	var blueBackground:Shape;
	var skyColor:Int;
	/*
	The dimensions of display and of other objects.
	*/
	var displayWidth:Int;
	var displayHeight:Int;
	/*
	The remaining variables will serve as parameters of our Perlin noise. We explain their meaning later on this page.
	*/
	var periodX:Float;
	var periodY:Float;
	var seed:Int;
	var offsets:Array<Point>;
	var numOctaves:Int;
	var bevelFilter:DropShadowFilter;
	var bevelFilter2:DropShadowFilter;
	var blurFilter:BlurFilter;

	function init(e:Event) {
		var i:Int;
		display = new Sprite();
		this.addChild(display);
		display.x=0;
		display.y=0;
		displayWidth = stage.stageWidth;
		displayHeight = stage.stageHeight;

		//periodX, periodY, numOctaves determine properties of our Perlin noise and
		//the appearance of the clouds. Smaller values for periods will result in
		//higher horizontal or vertical frequencies which will produce smaller,
		//more frequent clouds. Smaller Float of octaves, numOctaves, will give clouds
		//not as good-looking but much more CPU friendly, especially for larger images.
		//Perlin noise is very CPU Intensive. For example, by setting periodX=150,
		// periodY=60, numOctaves=3, you will get a nice looking sky
		//that will run at much higher FPS.
		perlinData = new BitmapData(displayWidth,displayHeight,true);
		perlinBitmap = new Bitmap(perlinData);

		periodX=90;
		periodY=90;
		numOctaves = 5;

		//skyColor is the color of the blue background. You can easily change it
		//on the next line to a different solid fill. A few lines below, you can also
		//replace fill by a gradient fill and create a gradient sky.

		skyColor = 0x2255AA;

		//We are creating a BitmapData object that supports transparency of pixels
		//(parameter 'true') and a Bitmap with that BitmapData. We will apply
		//a grayscale Perlin noise to perlinData. To our grayscale Perlin noise,
		//we will apply a ColorMatrixFilter, cmf. This filter makes darker pixels
		//in perlinData more transparent so blue sky shows through.
		//After applying cmf, some pixels are more transparent than others but they
		//are all turned to white. (See explanations later on the page.)


		blurFilter = new BlurFilter(7, 7,3);



		blueBackground = new Shape();
		blueBackground.graphics.beginFill(skyColor);
		blueBackground.graphics.drawRect(0,0,displayWidth,displayHeight);
		blueBackground.graphics.endFill();
		display.addChild(blueBackground);
		display.addChild(perlinBitmap);
		//We choose randomly a 'seed' used in Perlin noise and create the offsets array.
		Params.seed = Math.round(Math.random()*10000);
		offsets = new Array<Point>();
		for (i in 0 ... 10) {
			offsets.push(new Point());
		}
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onEnterFrame(evt:Event) {
		var i:Int;
		//Update offsets of the Perlin noise which moves the clouds.
		for (i in  0...10) {
			offsets[i].x += 1;
			offsets[i].y += 0.2;
		}

		defineFilters();
		//We create a grayscale Perlin noise in perlinData and apply
		//the ColorMatrixFilter, cmf, to it.
		//seed += 1;
		perlinData.perlinNoise(Params.period,Params.period,Params.octaves,Params.seed,false,Params.fractal,1,true,offsets);
		thresholdImage();
		perlinData.applyFilter(perlinData, perlinData.rect, new Point(), bevelFilter );
		perlinData.applyFilter(perlinData, perlinData.rect, new Point(), bevelFilter2 );
		perlinData.applyFilter(perlinData, perlinData.rect, new Point(), cmf);
		perlinData.applyFilter(perlinData, perlinData.rect, new Point(), blurFilter );
		}

		function defineFilters() {
			bevelFilter =  new DropShadowFilter(20, -Params.shade, 0, 1, 30, 30, 1, 1, true);
			bevelFilter2 = new DropShadowFilter(25,  Params.shade, 0xffffff, 1,30, 30, 1, 1, true);
			cmf = new ColorMatrixFilter([2, 0, 0, 0, 255,
									 0, 2, 0, 0, 255,
									 0, 0, 2, 0, 255,
									 1, 0, 0, 0, 0]);
		}

		function thresholdImage() {
			var bmd2:BitmapData = new BitmapData(perlinData.width, perlinData.height , true, 0xFFCCCCCC);
			var pt:Point = new Point(0, 0);
			var rect:Rectangle = new Rectangle(0, 0, perlinData.width, perlinData.height);
			var threshold:Int =  getThreshold();
			var color:Int = 0xE10229; //Replacement color (white)
			var maskColor:Int = 0xffffff; //What channels to affect (this is the default).
			perlinData.threshold(perlinData, rect, pt, "<", threshold, color, maskColor, true);
		}

		function getThreshold():Int {
			var clr = ColorUtils.colorToHexString(Params.threshold);
			var ret = "0x" + clr + clr + clr;
			return Std.parseInt(ret);
		}
}