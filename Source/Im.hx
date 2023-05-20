#if cpp
import lime.app.Application;
import imguicpp.ImGui;
import sdl.SDL;
#elseif js
import js.html.CanvasElement;
import js.Browser;
import haxe.Timer;
import imguijs.ImGui;
#end

#if cpp
@:headerInclude("./../imgui/backends/imgui_impl_sdl2.h")
class ImGuiImplSDL {
	@:keep public static function bind() {}
}

@:headerInclude("./../imgui/backends/imgui_impl_opengl3.h")
class ImGuiImplOpenGl3 {
	@:keep public static function bind() {}
}
#end

#if cpp
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
#elseif js
class Im {
	static var ImGui_Impl(get, never):Dynamic;

	inline static function get_ImGui_Impl():Dynamic
		return untyped window.ImGui_Impl;

	static var io:ImGuiIO = null;

	static var framePending:Bool = false;

	public static function init():Void {
		loadImGui();
	}

	static function loadScript(src:String, done:Bool->Void) {
		var didCallDone = false;

		var script = js.Browser.document.createScriptElement();
		script.setAttribute('type', 'text/javascript');
		script.addEventListener('load', function() {
			if (didCallDone)
				return;
			didCallDone = true;
			done(true);
		});
		script.addEventListener('error', function() {
			if (didCallDone)
				return;
			didCallDone = true;
			done(false);
		});
		script.setAttribute('src', src);

		js.Browser.document.head.appendChild(script);
	}

	static function loadImGui() {
		loadScript('./imgui.umd.js', function(_) {
			loadScript('./imgui_impl.umd.js', function(_) {
				Reflect.field(untyped window.ImGui, 'default')().then(function() {
					initImGui();
				}, function() {
					trace('Failed to load ImGui bindings');
				});
			});
		});
	}

	static function initImGui() {
		var canvas:CanvasElement = cast Browser.document.getElementById("myCanvas");

		ImGui.createContext();
		ImGui.styleColorsDark();
		ImGui_Impl.Init(canvas);

		io = ImGui.getIO();

	}

	public static function newFrame():Void {
		ImGui_Impl.NewFrame(Timer.stamp() * 1000);
		ImGui.newFrame();

		framePending = true;
	}

	public static function endFrame():Void {
		if (!framePending)
			return;
		framePending = false;

		ImGui.endFrame();
		ImGui.render();

		ImGui_Impl.RenderDrawData(ImGui.getDrawData());

		// clay.Clay.app.runtime.skipKeyboardEvents = io.wantCaptureKeyboard;
		// clay.Clay.app.runtime.skipMouseEvents = io.wantCaptureMouse;
	}
}
#end
