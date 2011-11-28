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
	
	import mx.core.UIComponent;
		
	public class TabBarEvent extends Event {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		public static const CHANGE_LABEL:String = "changeLabel";
		public static const CLOSE_TAB:String = "closeTab";
		public static const ADD_TAB:String = "addTab";
		public static const SELECT_TAB:String = "selectTab";
		
		private var _tabLabel:String;
		private var _tabUid:int;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function TabBarEvent(type:String, tabLabel:String="", tabUid:int=-1, 
									bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			_tabLabel = tabLabel;
			_tabUid = tabUid;
		}
		
		public function get tabLabel():String { return _tabLabel; }
		
		public function get tabUid():int { return _tabUid; }
		
		override public function toString():String {
	        return formatToString("TabBarEvent", "type", "tabLabel", "tabUid", 
				"bubbles", "cancelable");
		}
		
		override public function clone():Event {
        	return new TabBarEvent(type, _tabLabel, _tabUid, bubbles, cancelable);
		}
	}
}