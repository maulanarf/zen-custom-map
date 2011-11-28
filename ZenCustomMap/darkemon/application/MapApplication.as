package darkemon.application {
	
	import darkemon.Global;
	import darkemon.display.Arrow;
	import darkemon.display.MainScene;
	import darkemon.display.Node;
	import darkemon.events.CommunicatorEvent;
	import darkemon.events.NodeEvent;
	import darkemon.events.TabBarEvent;
	import darkemon.events.ToolBarEvent;
	import darkemon.net.Communicator;
	import darkemon.ui.ControlPanel;
	import darkemon.ui.ExtTabBar;
	import darkemon.ui.ImageLibraryDialog;
	import darkemon.ui.MapSettingsDialog;
	import darkemon.ui.NodeSettingsDialog;
	import darkemon.ui.ToolBar;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.ToggleButton;
		
	public class MapApplication extends Application {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var refreshBtn:Button = new Button();
		private var searchBtn:ToggleButton = new ToggleButton();
		
		private var tabBar:ExtTabBar = new ExtTabBar();
		private var controlPanel:ControlPanel = null;
		private var toolBar:ToolBar = ToolBar.getInstance();
		private var scene:MainScene = new MainScene();
		
		private var global:Global;
		private var comm:Communicator = new Communicator();
		
		[Embed(source="assets/search_small_icon.png")]
		private var searchIcon:Class;
		
		[Embed(source="assets/refresh_icon.gif")]
		private var refreshIcon:Class;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function MapApplication() {
			frameRate = 60;
			setStyle("backgroundColor", "white");
			
			searchBtn.width = searchBtn.height = 24;
			searchBtn.toolTip = "Search panel";
			searchBtn.setStyle("icon", searchIcon);
			
			refreshBtn.width = refreshBtn.height = 24;
			refreshBtn.toolTip = "Refresh events";
			refreshBtn.setStyle("icon", refreshIcon);
					
			addEventListener(FlexEvent.CREATION_COMPLETE, creationHandler);
			
			// Buttons listener.
			searchBtn.addEventListener(MouseEvent.CLICK, btnsHandler);
			refreshBtn.addEventListener(MouseEvent.CLICK, btnsHandler);
			
			// Area hit listeners.
			scene.addEventListener(MouseEvent.MOUSE_OVER, sceneMouseOverOutListener);
			scene.addEventListener(MouseEvent.MOUSE_OUT, sceneMouseOverOutListener);
			scene.addEventListener(NodeEvent.OPEN_PREF, nodeEventListener);
			scene.addEventListener(NodeEvent.OPEN_LIBRARY, nodeEventListener);
			scene.addEventListener(NodeEvent.OPEN_EVENTS, nodeEventListener);
			scene.addEventListener(NodeEvent.OPEN_SUBMAP, nodeEventListener);
			
			// ToolBar listeners.
			toolBar.addEventListener(ToolBarEvent.MOVE_MAP, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.ADD_NODE, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.DEL_NODE, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.MOVE_NODE, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.ADD_EDGE, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.DEL_EDGE, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.OPEN_PREF, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.SCALE_MAP, toolBarListener);
			toolBar.addEventListener(ToolBarEvent.SAVE_DATA, toolBarListener);
			
			// TabBar listeners.
			tabBar.addEventListener(TabBarEvent.SELECT_TAB, tabBarListener);
			tabBar.addEventListener(TabBarEvent.ADD_TAB, tabBarListener);
			tabBar.addEventListener(TabBarEvent.CHANGE_LABEL, tabBarListener);
			tabBar.addEventListener(TabBarEvent.CLOSE_TAB, tabBarListener);
		}
	
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function creationHandler(e:FlexEvent):void 
		{
			global = new Global(scene, tabBar);
			controlPanel = new ControlPanel(global);
			
			// TabBar constraints.
			tabBar.setConstraintValue("left", 0);
			tabBar.setConstraintValue("right", 0);
			tabBar.setConstraintValue("top", 0);
			// ToolBar constraints.
			toolBar.setConstraintValue("left", 5);
			toolBar.setConstraintValue("top", tabBar.height+5);
			// Search button constraints.
			searchBtn.setConstraintValue("right", 5);
			searchBtn.setConstraintValue("top", tabBar.height+5);
			// Refresh button constraints.
			refreshBtn.setConstraintValue("right", 5);
			refreshBtn.setConstraintValue("top", tabBar.height+searchBtn.height+10);
			// Control panel constraints.
			controlPanel.setConstraintValue("left", 0);
			controlPanel.setConstraintValue("right", 0);
			controlPanel.setConstraintValue("bottom", 0);
			// MainScene constraints.
			scene.setConstraintValue("left", 0);
			scene.setConstraintValue("right", 0);
			scene.setConstraintValue("top", 0);
			scene.setConstraintValue("bottom", 0);
									
			addElement(scene);
			addElement(tabBar);
			addElement(toolBar);
			addElement(searchBtn);
			addElement(refreshBtn);
			
			toolBar.dispatchEvent(new ToolBarEvent(ToolBarEvent.MOVE_MAP));
			comm.addEventListener(CommunicatorEvent.TABS_LOADED, communicatorHandler);
			comm.addEventListener(CommunicatorEvent.MAP_LOADED, communicatorHandler);
			comm.addEventListener(CommunicatorEvent.MAP_SAVED, communicatorHandler);

			// Load tabs config.
			Arrow.busySystem = true;
			comm.loadTabs();
		}
		
		private function enterFrameListener(e:Event):void {
			global.drawEdges();
		}
		
		private function sceneMouseOverOutListener(e:MouseEvent):void {
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:
					Arrow.show();
					break;
				case MouseEvent.MOUSE_OUT:
					Arrow.hide();
					break;
			}
		}
		
		private function btnsHandler(e:MouseEvent):void {
			switch(e.target) {
				case searchBtn:
					if(!searchBtn.selected) {
						controlPanel.resetResult();
						removeElement(controlPanel);
					} else {
						addElement(controlPanel);
					}
					break;
				case refreshBtn:
					global.dataProvider.updateEventsImmediate();
					break;
			}
		}
		
		private function toolBarListener(e:ToolBarEvent):void {
			switch(e.type)
			{
				case ToolBarEvent.MOVE_MAP:
					scene.draggable = true;
					scene.mouseChildren = false; // disable any action for nodes
					global.actionMode = Global.NONE_MODE;
					Arrow.mode = Arrow.GRAB;
					break;
				case ToolBarEvent.ADD_NODE:
					scene.draggable = false;
					scene.mouseChildren = false; // disable any action for nodes
					global.actionMode = Global.ADD_NODE_MODE;
					Arrow.mode = Arrow.ADD;
					break;
				case ToolBarEvent.DEL_NODE:
					scene.draggable = false;
					scene.mouseChildren = true;
					global.actionMode = Global.DEL_NODE_MODE;
					Arrow.mode = Arrow.DELETE;
					break;
				case ToolBarEvent.MOVE_NODE:
					scene.draggable = false;
					scene.mouseChildren = true;
					global.actionMode = Global.NONE_MODE;
					Arrow.mode = Arrow.NONE;
					break;
				case ToolBarEvent.ADD_EDGE:
					scene.draggable = false;
					scene.mouseChildren = true;
					global.actionMode = Global.ADD_EDGE_MODE;
					Arrow.mode = Arrow.SELECT_FIRST;
					break;
				case ToolBarEvent.DEL_EDGE:
					scene.draggable = false;
					scene.mouseChildren = true;
					global.actionMode = Global.DEL_EDGE_MODE;
					Arrow.mode = Arrow.SELECT_FIRST;
					break;
				case ToolBarEvent.OPEN_PREF:
					MapSettingsDialog.show(this, global);
					break;
				case ToolBarEvent.SCALE_MAP:
					scene.zoom = e.mapScale;
					break;
				case ToolBarEvent.SAVE_DATA:
					comm.saveMap(tabBar.selectedTabUid, 
						global.getMapSourceXML());
					break;
			}
		}
		
		private function nodeEventListener(e:NodeEvent):void {
			var n:Node = e.target as Node;
			switch(e.type)
			{
				case NodeEvent.OPEN_PREF:
					NodeSettingsDialog.show(this, n, global, tabBar);
					break;
				case NodeEvent.OPEN_LIBRARY:
					ImageLibraryDialog.show(this, n, true);
					break;
				case NodeEvent.OPEN_EVENTS:
					var url:String = "/zport/dmd/Devices"+
						n.zenClass+"/devices/"+n.nodeName+
						"/devicedetail#deviceDetailNav:device_events";
					navigateToURL(new URLRequest(url), "_blank");
					break;
				case NodeEvent.OPEN_SUBMAP:
					if(!tabBar.hasTabUid(n.submapUid)) {
						Alert.show("This map is not exist!", "Note");
					} else {
						tabBar.selectedTabUid = n.submapUid;
					}
					break;
			}
		}
		
		private function tabBarListener(e:TabBarEvent):void 
		{
			switch(e.type)
			{
				case TabBarEvent.SELECT_TAB:
					Arrow.busySystem = true;
					comm.loadMap(e.tabUid);
					break;
				case TabBarEvent.ADD_TAB:
					Arrow.busySystem = true;
					comm.loadMap(e.tabUid);
					comm.saveTabs(global.getTabsSourceXML());
					break;
				case TabBarEvent.CHANGE_LABEL:
					comm.saveTabs(global.getTabsSourceXML());
					break;
				case TabBarEvent.CLOSE_TAB:
					comm.saveTabs(global.getTabsSourceXML());
					comm.deleteMap(e.tabUid);
					break;
			}
		}
		
		private function loadMapHandler(e:Event):void {
			Arrow.busySystem = false;
			global.setMapSourceXML(e.target.data);
		}
		
		private function communicatorHandler(e:CommunicatorEvent):void {
			switch(e.type) {
				case CommunicatorEvent.TABS_LOADED:
					Arrow.busySystem = false;
					global.setTabsSourceXML(e.data);
					addEventListener(Event.ENTER_FRAME, enterFrameListener);
					break;
				case CommunicatorEvent.MAP_LOADED:
					Arrow.busySystem = false;
					global.setMapSourceXML(e.data);
					break;
				case CommunicatorEvent.MAP_SAVED:
					Alert.show("Map is saved", "Note");
					break;
			}
		}
	}
}