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
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.ui.Mouse;
	
	import flash.events.Event;
	
	public class Arrow extends MovieClip {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		public static const NONE : String = "none";
		public static const GRAB : String = "grab";
		public static const ADD : String = "add";
		public static const DELETE : String = "delete";
		public static const SELECT_FIRST : String = "selectFirst";
		public static const SELECT_SECOND : String = "selectSecond";
		
		private static var _instance : Arrow = null;
		private static var _allowInstantiation : Boolean = false;
		private static var _isVisible : Boolean = false;
		private static var _curArrow : String = GRAB;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function Arrow() {
			if(!_allowInstantiation) {
				throw Error("Arrow is a singleton class, use getInstance() instead.");
			}
			stop();
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		public static function getInstance() : Arrow {
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new Arrow();
				_allowInstantiation = false;
			}
			return _instance;
		}
		
		public static function isVisible() : Boolean {
			return _isVisible;
		}
		
		public static function show(container : MovieClip) : void {
			if(_instance == null) {
				getInstance();
			}
			var _stage : Stage = container.stage;
			_stage.addEventListener(Event.RENDER, _instance.onTopHandler);
			_stage.addChildAt(_instance, Math.max(_stage.numChildren-1,0));
			_instance.addEventListener(Event.ENTER_FRAME, _instance.enterFrameHandler);
			_isVisible = true;
			
			_instance.updateArrow(_curArrow);
		}
		
		public static function hide() : void {
			if(_isVisible) {
				var _stage : Stage = _instance.parent.stage;
				Mouse.show();
				_stage.removeChild(_instance);
				_stage.removeEventListener(Event.RENDER, _instance.onTopHandler);
				_instance.removeEventListener(Event.ENTER_FRAME, _instance.enterFrameHandler);
				_isVisible = false;
			}
		}
		
		public static function get arrow() : String { return _curArrow; }
		public static function set arrow(a : String) : void { 
			_curArrow = a; 
			if(_isVisible) _instance.updateArrow(_curArrow);
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
	
		private function updateArrow(a : String) : void {
			switch(_curArrow)
			{
				case GRAB:
					Mouse.hide();
					_instance.gotoAndStop(1);
					break;
				case ADD:
					Mouse.show();
					_instance.gotoAndStop(2);
					break;
				case DELETE:
					Mouse.show();
					_instance.gotoAndStop(3);
					break;
				case SELECT_FIRST:
					Mouse.show();
					_instance.gotoAndStop(4);
					break;
				case SELECT_SECOND:
					Mouse.show();
					_instance.gotoAndStop(5);
					break;
				case NONE:
					Mouse.show();
					_instance.gotoAndStop(6);
					break;
			}
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
	
		private function onTopHandler(e : Event) : void {
			_instance.parent.stage.setChildIndex(_instance, Math.max(_instance.parent.stage.numChildren-1,0));
		}
		
		private function enterFrameHandler(e : Event) : void {
			_instance.x = _instance.parent.stage.mouseX;
			_instance.y = _instance.parent.stage.mouseY;
		}
	}
}