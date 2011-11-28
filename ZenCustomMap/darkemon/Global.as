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
	
	import darkemon.*;
	import darkemon.data.GraphData;
	import darkemon.data.MapDataProvider;
	import darkemon.display.*;
	import darkemon.events.*;
	import darkemon.net.Communicator;
	import darkemon.ui.*;
	
	import flash.events.MouseEvent;
	import flash.xml.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	public class Global {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		public static const NONE_MODE:String = "noneMode";
		public static const ADD_NODE_MODE:String = "addNodeMode";
		public static const DEL_NODE_MODE:String = "delNodeMode";
		public static const ADD_EDGE_MODE:String = "addEdgeMode";
		public static const DEL_EDGE_MODE:String = "delEdgeMode";
		
		private var _dataProvider:MapDataProvider;
		private var _tabBar:ExtTabBar;
		private var _scene:MainScene;
		private var _comm:Communicator;
		
		private var sourceNodeID:int;
		private var targetNodeID:int;
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function Global(scene:MainScene, tabBar:ExtTabBar):void 
		{
			_dataProvider = new MapDataProvider();
			_scene = scene;
			_tabBar = tabBar;
			_comm = new Communicator();
		}
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------

		public function get dataProvider():MapDataProvider { return _dataProvider; }
	
		public function get scene():MainScene { return _scene; }
		
		public function getTabsSourceXML():String {
			var zenmapNode:XML = new XML("<zenmap/>");
			var mapsNode:XML = new XML("<maps/>");
						
			for each(var item:Object in _tabBar.dataProvider) {
				mapsNode.appendChild(new XML(
					"<map uid='"+item.uid+"'>"+item.label+"</map>")
				);
			}
			zenmapNode.appendChild(mapsNode);
			return zenmapNode.toXMLString();
		}
		
		public function setTabsSourceXML(src:String):void 
		{
			try {
				var xml:XML = new XML(src);
				var mapsNode:XML = xml.elements("maps")[0];
				
				var dataArray:Array = new Array();
				for each(var mapNode:XML in mapsNode.elements("map")) {
					dataArray.push(
						{"label":mapNode.toString(),
						 "uid":int(mapNode.attribute("uid"))}
					);
				}
				if(dataArray.length == 0) 
					_tabBar.dataProvider = new ArrayCollection([{"label":"untitled", "uid":0}]);
				else _tabBar.dataProvider = new ArrayCollection(dataArray);
			} 
			catch(error:Error) {
				throw Error("darkemon::Global::setTabsSourceXML\n"+error.toString());
			}
		}

		public function getMapSourceXML():String {
			var mapNode:XML = new XML("<map/>");
			var nodes:XML = new XML("<nodes/>");
			var edges:XML = new XML("<edges/>");
			
			// Fill 'map' child.
			var mapChild;
			mapNode.appendChild(new XML("<uid>"+_dataProvider.mapUid+"</uid>"));
			mapNode.appendChild(new XML("<x>"+_scene.sceneX+"</x>"));
			mapNode.appendChild(new XML("<y>"+_scene.sceneY+"</y>"));
			mapNode.appendChild(new XML("<zoom_index>"+
				ToolBar.getInstance().selectedScaleBoxIndex+"</zoom_index>"));
			mapNode.appendChild(
				new XML("<line_width>"+String(_dataProvider.graphLineWidth)+
					    "</line_width>"));
			mapNode.appendChild(
				new XML("<line_color>"+String(_dataProvider.graphLineColor)+
					    "</line_color>"));
			mapNode.appendChild(
				new XML("<refresh>"+String(_dataProvider.refreshEventsTime)+
				        "</refresh>"));
			mapNode.appendChild(
				new XML("<back_image>"+_scene.hasBackgroundImage()+"</back_image>"));
			
			// Remove image from server.
			if(!_scene.hasBackgroundImage()) deleteBackgroundImage();
			
			// Fill 'nodes' child.
			for(var i:int=0; i<_dataProvider.graphData.nodesCount; i++) {
				if(_dataProvider.graphData.getNode(i) != null) {
					var node:XML;
					var n:Node = _dataProvider.graphData.getNode(i);
					node = new XML("<node id='"+n.nodeId+"' x='"+n.x+"' y='"+n.y+"'/>");
					node.appendChild(new XML("<name>"+n.nodeName+"</name>"));
					node.appendChild(new XML("<type>"+n.type+"</type>"));
					node.appendChild(new XML("<ip>"+n.ip+"</ip>"));
					node.appendChild(new XML("<submap_uid>"+n.submapUid+"</submap_uid>"));
					node.appendChild(new XML("<zenClass>"+n.zenClass+"</zenClass>"));
					node.appendChild(new XML("<image>"+n.imageName+"</image>"));
					nodes.appendChild(node);
				}
			}
			
			// Fill 'edges' child.
			var edgeArr:Array;
			for(i=0; i<_dataProvider.graphData.edgesCount; i++) {
				edgeArr = _dataProvider.graphData.getEdgesFrom(i);
				if(edgeArr != null) {
					for(var j:int=0; j<edgeArr.length; j++) {
						edges.appendChild(
							new XML("<edge source='"+i+"' target='"+edgeArr[j]+"'/>")
						);
					}
				}
			}
			
			mapNode.appendChild(nodes);
			mapNode.appendChild(edges);
			
			return mapNode.toXMLString();
		}
		
		public function setMapSourceXML(src:String):void 
		{
			// Clear scene.
			clear();
			try {
				var xml:XML = new XML(src);
				
				//
				// Read map data.
				//
				_dataProvider.mapUid = int(xml.elements("uid")[0]);
				_dataProvider.graphLineWidth = int(xml.elements("line_width")[0]);
				_dataProvider.graphLineColor = uint(xml.elements("line_color")[0]);
				_dataProvider.refreshEventsTime = int(xml.elements("refresh")[0]);
				_scene.sceneX = Number(xml.elements("x")[0]);
				_scene.sceneY = Number(xml.elements("y")[0]);
				ToolBar.getInstance().selectedScaleBoxIndex = 
					int(xml.elements("zoom_index")[0]);
							
				//
				// Read nodes data.
				//
				var nodes:XML = xml.elements("nodes")[0];
				for each(var node:XML in nodes.elements("node")) 
				{
					var n:Node = new Node(node.attribute("id"));
					n.nodeName = node.elements("name")[0].toString();
					n.zenClass = node.elements("zenClass")[0].toString();
					n.ip = node.elements("ip")[0].toString();
					n.submapUid = uint(node.elements("submap_uid")[0]);
					n.type = node.elements("type")[0].toString();
					_scene.getNodeLayer().addChild(n);            // add node to scene
					_dataProvider.graphData.addNode(n.nodeId, n); // add node to array
					n.x = node.attribute("x");
					n.y = node.attribute("y");
					
					if(n.type == "submap") n.nodeName = _tabBar.getLabelByUid(n.submapUid);
				
					// Set node image.
					if(node.elements("image")[0].toString() != "null") {
						var imgUrl:String = Communicator.url + 
							"?action=download_nodeimage&filename="+
							node.elements("image")[0].toString();
						n.setImage(imgUrl, node.elements("image")[0].toString());
					}
				}
				
				//
				// Read edge data.
				//
				var edges:XML = xml.elements("edges")[0];
				for each(var edge:XML in edges.elements("edge"))
				{
					var sourceID:int = edge.attribute("source");
					var targetID:int = edge.attribute("target");
					_dataProvider.graphData.addEdge(sourceID, targetID);
				}
			
				// Load background image.
				if(xml.elements("back_image")[0] == "true") {
					_scene.setBackgroundImage(Communicator.url+
						"?action=download_background&filename=background"+
						String(_dataProvider.mapUid)+".img");
				}
			}
			catch(error:Error) {
				throw Error("darkemon::Global::setMapSourceXML\n"+error.toString());
			}
			// Update events.
			_dataProvider.updateEventsImmediate();
		}

		public function addNewNodeToScene(nodeName:String, nodeX:int, nodeY:int):void 
		{
			var id:int = _dataProvider.graphData.getFirstFreeNodeID();
			var n:Node = new Node(id);
			n.nodeName = nodeName;
			_dataProvider.graphData.addNode(id, n);
			_scene.getNodeLayer().addChild(n);
			n.x = nodeX;
			n.y = nodeY;
		}
		
		public function removeNodeFromScene(nodeID:int):void
		{
			_dataProvider.graphData.removeNode(nodeID);
			_dataProvider.graphData.removeEdgesFrom(nodeID);
		}
		
		public function drawEdges():void {
			_scene.getEdgeLayer().graphics.clear();
			_scene.getEdgeLayer().graphics.lineStyle(_dataProvider.graphLineWidth, 
				_dataProvider.graphLineColor);
			var edges : Array;
			for(var i:int=0; i<_dataProvider.graphData.edgesCount; i++) {
				edges = _dataProvider.graphData.getEdgesFrom(i);
				if(edges != null) {
					var sourceNode : Node = _dataProvider.graphData.getNode(i);
					for(var j:int=0; j<edges.length; j++) {
						var targetNode : Node = _dataProvider.graphData.getNode(edges[j]);
						_scene.getEdgeLayer().graphics.moveTo(sourceNode.x, sourceNode.y);
						_scene.getEdgeLayer().graphics.lineTo(targetNode.x, targetNode.y);
					}
				}
			}
		}

		public function set actionMode(action:String):void 
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
		
		public function deleteBackgroundImage():void {
			_scene.setBackgroundImage(null);              // remove image from MainScene
			_comm.deleteBackground(_dataProvider.mapUid); // remove image from server
		}
		
		public function clear():void {
			_dataProvider.graphData.removeAll();
			_scene.setBackgroundImage(null);;
			_scene.clearNodeLayer();
			_scene.zoom = 1;
		}
			
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		////
		// Add node mode.
		//
		private function addNodeListener(e:MouseEvent):void {
			addNewNodeToScene("new node", _scene.getNodeLayer().contentMouseX, 
				_scene.getNodeLayer().contentMouseY);
		}
		
		////
		// Delete node mode.
		//
		private function delNodeListener(e:MouseEvent):void {
			if(e.target is Node) {
				var n : Node = (e.target as Node);
				removeNodeFromScene(n.nodeId);
				_scene.getNodeLayer().removeChild(n);
			}
		}
		
		////
		// Add edge mode.
		//
		private function addEdgeSourceListener(e:MouseEvent):void {
			if(e.target is Node) {
				var n:Node = (e.target as Node);
				sourceNodeID = n.nodeId;
				_scene.addEventListener(MouseEvent.CLICK, addEdgeTargetListener);
				_scene.removeEventListener(MouseEvent.CLICK, addEdgeSourceListener);
				//Arrow.mode = Arrow.SELECT_SECOND;
			}
		}
		
		private function addEdgeTargetListener(e:MouseEvent):void {
			if(e.target is Node) {
				var n:Node = (e.target as Node);
				targetNodeID = n.nodeId;
				if(sourceNodeID != targetNodeID) {
					_dataProvider.graphData.addEdge(sourceNodeID, targetNodeID);
					_scene.addEventListener(MouseEvent.CLICK, addEdgeSourceListener);
					_scene.removeEventListener(MouseEvent.CLICK, addEdgeTargetListener);
					//Arrow.mode = Arrow.SELECT_FIRST;
				}
			}
		}
		
		////
		// Delete edge mode.
		//
		private function delEdgeSourceListener(e:MouseEvent):void {
			if(e.target is Node) {
				var n:Node = (e.target as Node);
				sourceNodeID = n.nodeId;
				_scene.addEventListener(MouseEvent.CLICK, delEdgeTargetListener);
				_scene.removeEventListener(MouseEvent.CLICK, delEdgeSourceListener);
				//Arrow.mode = Arrow.SELECT_SECOND;
			}
		}
		
		private function delEdgeTargetListener(e:MouseEvent):void {
			if(e.target is Node) {
				var n:Node = (e.target as Node);
				targetNodeID = n.nodeId;
				if(sourceNodeID != targetNodeID) {
					_dataProvider.graphData.removeEdge(sourceNodeID, targetNodeID);
					_scene.addEventListener(MouseEvent.CLICK, delEdgeSourceListener);
					_scene.removeEventListener(MouseEvent.CLICK, delEdgeTargetListener);
					//Arrow.mode = Arrow.SELECT_FIRST;
				}
			}
		}
	}
}