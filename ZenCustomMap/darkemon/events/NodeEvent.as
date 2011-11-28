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
		
	public class NodeEvent extends Event {
		public static const OPEN_PREF:String = "openPreferences";
		public static const OPEN_LIBRARY:String = "openLibrary";
		public static const OPEN_EVENTS:String = "openEvents";
		public static const OPEN_SUBMAP:String = "openSubMap";
		public static const DOUBLE_CLICK:String = "doubleClick";
	
		public function NodeEvent(type : String, 
				bubbles : Boolean = false, 
				cancelable : Boolean = false) 
		{
			super(type, bubbles, cancelable);
		}
		
		override public function toString() : String {
	        return formatToString("NodeEvent", "type", "bubbles", "cancelable",
                    "eventPhase");
		}
		
		override public function clone() : Event {
        	return new NodeEvent(type, bubbles, cancelable);
		}
	}
}