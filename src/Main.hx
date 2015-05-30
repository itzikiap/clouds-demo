package;

import openfl.display.Sprite;
import openfl.Lib;
import clouds.CloudsRenderer;
import ru.stablex.ui.UIBuilder;

/**
 * ...
 * @author IAP
 */

class Main extends Sprite {

	public function new() {
		super();
		addChild(new CloudsRenderer());
		/*Toolkit.theme = new GradientTheme();
		Toolkit.init();
		Toolkit.openFullscreen(function(root:Root) {
			root.addChild(new Sliders().view);
		});*/



		 UIBuilder.init();
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");

		addChild( UIBuilder.buildFn('uipanel.xml')() );
	}

}
