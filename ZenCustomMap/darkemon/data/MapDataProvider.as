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
package darkemon.data {
	
	import darkemon.display.Node;
	import darkemon.events.CommunicatorEvent;
	import darkemon.net.Communicator;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	public class MapDataProvider {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var _mapUid:int;
		private var _graphLineWidth:int = 1;
		private var _graphLineColor:uint = 0X000000;
		private var _refreshEventsTime:int = 300;
		
		private var _graphData:GraphData = new GraphData();
		private var _timer:Timer;
		private var _comm:Communicator = new Communicator();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function MapDataProvider() {
			_timer = new Timer(_refreshEventsTime*1000);
			_comm.addEventListener(CommunicatorEvent.EVENTS_LOADED, communicatorHandler);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		// Set and get map's uid.
		public function get mapUid():int { return _mapUid; }
		public function set mapUid(id:int):void { _mapUid = id; }
		
		// Set and get the graph line width.
		public function get graphLineWidth():int { return _graphLineWidth; }
		public function set graphLineWidth(w:int):void { _graphLineWidth = w; }
		
		// Set and get the graph line color.
		public function get graphLineColor():uint { return _graphLineColor; }
		public function set graphLineColor(c:uint):void { _graphLineColor = c; }
		
		public function get graphData():GraphData { return _graphData; }
		public function set graphData(gd:GraphData):void { _graphData = gd; }
		
		// Set and get the refresh events time interval.
		public function get refreshEventsTime():int { return _refreshEventsTime; }
		public function set refreshEventsTime(t:int):void { 
			_refreshEventsTime = t;
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, refreshEvents);
			_timer = new Timer(_refreshEventsTime*1000);
			_timer.addEventListener(TimerEvent.TIMER, refreshEvents);
			_timer.start();
		} 
		
		public function searchNodes(s:String, type:String="name"):Array {
			return _graphData.searchNodes(s, type);
		}
		
		public function updateEventsImmediate():void {
			_timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function setDevicesEvents():void {
			var xml:XML = new XML("<device_list/>");
			var dev:XML;
			
			// Generate device list and clear event states.
			for(var i:int=0; i<_graphData.nodesCount; i++) {
				if(_graphData.getNode(i) != null) {
					var n:Node = (_graphData.getNode(i) as Node);
					n.eventState = Node.CLEAR_STATE;
					var str:String;
					if(n.type == "submap") {
						str = "<device id='"+String(n.nodeId)+
							"' type='"+n.type+"'>"+n.submapUid+"</device>"
					} else {
						str = "<device id='"+String(n.nodeId)+
							"' type='"+n.type+"'>"+n.ip+"</device>"
					}
					dev = new XML(str);
					xml.appendChild(dev);
				}
			}
			
			_comm.loadEvents(xml.toXMLString());
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------

		private function communicatorHandler(e:CommunicatorEvent):void {
			if(e.type == CommunicatorEvent.EVENTS_LOADED) {
				var xml:XML = new XML(e.data);
				for each(var evt:XML in xml.elements("device")) {
					var id:int = int(evt.attribute("id"));
					var n:Node = _graphData.getNode(id); 
					n.eventState = int(evt.attribute("severity"));
					n.message = evt.toString();
				}
			}
		}
		
		private function refreshEvents(e:TimerEvent):void {
			setDevicesEvents();
		}
	}
}