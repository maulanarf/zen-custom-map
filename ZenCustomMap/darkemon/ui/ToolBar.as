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
package darkemon.ui {
	import darkemon.components.DropDownButtonList;
	import darkemon.events.ToolBarEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.ToggleButton;
	import spark.events.IndexChangeEvent;
	
	public class ToolBar extends HGroup {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _instance:ToolBar = null;
		private static var _allowInstantiation:Boolean = false;
		
		private static var panBtn:ToggleButton = new ToggleButton();
		private static var moveNodeBtn:ToggleButton = new ToggleButton();
		private static var addNodeBtn:ToggleButton = new ToggleButton();
		private static var delNodeBtn:ToggleButton = new ToggleButton();
		private static var addEdgeBtn:ToggleButton = new ToggleButton();
		private static var delEdgeBtn:ToggleButton = new ToggleButton();
		private static var saveBtn:Button = new Button();
		private static var prefBtn:Button = new Button();
		private static var nodeToolBtnList:DropDownButtonList = new DropDownButtonList();
		private static var edgeToolBtnList:DropDownButtonList = new DropDownButtonList();
		private static var scaleBox:DropDownList = new DropDownList();
		
		private static var currentSelectedBtn:ToggleButton = new ToggleButton();
		
		[Embed(source='assets/grab_hand_icon.png')]
		public static var MoveMapIcon:Class;
		[Embed(source='assets/move_node_icon.png')]
		public static var MoveNodeIcon:Class;
		[Embed(source='assets/add_node_icon.png')]
		public static var AddNodeIcon:Class;
		[Embed(source='assets/del_node_icon.png')]
		public static var DelNodeIcon:Class;
		[Embed(source='assets/add_edge_icon.png')]
		public static var AddEdgeIcon:Class;
		[Embed(source='assets/del_edge_icon.png')]
		public static var DelEdgeIcon:Class;
		[Embed(source='assets/gear_icon.png')]
		public static var PrefIcon:Class;
		[Embed(source='assets/diskette_icon.png')]
		public static var SaveIcon:Class;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function ToolBar() {
			if(!_allowInstantiation) {
				throw Error("ToolBar is a singleton class, use getInstance() instead.");
			}
			
			gap = 5;
			
			// Clear buttons label.
			panBtn.label = "";
			moveNodeBtn.label = "";
			addNodeBtn.label = "";
			delNodeBtn.label = "";
			addEdgeBtn.label = "";
			delEdgeBtn.label = "";
			saveBtn.label = "";
			prefBtn.label = "";
			
			// Add tool tips.
			panBtn.toolTip = "Move map";
			moveNodeBtn.toolTip = "Move and edit node";
			addNodeBtn.toolTip = "Add node";
			delNodeBtn.toolTip = "Delete node";
			addEdgeBtn.toolTip = "Add edge";
			delEdgeBtn.toolTip = "Delete edge";
			saveBtn.toolTip = "Save map";
			prefBtn.toolTip = "Map settings";
			scaleBox.toolTip = "Map scale";
			
			// Set buttons size.
			panBtn.width = panBtn.height = 24;
			moveNodeBtn.width = moveNodeBtn.height = 24;
			addNodeBtn.width = addNodeBtn.height = 24;
			delNodeBtn.width = delNodeBtn.height = 24;
			addEdgeBtn.width = addEdgeBtn.height = 24;
			delEdgeBtn.width = delEdgeBtn.height = 24;
			saveBtn.width = saveBtn.height = 24;
			prefBtn.width = prefBtn.height = 24;
			scaleBox.height = 24;
			scaleBox.width = 72;
			
			// Set icons.
			panBtn.setStyle("icon", MoveMapIcon);
			moveNodeBtn.setStyle("icon", MoveNodeIcon);
			addNodeBtn.setStyle("icon", AddNodeIcon);
			delNodeBtn.setStyle("icon", DelNodeIcon);
			addEdgeBtn.setStyle("icon", AddEdgeIcon);
			delEdgeBtn.setStyle("icon", DelEdgeIcon);
			saveBtn.setStyle("icon", SaveIcon);
			prefBtn.setStyle("icon", PrefIcon);
			
			// Fill drop down button lists.
			nodeToolBtnList.addButton(moveNodeBtn);
			nodeToolBtnList.addButton(addNodeBtn);
			nodeToolBtnList.addButton(delNodeBtn);
			
			edgeToolBtnList.addButton(addEdgeBtn);
			edgeToolBtnList.addButton(delEdgeBtn);
			
			// Fill scale list.
			scaleBox.dataProvider = new ArrayCollection([
				{"label":"25%","delta":0.25},
				{"label":"50%","delta":0.5},
				{"label":"75%","delta":0.75},
				{"label":"100%","delta":1},
				{"label":"200%","delta":2},
				{"label":"300%","delta":3},
				{"label":"400%","delta":4}]);
			scaleBox.selectedIndex = 3;
			
			// Add listeners.
			panBtn.addEventListener(MouseEvent.CLICK, clickListener);
			moveNodeBtn.addEventListener(MouseEvent.CLICK, clickListener);
			addNodeBtn.addEventListener(MouseEvent.CLICK, clickListener);
			delNodeBtn.addEventListener(MouseEvent.CLICK, clickListener);
			addEdgeBtn.addEventListener(MouseEvent.CLICK, clickListener);
			delEdgeBtn.addEventListener(MouseEvent.CLICK, clickListener);
			saveBtn.addEventListener(MouseEvent.CLICK, clickListener);
			prefBtn.addEventListener(MouseEvent.CLICK, clickListener);
			scaleBox.addEventListener(IndexChangeEvent.CHANGE, changeScaleHandler);
			
			// Add buttons to scene.
			addElement(panBtn);
			addElement(nodeToolBtnList);
			addElement(edgeToolBtnList);
			addElement(prefBtn);
			addElement(saveBtn);
			addElement(scaleBox);
		
			// Select first button.
			panBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public static function getInstance():ToolBar {
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new ToolBar();
				_allowInstantiation = false;
			}
			return _instance;
		}
		
		public function get selectedScaleBoxIndex():int {
			return scaleBox.selectedIndex;
		}
		
		public function set selectedScaleBoxIndex(i:int):void {
			scaleBox.selectedIndex = i;
			scaleBox.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function clickListener(e:MouseEvent):void {
			if(e.target is ToggleButton) 
			{
				var btn:ToggleButton = e.target as ToggleButton;
				if(btn != currentSelectedBtn) {
					switch(btn)
					{
						case panBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.MOVE_MAP));
						break;
						case moveNodeBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.MOVE_NODE));
						break;
						case addNodeBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.ADD_NODE));
						break;
						case delNodeBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.DEL_NODE));
						break;
						case addEdgeBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.ADD_EDGE));
						break;
						case delEdgeBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.DEL_EDGE));
						break;
					}
					currentSelectedBtn.selected = false;
					currentSelectedBtn = btn;
				}
				btn.selected = true;
			} else {
				switch(e.target as Button)
				{
					case saveBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.SAVE_DATA));
						break;
					case prefBtn:
						dispatchEvent(new ToolBarEvent(ToolBarEvent.OPEN_PREF));
						break;
				}
			}
		}
		
		private function changeScaleHandler(e:IndexChangeEvent):void {
			dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP,
				scaleBox.selectedItem.delta));
		}
	}
}