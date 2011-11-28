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
package darkemon.net {
	import darkemon.events.CommunicatorEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class Communicator extends EventDispatcher {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		public static const url:String = "/zport/dmd/zenCustomMapData";
		
		private var _request:URLRequest;
		private var _vars:URLVariables;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function Communicator() {
			_request = new URLRequest(url);
			_request.method = URLRequestMethod.POST;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function saveTabs(tabsSourceXML:String):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, saveTabsHandler);
			
			_vars = new URLVariables();
			_vars.action = "save_mainconfig";
			_vars.config = tabsSourceXML;
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function loadTabs():void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadTabsHandler);
			
			_vars = new URLVariables();
			_vars.action = "get_mainconfig";
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function deleteMap(mapUid:int):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, deleteMapHandler);
			
			_vars = new URLVariables();
			_vars.action = "delete_map";
			_vars.map_id = mapUid;
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function loadMap(mapUid:int):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadMapHandler);
			
			_vars = new URLVariables();
			_vars.action = "get_config";
			_vars.map_id = mapUid;
			_request.data = _vars;
			urlLoader.load(_request);
		}
	
		public function saveMap(mapUid:int, mapSourceXML:String):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, saveMapHandler);
			
			_vars = new URLVariables();
			_vars.action = "save_config";
			_vars.map_id = mapUid;
			_vars.config = mapSourceXML;
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function deleteBackground(mapUid:int):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, deleteBackgroundHandler);
			
			_vars = new URLVariables();
			_vars.action = "delete_background";
			_vars.filename = "background"+String(mapUid)+".img";
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function loadImagesList():void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadImagesListHandler);
			
			_vars = new URLVariables();
			_vars.action = "download_nodeimage";
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function deleteImage(imageName:String):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, deleteImageHandler);
			
			_vars = new URLVariables();
			_vars.action = "delete_nodeimage";
			_vars.filename = imageName;
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function loadEvents(deviceListXML:String):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadEventsHandler);
			
			_vars = new URLVariables();
			_vars.action = "get_devicesevents";
			_vars.devicelist = deviceListXML;
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
		public function loadDevicesList():void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadDevicesListHandler);
			
			_vars = new URLVariables();
			_vars.action = "get_devicelist";
			_request.data = _vars;
			urlLoader.load(_request);
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function saveTabsHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.TABS_SAVED));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				saveTabsHandler);
		}
		
		private function loadTabsHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.TABS_LOADED, 
				e.target.data));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				loadTabsHandler);
		}
		
		private function deleteMapHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.MAP_DELETED));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				deleteMapHandler);
		}
		
		private function loadMapHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.MAP_LOADED, 
				e.target.data));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				loadMapHandler);
		}
		
		private function saveMapHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.MAP_SAVED));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				saveMapHandler);
		}
		
		private function deleteBackgroundHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.BACKGROUND_DELETED));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				deleteBackgroundHandler);
		}
		
		private function loadImagesListHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.IMAGES_LIST_LOADED,
				e.target.data));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				loadImagesListHandler);
		}
		
		private function deleteImageHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.IMAGE_DELETED));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				deleteImageHandler);
		}
		
		private function loadEventsHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.EVENTS_LOADED,
				e.target.data));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				loadEventsHandler);
		}
		
		private function loadDevicesListHandler(e:Event):void {
			dispatchEvent(new CommunicatorEvent(CommunicatorEvent.DEVICES_LIST_LOADED,
				e.target.data));
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, 
				loadDevicesListHandler);
		}
	}
}