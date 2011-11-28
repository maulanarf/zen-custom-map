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
	import darkemon.Global;
	import darkemon.display.Arrow;
	import darkemon.display.Node;
	import darkemon.events.CommunicatorEvent;
	import darkemon.net.Communicator;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Form;
	import spark.components.FormItem;
	import spark.components.TitleWindow;
	import spark.events.IndexChangeEvent;
	import spark.layouts.HorizontalLayout;
	
	public class NodeSettingsDialog {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _window:TitleWindow = null;
		private static var _global:Global = null;
		private static var _node:Node = null;
		private static var _tabBar:ExtTabBar = null;
		private static var _devicesDict:Object;
		private static var _comm:Communicator = new Communicator();
		
		private static var form:Form = new Form();
		private static var nodeFormItem:FormItem = new FormItem();
		private static var submapFormItem:FormItem = new FormItem();
		private static var nodeTypeBox:DropDownList = new DropDownList();
		private static var nodeClassBox:DropDownList = new DropDownList();
		private static var nodeDeviceBox:DropDownList = new DropDownList();
		private static var subMapBox:DropDownList = new DropDownList();
		private static var okBtn:Button = new Button();
		private static var cancelBtn:Button = new Button();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function NodeSettingsDialog() {
			throw Error("NodeSettingsDialog is a singleton class, use show() instead.");
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public static function show(parent:DisplayObject, n:Node, g:Global,
									t:ExtTabBar, modal:Boolean=false):void {
			if(!_window) createWindow();
			_node = n;
			_global = g;
			_tabBar = t;
			_comm.addEventListener(CommunicatorEvent.DEVICES_LIST_LOADED, communicatorHandler);
			update();
			PopUpManager.addPopUp(_window, parent, modal);
			PopUpManager.centerPopUp(_window);
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private static function createWindow():void {
			
			_window = new TitleWindow();
			
			// Set size and title.
			_window.height = 200;
			_window.width = 400;
			_window.title = "Node setings";
			
			_window.addElement(form);
			_window.addElement(okBtn);
			_window.addElement(cancelBtn);
			
			okBtn.label = "Ok";
			cancelBtn.label = "Cancel";
			okBtn.height = cancelBtn.height = 20;
			okBtn.width = cancelBtn.width = 75;
			
			nodeTypeBox.dataProvider = new ArrayCollection(["node", "submap"]);
			nodeClassBox.dataProvider = new ArrayCollection();
			nodeDeviceBox.dataProvider = new ArrayCollection();
			subMapBox.dataProvider = new ArrayCollection();
			nodeClassBox.width = nodeDeviceBox.width = 140;
			
			form.setConstraintValue("top", 5);
			form.setConstraintValue("left", 5);
			form.setConstraintValue("right", 5);
			form.setConstraintValue("bottom", 30);
			okBtn.setConstraintValue("bottom", 5);
			okBtn.setConstraintValue("right", cancelBtn.width+10);
			cancelBtn.setConstraintValue("bottom", 5);
			cancelBtn.setConstraintValue("right", 5);
			
			//
			// Fill the form.
			//
			/* Node type settings */
			var formItem:FormItem = new FormItem();
			formItem.label = "Node type";
			formItem.addElement(nodeTypeBox);
			form.addElement(formItem);
			
			//
			// Dynamic form items.
			//
			/* Form item for node type 'node' */
			nodeFormItem.label = "Device";
			nodeFormItem.layout = new HorizontalLayout();
			nodeFormItem.addElement(nodeClassBox);
			nodeFormItem.addElement(nodeDeviceBox);
			
			/* Form item for node type 'submap' */
			submapFormItem.label = "Map";
			submapFormItem.addElement(subMapBox);
						
			// Add listeners.
			okBtn.addEventListener(MouseEvent.CLICK, applyHandler);
			cancelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			nodeTypeBox.addEventListener(IndexChangeEvent.CHANGE, nodeTypeBoxListener);
			nodeClassBox.addEventListener(IndexChangeEvent.CHANGE, selectDeviceClass);
			_window.addEventListener(CloseEvent.CLOSE, closeHandler);
		}
		
		private static function showNodeItem():void {
			try { form.removeElementAt(1); }
			catch(error:Error) {}
			loadDeviceList();
			form.addElement(nodeFormItem);
		}
		
		private static function showSubmapItem():void {
			try { form.removeElementAt(1); }
			catch(error:Error) {}
			var i:int;
			if(_tabBar.dataProvider.length > 1) {
				//var dp:ArrayCollection = new ArrayCollection(
				(subMapBox.dataProvider as ArrayCollection).source = 
					ObjectUtil.copy(_tabBar.dataProvider.source) as Array;
			
				// Remove current map from list.
				for(i=0; i<subMapBox.dataProvider.length; i++) {
					if(_global.dataProvider.mapUid == subMapBox.dataProvider[i].uid) {
						subMapBox.dataProvider.removeItemAt(i);
						break;
					}
				}
				subMapBox.selectedIndex = 0;
			}
			
			// Select the corresponding map if defined.
			if(_node.submapUid) {
				for(i=0; i<subMapBox.dataProvider.length; i++) {
					if(_node.submapUid == subMapBox.dataProvider[i].uid) {
						subMapBox.selectedIndex = i;
						break;
					}
				}
			}
			form.addElement(submapFormItem);
		}
		
		private static function loadDeviceList():void {
    		_comm.loadDevicesList();
			Arrow.busySystem = true;
		}
		
		private static function update():void {
			for(var i:int=0; i<nodeTypeBox.dataProvider.length; i++) {
				if(_node.type == nodeTypeBox.dataProvider[i]) {
					nodeTypeBox.selectedIndex = i;
					break;
				}
			}
			nodeTypeBox.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
		}
		
		private static function destroy():void {
			_node = null;
			_global = null;
			(nodeClassBox.dataProvider as ArrayCollection).removeAll();
			(nodeDeviceBox.dataProvider as ArrayCollection).removeAll();
			(subMapBox.dataProvider as ArrayCollection).removeAll();
			_devicesDict = null;
			_comm.removeEventListener(CommunicatorEvent.DEVICES_LIST_LOADED, 
				communicatorHandler);
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private static function closeHandler(e:CloseEvent):void {
			PopUpManager.removePopUp(_window);
			destroy();
		}
		
		private static function applyHandler(e:MouseEvent):void {
			if(_node.type != nodeTypeBox.selectedItem) {
				_node.type = nodeTypeBox.selectedItem as String;
			}
			
			switch(_node.type) {
				case "node":
					_node.ip = nodeDeviceBox.selectedItem.ip;
					_node.nodeName = nodeDeviceBox.selectedItem.label;
					_node.zenClass = nodeClassBox.selectedItem.label;
					break;
				case "submap":
					if(subMapBox.selectedIndex != -1) {
						_node.nodeName = subMapBox.selectedItem.label;
						_node.submapUid = subMapBox.selectedItem.uid;
					} else {
						_node.nodeName = "new submap";	
					}
					break;
			}
			_node.message = "";
			_node.eventState = Node.CLEAR_STATE;
			PopUpManager.removePopUp(_window);
			destroy();
		}
		
		private static function cancelHandler(e:MouseEvent):void {
			_window.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			destroy();
		}
		
		private static function nodeTypeBoxListener(e:IndexChangeEvent):void {
			switch(nodeTypeBox.selectedItem as String) {
				case "node":
					showNodeItem();
					break;
				case "submap":
					showSubmapItem();
					break;
			}
		}
		
		private static function selectDeviceClass(e:IndexChangeEvent):void {
			nodeDeviceBox.dataProvider = _devicesDict[nodeClassBox.selectedItem.label];
			nodeDeviceBox.selectedIndex = 0;
		}
		
		private static function communicatorHandler(e:CommunicatorEvent):void {
			if(e.type == CommunicatorEvent.DEVICES_LIST_LOADED) {
				try {
					_devicesDict = new Object();
					var xml:XML = new XML(e.data);
					
					// Read device list.
					var dp:ArrayCollection = new ArrayCollection();
					var devices:ArrayCollection;
					var i:int = 0;
					var j:int = 0;
					var classIndex:int = 0;
					var deviceIndex:int = 0;
					for each(var classNode:XML in xml.elements("class")) 
					{
						if(_node.zenClass == classNode.attribute("path")) 
							classIndex = i;
						if(_devicesDict[classNode.attribute("path")] == undefined) 
							devices = new ArrayCollection();
						else devices = _devicesDict[classNode.attribute("path")];
						
						j = 0;
						for each(var devNode:XML in classNode.elements("device"))
						{
							var dev:Object = new Object();
							dev.label = devNode.toString();
							dev.ip = devNode.attribute("ip");
							devices.addItem(dev);
							if(_node.ip == dev.ip) deviceIndex = j;
							j++;
						}
						_devicesDict[classNode.attribute("path")] = devices;
						dp.addItem({"label":classNode.attribute("path")});
						i++;
					}
					
					nodeClassBox.dataProvider = dp;
					nodeClassBox.selectedIndex = classIndex;
					nodeDeviceBox.dataProvider = _devicesDict[nodeClassBox.selectedItem.label];
					nodeDeviceBox.selectedIndex = deviceIndex;
				} 
				catch(e:TypeError) {
					throw Error("darkemon::ui::NodeSettingsDialog::"+
						"communicatorHandler::Could not parse the XML file.\n"+e.toString());
				}
				finally {
					Arrow.busySystem = false;
				}
			}
		}
	}
}