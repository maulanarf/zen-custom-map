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
	import darkemon.events.NodeEvent;
	import darkemon.display.Node;
	
	import flash.display.DisplayObject;
	import flash.ui.Mouse;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class NodeMenu {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _menu:List = null;
		private static var _parent:DisplayObject;
		private static var _visible:Boolean = false;
		private static var _node:Node = null;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function NodeMenu() {
			throw Error("NodeMenu is a singleton class, use show() instead.");
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public static function show(n:Node):void {
			if(!_menu) createMenu();
			if(_visible) hide();
			_node = n;
			updateMenu();
			PopUpManager.addPopUp(_menu, FlexGlobals.topLevelApplication.parent, false);
			_menu.x = FlexGlobals.topLevelApplication.contentMouseX;
			_menu.y = FlexGlobals.topLevelApplication.contentMouseY;
			_visible = true;
		}
		
		public static function hide():void {
			if(_visible) {
				_node = null;
				PopUpManager.removePopUp(_menu);
				_visible = false;
			}
		}
		
		public static function get visible():Boolean {
			return _visible;
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private static function createMenu():void {
			_menu = new List();
			_menu.addEventListener(IndexChangeEvent.CHANGE, selectMenuItem);
		}
		
		private static function updateMenu():void {
			if(_node.type == "submap") {
				_menu.dataProvider = new ArrayCollection(
					["Settings", "Image", "Open submap"]);
			} else {
				_menu.dataProvider = new ArrayCollection(
					["Settings", "Image", "Open events"]);
			}
			_menu.height = _menu.dataProvider.length * 23;
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private static function selectMenuItem(e:IndexChangeEvent):void {
			switch(String(_menu.selectedItem)) {
				case "Settings":
					_node.dispatchEvent(new NodeEvent(NodeEvent.OPEN_PREF, true, false));
					break;
				case "Image":
					_node.dispatchEvent(new NodeEvent(NodeEvent.OPEN_LIBRARY, true, false));
					break;
				case "Open events":
					_node.dispatchEvent(new NodeEvent(NodeEvent.OPEN_EVENTS, true, false));
					break;
				case "Open submap":
					_node.dispatchEvent(new NodeEvent(NodeEvent.OPEN_SUBMAP, true, false));
					break;
			}
			hide();
		}
	}
}