/*
This program is the add-on for a Zenoss monitoring system.
Copyright (C) 2011 Krasotin Artem

This program is free software; you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software Foundation; 
either version 2 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; 
if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
package darkemon {
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;

	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	
	import flash.xml.*;
		
	import flash.utils.Timer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	
	import fl.data.DataProvider;
	
	import darkemon.display.*;
	import darkemon.events.*;
	import darkemon.ui.*;
	import darkemon.*;
	
	public class Global {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		public static const NONE_MODE : String = "noneMode";
		public static const ADD_NODE_MODE : String = "addNodeMode";
		public static const DEL_NODE_MODE : String = "delNodeMode";
		public static const ADD_EDGE_MODE : String = "addEdgeMode";
		public static const DEL_EDGE_MODE : String = "delEdgeMode";
		
		private var _mapId : int;
		private var _graphLineWidth : int = 1;
		private var _graphLineColor : uint = 0X000000;
		private var _refreshEventsTime : int = 300;
		private var _url : String;
				
		private var _timer : Timer = null;
		private var _toolBar : ToolBar;
		private var _tabBar : TabBar;
		private var _scene : MovieClip;
		private var bigPreloader : BigPreloader = null;
		private var rootScene : DisplayObject;
		private var nodeArray : NodeArray = new NodeArray();
		
		private var sourceNodeID : int;
		private var targetNodeID : int;
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function Global(scene : MainScene, toolBar : ToolBar, tabBar : TabBar, rootScene : DisplayObject) : void {
			_scene = scene;
			_toolBar = toolBar;
			_tabBar = tabBar;
			this.rootScene = rootScene;
		}
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		// Set and get map's id.
		public function get mapId() : int { return _mapId; }
		public function set mapId(id : int) : void { _mapId = id; }
		
		// Set and get the graph line width.
		public function get graphLineWidth() : int { return _graphLineWidth; }
		public function set graphLineWidth(w : int) : void { _graphLineWidth = w; }
		
		// Set and get the graph line color.
		public function get graphLineColor() : uint { return _graphLineColor; }
		public function set graphLineColor(c : uint) : void { _graphLineColor = c; }
		
		// Set and get url address.
		public function get url() : String { return _url; }
		public function set url(u : String) : void { _url = u; }
		
		// Set and get the refresh events time interval.
		public function get refreshEventsTime() : int { return _refreshEventsTime; }
		public function set refreshEventsTime(t : int) : void { 
			_refreshEventsTime = t;
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, refreshEvents);
			_timer = new Timer(_refreshEventsTime*1000);
			_timer.addEventListener(TimerEvent.TIMER, refreshEvents);
			_timer.start();
		}
		
		public function get scene() : MovieClip { return _scene; }
		
		// Load main config.
		public function loadMainConfig(req : URLRequest) : void {
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, mainConfigLoadedHandler);
			loader.load(req);
			showPreloader();
		}
			
		// Load data from xml.
		public function loadMap(req : URLRequest) : void
		{
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, mapLoadedHandler);
			loader.load(req);
			showPreloader();
		}
		
		// Save main data in xml.
		public function mainDataXML() : String 
		{
			var zenmapNode : XML = new XML("<zenmap/>");
			var mapsNode : XML = new XML("<maps/>");
			var mapNode : XML;
			
			var dp : DataProvider = _tabBar.dataProvider;
			for(var i:int=0; i<dp.length; i++) {
				var item:Object = dp.getItemAt(i);
				mapNode = new XML(
					"<map id='"+item.data+"'>"+item.label+"</map>");
				mapsNode.appendChild(mapNode);
			}
			zenmapNode.appendChild(mapsNode);
			return zenmapNode.toXMLString();
		}
		
		// Save map data in xml.
		public function mapDataXML() : String 
		{
			var mapNode : XML = new XML("<map/>");
			var nodes : XML = new XML("<nodes/>");
			var edges : XML = new XML("<edges/>");
			
			// Fill 'map' child.
			var mapChild;
			mapChild = new XML("<id>"+_mapId+"</id>");
			mapNode.appendChild(mapChild);
			mapChild = new XML("<x>"+_scene.x+"</x>");
			mapNode.appendChild(mapChild);
			mapChild = new XML("<y>"+_scene.y+"</y>");
			mapNode.appendChild(mapChild);
			mapChild = new XML("<scale>"+_scene.scaleX+"</scale>");
			mapNode.appendChild(mapChild);
			mapChild = new XML("<line_width>"+String(_graphLineWidth)+"</line_width>");
			mapNode.appendChild(mapChild);
			mapChild = new XML("<line_color>"+String(_graphLineColor)+"</line_color>");
			mapNode.appendChild(mapChild);
			mapChild = new XML("<refresh>"+String(_refreshEventsTime)+"</refresh>");
			mapNode.appendChild(mapChild);

			mapChild = new XML("<back_image>"+_scene.hasBackground()+"</back_image>");
			mapNode.appendChild(mapChild);
			
			if(!_scene.hasBackground()) {
				deleteBackground();
			}
			
			// Fill 'nodes' child.
			for(var i:int=0; i<nodeArray.length(); i++) {
				if(nodeArray.getNode(i) != null) {
					var str : String = new String();
					var node     : XML;
					var nameNode : XML;
					var zpath    : XML;
					var ip       : XML;
					var image    : XML;
					var n : Node = (nodeArray.getNode(i) as Node);
					
					str = "<node id='"+n.id+"' x='"+n.x+"' y='"+n.y+"'/>";
					node     = new XML(str);
					nameNode = new XML("<name>"+n.nodeName+"</name>");
					zpath    = new XML("<zpath>"+n.zpath+"</zpath>");
					ip       = new XML("<ip>"+n.ip+"</ip>");
					image    = new XML("<image>"+n.imageName+"</image>");
										
					node.appendChild(nameNode);
					node.appendChild(ip);
					node.appendChild(image);
					node.appendChild(zpath);
					nodes.appendChild(node);
				}
			}
			
			// Fill 'edges' child.
			var edgeArr : Array;
			var edge : XML;
			for(i=0; i<nodeArray.lengthEdgeArray(); i++) {
				edgeArr = nodeArray.getEdgesFrom(i);
				if(edgeArr != null) {
					for(var j:int=0; j<edgeArr.length; j++) {
						str = "<edge source='"+i+"' target='"+edgeArr[j]+"'/>";
						edge = new XML(str);
						edges.appendChild(edge);
					}
				}
			}
						
			mapNode.appendChild(nodes);
			mapNode.appendChild(edges);
			
			return mapNode.toXMLString();
		}
		
		public function addNewNodeToScene(nodeName : String, nodeX : int, nodeY : int) : void 
		{
			var id : int = nodeArray.getFirstFreeNodeID();
			var n : Node = new Node(id);
			n.nodeName = nodeName;
			nodeArray.addNode(id, n);
			_scene.getNodeLayer().addChild(n);
			n.x = nodeX;
			n.y = nodeY;
		}
		
		public function removeNodeFromScene(nodeID : int) : void
		{
			nodeArray.removeNode(nodeID);
			nodeArray.removeEdgesFrom(nodeID);
		}
		
		public function drawEdges() : void {
			_scene.getEdgeLayer().graphics.clear();
			_scene.getEdgeLayer().graphics.lineStyle(_graphLineWidth, _graphLineColor);
			var edges : Array;
			for(var i:int=0; i<nodeArray.lengthEdgeArray(); i++) {
				edges = nodeArray.getEdgesFrom(i);
				if(edges != null) {
					var sourceNode : Node = nodeArray.getNode(i);
					for(var j:int=0; j<edges.length; j++) {
						var targetNode : Node = nodeArray.getNode(edges[j]);
						_scene.getEdgeLayer().graphics.moveTo(sourceNode.x, sourceNode.y);
						_scene.getEdgeLayer().graphics.lineTo(targetNode.x, targetNode.y);
					}
				}
			}
		}
		
		public function scaleMap(k : Number) : void {
			_scene.scaleX = k;
			_scene.scaleY = k;
		}
		
		public function set actionMode(action : String) : void 
		{
			switch(action)
			{
				case NONE_MODE:
					_scene.removeEventListener(MouseEvent.MOUSE_DOWN, addNodeListener);
					_scene.removeEventListener(MouseEvent.MOUSE_DOWN, delNodeListener);
					_scene.removeEventListener(MouseEvent.CLICK, addEdgeSourceListener);
					_scene.removeEventListener(MouseEvent.CLICK, addEdgeTargetListener);
					_scene.removeEventListener(MouseEvent.CLICK, delEdgeSourceListener);
					_scene.removeEventListener(MouseEvent.CLICK, delEdgeTargetListener);
					break;
				case ADD_NODE_MODE:
					actionMode = NONE_MODE;
					_scene.addEventListener(MouseEvent.MOUSE_DOWN, addNodeListener);
					break;
				case DEL_NODE_MODE:
					actionMode = NONE_MODE;
					_scene.addEventListener(MouseEvent.MOUSE_DOWN, delNodeListener);
					break;
				case ADD_EDGE_MODE:
					actionMode = NONE_MODE;
					_scene.addEventListener(MouseEvent.CLICK, addEdgeSourceListener);
					break;
				case DEL_EDGE_MODE:
					actionMode = NONE_MODE;
					_scene.addEventListener(MouseEvent.CLICK, delEdgeSourceListener);
					break;
			}
		}
		
		//
		// Clear scene only.
		//
		public function clearMap() : void {
			// Clear scene.
			nodeArray.removeAll();
			_scene.clearBackground();
			while(_scene.getNodeLayer().numChildren != 0)
			{
				_scene.getNodeLayer().removeChildAt(0);
			}
		}
		
		public function deleteBackground() : void {
			_scene.clearBackground(); // remove image from MovieClip
			
			// Remove image from server.
			var urlLoader : URLLoader = new URLLoader();
			var urlRequest : URLRequest = new URLRequest(_url) ;
			var urlVars : URLVariables = new URLVariables();
				
			urlRequest.method = URLRequestMethod.POST;
			urlVars.action = "delete_background";
			urlVars.filename = "background"+String(_mapId)+".img";
			urlRequest.data = urlVars;
			urlLoader.load(urlRequest);
		}
		
				
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function showPreloader() : void {
			bigPreloader = new BigPreloader();
			bigPreloader.scaleX = 0.5;
			bigPreloader.scaleY = 0.5;
			bigPreloader.x = rootScene.stage.stageWidth/2;
			bigPreloader.y = rootScene.stage.stageHeight/2;
			rootScene.stage.addChild(bigPreloader);
		}
		
		private function removePreloader() : void {
			if(bigPreloader != null) {
				bigPreloader.parent.removeChild(bigPreloader);
				bigPreloader = null;
			}
		}
		
		private function mainConfigLoadedHandler(e : Event) : void 
		{
			removePreloader();
			try {
				var xml : XML = new XML(e.target.data);
				var mapsNode : XML = xml.elements("maps")[0];
				
				var dataArray : Array = new Array();
				for each(var mapNode:XML in mapsNode.elements("map")) {
					dataArray.push(
						{"label":mapNode.toString(),
					     "data":int(mapNode.attribute("id"))}
					);
				}
				if(dataArray.length == 0) 
					_tabBar.dataProvider = new DataProvider([{"label":"untitled", data:0}]);
				else _tabBar.dataProvider = new DataProvider(dataArray);
				
				// Load map.
				var urlRequest : URLRequest = new URLRequest(_url);
				var urlVariables : URLVariables = new URLVariables();
				urlRequest.method = URLRequestMethod.POST;
				urlVariables.action = "get_config";
				urlVariables.map_id = _tabBar.selectedTabId;
				urlRequest.data = urlVariables;
				loadMap(urlRequest);
			} 
			catch(error : Error) {
				trace("mainConfigLoadedHandler()\n"+error.toString());
			}
		}
		
		private function mapLoadedHandler(e : Event) : void 
		{
			removePreloader();
			try {
				e.target.removeEventListener(Event.COMPLETE, mapLoadedHandler);
				var xml : XML = new XML(e.target.data); trace(xml.toString());
								
				// Read map data.
				_mapId = int(xml.elements("id")[0]);
				_graphLineWidth = int(xml.elements("line_width")[0]);
				_graphLineColor = uint(xml.elements("line_color")[0]);
				_refreshEventsTime = int(xml.elements("refresh")[0]);
				_scene.x = Number(xml.elements("x")[0]);
				_scene.y = Number(xml.elements("y")[0]);
								
				// Read nodes data.
				var nodes : XML = xml.elements("nodes")[0];
				for each(var node:XML in nodes.elements("node")) {
					var n : Node = new Node(node.attribute("id"));
					n.nodeName = node.elements("name")[0].toString();
					n.ip       = node.elements("ip")[0].toString();
					n.zpath    = node.elements("zpath")[0].toString();
					_scene.getNodeLayer().addChild(n);
					nodeArray.addNode(n.id, n);
					n.x = node.attribute("x");
					n.y = node.attribute("y");
					
					// Set node image.
					if(node.elements("image")[0].toString() != "null") {
						var urlRequest : URLRequest = new URLRequest(_url+
							"?action=download_nodeimage&filename="+node.elements("image")[0].toString());
						urlRequest.method = URLRequestMethod.POST;
						n.loadImageURL(urlRequest,node.elements("image")[0].toString());
					}
				}
				
				// Read edge data.
				var edges : XML = xml.elements("edges")[0];
				for each(var edge:XML in edges.elements("edge")) {
					var sourceID : int = edge.attribute("source");
					var targetID : int = edge.attribute("target");
					nodeArray.addEdge(sourceID, targetID);
				}
												
				// Load background image.								
				if(xml.elements("back_image")[0] == "true") {
					var urlRequest : URLRequest = new URLRequest(_url) ;
					var urlVars : URLVariables = new URLVariables();
				
					urlRequest.method = URLRequestMethod.POST;
					urlVars.action = "download_background";
					urlVars.filename = "background"+String(_mapId)+".img";
					urlRequest.data = urlVars;
					_scene.loadBackgroundURL(urlRequest);
				}
				
				switch(Number(xml.elements("scale")[0]))
				{
					case Number(0.25):
						_toolBar.currentScaleBoxIndex(0);
						break;
					case Number(0.5):
						_toolBar.currentScaleBoxIndex(1);
						break;
					case Number(0.75):
						_toolBar.currentScaleBoxIndex(2);
						break;
					case Number(1):
						_toolBar.currentScaleBoxIndex(3);
						break;
					case Number(2):
						_toolBar.currentScaleBoxIndex(4);
						break;
					case Number(3):
						_toolBar.currentScaleBoxIndex(5);
						break;
					case Number(4):
						_toolBar.currentScaleBoxIndex(6);
						break;
				}
				scaleMap(xml.elements("scale")[0]);
			} 
			catch(error : Error) {
				trace("mapLoadedHandler()\n"+error.toString());
			}
			if(_timer != null) 
				if(_timer.hasEventListener(TimerEvent.TIMER))
					_timer.removeEventListener(TimerEvent.TIMER, refreshEvents);
			_timer = new Timer(_refreshEventsTime*1000);
			_timer.addEventListener(TimerEvent.TIMER, refreshEvents);
			_timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			_timer.start();
			(rootScene as MovieClip).play();
		}
		
		private function getDevicesEvents() : void {
			var xml : XML = new XML("<device_list/>");
			var dev : XML;
			
			for(var i:int=0; i<nodeArray.length(); i++) {
				if(nodeArray.getNode(i) != null) {
					var n : Node = (nodeArray.getNode(i) as Node);
					n.eventState = Node.CLEAR_STATE;
					dev = new XML("<device id='"+String(n.id)+"'>"+n.ip+"</device>");
					xml.appendChild(dev);
				}
			}
			
			var urlLoader : URLLoader = new URLLoader();
			var urlRequest : URLRequest = new URLRequest(_url) ;
			var urlVars : URLVariables = new URLVariables();
				
			urlRequest.method = URLRequestMethod.POST;
			urlVars.action = "get_devicesevents";
			urlVars.devicelist = xml.toXMLString();
			urlRequest.data = urlVars;
			
			urlLoader.addEventListener(Event.COMPLETE, sendData);
			urlLoader.load(urlRequest);

			function sendData(e : Event) : void 
			{
				var xml : XML = new XML(urlLoader.data);
				for each(var node : XML in xml.elements("id")) {
					var severity : int = int(node.attribute("severity"));
					var id : int = int(node.toString());
					nodeArray.getNode(id).eventState = severity;
				}
			}
		}
		
		////
		// Listener: Add node mode.
		//
		private function addNodeListener(e : MouseEvent) : void {
			addNewNodeToScene("new node", e.localX, e.localY);
		}
		
		////
		// Listener: Delete node mode.
		//
		private function delNodeListener(e : MouseEvent) : void {
			if(e.target is Node) {
				var n : Node = (e.target as Node);
				removeNodeFromScene(n.id);
				_scene.getNodeLayer().removeChild(n);
			}
		}
		
		////
		// Listeners: Add edge mode.
		//
		private function addEdgeSourceListener(e : MouseEvent) : void {
			if(e.target is Node) {
				var n : Node = (e.target as Node);
				sourceNodeID = n.id;
				_scene.addEventListener(MouseEvent.CLICK, addEdgeTargetListener);
				_scene.removeEventListener(MouseEvent.CLICK, addEdgeSourceListener);
				Arrow.arrow = Arrow.SELECT_SECOND;
			}
		}
		
		private function addEdgeTargetListener(e : MouseEvent) : void {
			if(e.target is Node) {
				var n : Node = (e.target as Node);
				targetNodeID = n.id;
				if(sourceNodeID != targetNodeID) {
					nodeArray.addEdge(sourceNodeID, targetNodeID);
					_scene.addEventListener(MouseEvent.CLICK, addEdgeSourceListener);
					_scene.removeEventListener(MouseEvent.CLICK, addEdgeTargetListener);
					Arrow.arrow = Arrow.SELECT_FIRST;
				}
			}
		}
		
		////
		// Listeners: Delete edge mode.
		//
		private function delEdgeSourceListener(e : MouseEvent) : void {
			if(e.target is Node) {
				var n : Node = (e.target as Node);
				sourceNodeID = n.id;
				_scene.addEventListener(MouseEvent.CLICK, delEdgeTargetListener);
				_scene.removeEventListener(MouseEvent.CLICK, delEdgeSourceListener);
				Arrow.arrow = Arrow.SELECT_SECOND;
			}
		}
		
		private function delEdgeTargetListener(e : MouseEvent) : void {
			if(e.target is Node) {
				var n : Node = (e.target as Node);
				targetNodeID = n.id;
				if(sourceNodeID != targetNodeID) {
					nodeArray.removeEdge(sourceNodeID, targetNodeID);
					_scene.addEventListener(MouseEvent.CLICK, delEdgeSourceListener);
					_scene.removeEventListener(MouseEvent.CLICK, delEdgeTargetListener);
					Arrow.arrow = Arrow.SELECT_FIRST;
				}
			}
		}
		
		////
		// Listeners: Refresh events inteval.
		//
		private function refreshEvents(e : TimerEvent) : void {
			//trace("it's dinner time bitches");
			getDevicesEvents();
		}
	}
}