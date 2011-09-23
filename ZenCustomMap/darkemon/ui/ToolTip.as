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
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class ToolTip extends Sprite {
		
		public static const LEFT : String = "left";
		public static const RIGHT : String = "right";
		public static const TOP : String = "top";
		public static const BOTTOM : String = "bottom";
		
		private static var _instance : ToolTip = null;
		private static var _allowInstantiation : Boolean = false;
		private static var _isVisible : Boolean = false;
		
		private static var _hint : TextField;
		private static var _stage : Stage;
		private static var _timer : Timer;
		private static var _pos : String;
		
		//--------------------------
		//    Listeners.
		//--------------------------
		
		private static function mouseListener(e : MouseEvent) : void {
			switch(_pos) 
			{
				case BOTTOM:
					_hint.x = _stage.mouseX;
					_hint.y = _stage.mouseY + 20;
					break;
				case TOP:
					_hint.x = _stage.mouseX;
					_hint.y = _stage.mouseY - 20;
					break;
				case LEFT:
					_hint.x = _stage.mouseX - (_hint.width + 5);
					_hint.y = _stage.mouseY + 1;
					break;
				case RIGHT:
					_hint.x = _stage.mouseX + 15;
					_hint.y = _stage.mouseY + 1;
					break;
			}
		}
		
		private static function onTimer(e : TimerEvent) : void {
			_stage.addChild(_hint);
		}
		
		//--------------------------
		//    Public methods.
		//--------------------------
		
		/* Constructor. */
		public function ToolTip(container : DisplayObject) {
			if(!_allowInstantiation) {
				throw Error("ToolTip is a singleton class, use getInstance() instead.");
			}
												
			if(container != null) {
				_stage = container.stage;
			} else if(stage) {
				_stage = stage;
				parent.removeChild(this);
			}
			
			_hint = new TextField();
			_hint.selectable = false;
			_hint.background = true;
			_hint.backgroundColor = 0xFFFFCC;
			_hint.border = true;
			_hint.autoSize = TextFieldAutoSize.CENTER;
		}
		
		public static function isVisible() : Boolean {
			return _isVisible;
		}
		
		public static function getInstance(container : DisplayObject) : ToolTip 
		{
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new ToolTip(container);
				_allowInstantiation = false;
			}
			return _instance;
		}
		
		public static function showToolTip(container : DisplayObject, txt : String, 
										   delay : Number = 0, pos : String = BOTTOM) : void
		{
			if(_instance == null) {
				getInstance(container);
			}
			
			_pos = pos;
			
			_timer = new Timer(delay, 1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			
			_hint.text = txt;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseListener);
			_isVisible = true;
		}
		
		public static function hideToolTip() : void {
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer = null;
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseListener);
			if(_hint.parent) _stage.removeChild(_hint);
			_isVisible = false;
		}
	}
}