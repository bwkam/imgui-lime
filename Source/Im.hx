#if cpp
import lime.app.Application;
import imguicpp.ImGui;
import sdl.SDL;

@:headerInclude("./../imgui/backends/imgui_impl_sdl2.h")
class ImGuiImplSDL {
	@:keep public static function bind() {}
}

@:headerInclude("./../imgui/backends/imgui_impl_opengl3.h")
class ImGuiImplOpenGl3 {
	@:keep public static function bind() {}
}

class Im {
	static var framePending:Bool = false;

	static var didSetTextureFilter:Bool = false;

	public static function init():Void {
		ImGuiImplSDL.bind();
		ImGuiImplOpenGl3.bind();

		ImGui.createContext();
		ImGui.styleColorsDark();

		var glContext = SDL.GL_GetCurrentContext();
		var window = SDL.GL_GetCurrentWindow();

		untyped __cpp__('ImGui_ImplSDL2_InitForOpenGL({0}, {1})', window, glContext);

		#if (ios || tvos || android)
		untyped __cpp__('ImGui_ImplOpenGL3_Init("#version 300 es")');
		#else
		untyped __cpp__('ImGui_ImplOpenGL3_Init("#version 120")');
		#end
	}

	public static function newFrame():Void {
		var window = SDL.GL_GetCurrentWindow();

		untyped __cpp__('ImGui_ImplOpenGL3_NewFrame()');
		untyped __cpp__('ImGui_ImplSDL2_NewFrame({0})', window);

		ImGui.newFrame();

		framePending = true;
	}

	public static function endFrame():Void {
		if (!framePending)
			return;
		framePending = false;

		ImGui.endFrame();
		ImGui.render();

		untyped __cpp__('ImGui_ImplOpenGL3_RenderDrawData({0})', ImGui.getDrawData());

		var io = ImGui.getIO();
		// clay.Clay.app.runtime.skipKeyboardEvents = io.wantCaptureKeyboard;
		// clay.Clay.app.runtime.skipMouseEvents = io.wantCaptureMouse;
	}
}
#end
