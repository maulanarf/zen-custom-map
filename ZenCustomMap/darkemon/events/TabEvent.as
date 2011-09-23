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
		
	public class TabEvent extends Event {
		public static const CHANGE_LABEL : String = "changeLabel";
		public static const CLOSE_TAB : String = "closeTab";
		public static const ADD_TAB : String = "addTab";
		public static const SELECT_TAB : String = "selectTab";
		
		var _tabLabel : String;
		var _tabId : int;
	
		public function TabEvent(type:String, bubbles:Boolean, cancelable:Boolean,
								 tabLabel:String, tabId:int) 
		{
			super(type, bubbles, cancelable);
			_tabLabel = tabLabel;
			_tabId = tabId;
		}
		
		public function get tabLabel() : String { return _tabLabel; }
		
		public function get tabId() : int { return _tabId; }

		
		override public function toString() : String {
	        return formatToString("TabEvent", "type", "bubbles", "cancelable",
                    "tabLabel", "tabId");
		}
		
		override public function clone() : Event {
        	return new TabEvent(type, bubbles, cancelable, _tabLabel, _tabId);
		}
	}
}