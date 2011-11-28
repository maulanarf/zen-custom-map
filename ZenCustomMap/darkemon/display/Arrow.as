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
package darkemon.display {
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	
	public class Arrow {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		public static const NONE:String = "none";
		public static const GRAB:String = "grab";
		public static const ADD:String = "add";
		public static const DELETE:String = "delete";
		public static const SELECT_FIRST:String = "selectFirst";
		public static const SELECT_SECOND:String = "selectSecond";

		private static var _visible:Boolean = false;
		private static var _currentCursor:Class = null;
		
		[Embed(source="assets/hand-grab-cursor.swf")]
		private static var handGrabCursor:Class;
		
		[Embed(source="assets/add-cursor.png")]
		private static var addCursor:Class;
		
		[Embed(source="assets/delete-cursor.png")]
		private static var deleteCursor:Class;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function Arrow() {
			throw Error("Arrow is a singleton class, use show() instead.");
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		public static function set mode(m:String):void {
			switch(m)
			{
				case GRAB:
					_currentCursor = handGrabCursor;
					break;
				case ADD:
					_currentCursor = addCursor;
					break;
				case DELETE:
					_currentCursor = deleteCursor;
					break;
				case SELECT_FIRST:
					_currentCursor = null;
					break;
				case SELECT_SECOND:
					_currentCursor = null;
					break;
				case NONE:
					_currentCursor = null;
					break;
				default:
					_currentCursor = null;
					CursorManager.removeAllCursors();
					break;
			}
			if(_visible) {
				hide();
				show();
			}
		}
		
		public static function show():void {
			_visible = true;
			if(_currentCursor == null) CursorManager.removeAllCursors();
			else CursorManager.setCursor(_currentCursor);
		}
		
		public static function hide():void {
			_visible = false;
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		public static function set busySystem(flag:Boolean):void {
			if(flag) {
				CursorManager.setBusyCursor();
				FlexGlobals.topLevelApplication.enabled = false;
			} else {
				CursorManager.removeBusyCursor();
				FlexGlobals.topLevelApplication.enabled = true;
			}
		}
	}
}