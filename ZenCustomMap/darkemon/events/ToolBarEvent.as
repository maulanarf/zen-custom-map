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
		
	public class ToolBarEvent extends Event {
		public static const MOVE_MAP:String = "moveMap";
		public static const MOVE_NODE:String = "moveNode";
		public static const ADD_NODE:String = "addNode";
		public static const DEL_NODE:String = "delNode";
		public static const ADD_EDGE:String = "addEdge";
		public static const DEL_EDGE:String = "delEdge";
		public static const SAVE_DATA:String = "saveData";
		public static const OPEN_PREF:String = "openPref";
		public static const SCALE_MAP:String = "scaleMap";
		
		private var _mapScale:Number;

		public function ToolBarEvent(type:String, mapScale:Number=1, 
			bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			_mapScale = mapScale;
		}
		
		public function get mapScale():Number { 
			return _mapScale; 
		}
				
		override public function toString():String {
	        return formatToString("ToolBarEvent", "type", "bubbles", "cancelable",
                    "mapScale");
		}
		
		override public function clone():Event {
        	return new ToolBarEvent(type, _mapScale, bubbles, cancelable);
		}
	}
}