package;

import imgui.ImGui;
import lime.graphics.RenderContext;
import lime.app.Application;

class Main extends Application {
	public function new() {
		super();
		trace("Hello World");
	}

	override function onWindowCreate() {
		Im.init();
	}

	public override function render(context:RenderContext):Void {
		switch (context.type) {
			case OPENGL, OPENGLES, WEBGL:
				var gl = context.webgl;

				gl.clearColor(0.75, 1, 0, 1);
				gl.clear(gl.COLOR_BUFFER_BIT);

				Im.newFrame();
				ImGui.showDemoWindow();
				Im.endFrame();

			default:
		}
	}
}
