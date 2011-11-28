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
package darkemon.events {
	import flash.events.Event;
	
	public class CommunicatorEvent extends Event {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		public static const TABS_LOADED:String = "tabsLoaded";
		public static const TABS_SAVED:String = "tabsSaved";
		public static const MAP_DELETED:String = "mapDeleted";
		public static const MAP_LOADED:String = "mapLoaded";
		public static const MAP_SAVED:String = "mapSaved";
		public static const BACKGROUND_DELETED:String = "backgroundDeleted";
		public static const IMAGES_LIST_LOADED:String = "imagesListLoaded";
		public static const IMAGE_DELETED:String = "imageDeleted";
		public static const EVENTS_LOADED:String = "eventsLoaded";
		public static const DEVICES_LIST_LOADED:String = "devicesListLoaded";
		
		private var _data:String;
				
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function CommunicatorEvent(type:String, data:String="", 
			bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function get data():String { return _data; }
		
		override public function toString():String {
			return formatToString("CommunicatorEvent", "type", "bubbles", 
				"cancelable");
		}
		
		override public function clone():Event {
			return new CommunicatorEvent(type, _data, bubbles, cancelable);
		}
	}
}