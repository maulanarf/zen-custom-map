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
	
	import darkemon.events.NodeEvent;
	import darkemon.ui.NodeMenu;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	
	public class Node extends Group {
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		public static const MULTIPLE_SELECTION:String = "multipleSelection";
		public static const SINGLE_SELECTION:String = "singleSelection";
		
		public static const CRITICAL_STATE:int = 5;
		public static const ERROR_STATE:int = 4;
		public static const WARNING_STATE:int = 3;
		public static const CLEAR_STATE:int = 0;
		
		private static var _selectedNodes:ArrayCollection = new ArrayCollection();
		private static var _selectionMode:String = SINGLE_SELECTION;

	//--------------------------------------
	//  Properties
	//--------------------------------------

		private var _id:int;
		private var _color:int = 0X00CC00; // green
		private var _backAreaColor:int = 0x25f97f; // light green
		private var _ip:String;
		private var _zenClass:String;
		private var _image:Image = new Image();
		private var _imageName:String = null;
		private var _select:Boolean = false;
		private var _type:String = "node";
		private var _subMapUid:uint = undefined; // for node type 'submap'

		private var backArea:UIComponent = new UIComponent();
		private var displayLabel:Label = new Label();
		private var messageField:Label = new Label();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function Node(nId:int) 
		{
			_id = nId;
			toolTip = "Double click for open menu";
					
			_image.height = _image.width = 40;
			_image.x = _image.y = 0;
			_image.x -= _image.width / 2;
			_image.y -= _image.height / 2;
			
			drawDefaultImage();
			addElement(backArea);
			addElement(_image);
			addElement(displayLabel);
			addElement(messageField);
			
			displayLabel.setStyle("textAlign", "center");
			displayLabel.setStyle("fontWeight", "bold");
			displayLabel.setConstraintValue("horizontalCenter", 0);
			displayLabel.setConstraintValue("top", _image.height/2+5);
			
			messageField.setStyle("textAlign", "center");
			messageField.setStyle("fontWeight", "bold");
			messageField.setStyle("fontSize", "14");
			messageField.setStyle("color", "#FF0000");
			messageField.setConstraintValue("horizontalCenter", 0);
			messageField.setConstraintValue("top",
				_image.height/2+24);

			// Set button mode.
			doubleClickEnabled = true;
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			// Add listeners.
			setActive(true);
			
			updateBackArea();
		}
		
	//--------------------------------------
	//  Public Static Methods
	//--------------------------------------
		
		public static function get selectionMode():String {
			return _selectionMode;
		}
		
		public static function set selectionMode(m:String):void {
			_selectionMode = m;
		}
		
		public static function unselectAll():void {
			if(_selectedNodes.length != 0) {
				for each(var n:Node in _selectedNodes) {
					n.clearSelect();
				}
				_selectedNodes.removeAll();
			}
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/* Set and get value of the node ID. */
		public function get nodeId():int { return _id; }
		public function set nodeId(nId:int):void { _id = nId; }
		
		public function get select():Boolean { return _select; }
		public function set select(flag:Boolean):void {
			switch(_selectionMode) {
				case MULTIPLE_SELECTION:
					if(flag && !_select) _selectedNodes.addItem(this);
					if(!flag && _select) {
						var i:int = _selectedNodes.getItemIndex(this);
						_selectedNodes.removeItemAt(i);
					}
					break; 
				case SINGLE_SELECTION:
					unselectAll();
					if(flag && !_select) _selectedNodes.addItem(this);
					break;
			}
			_select = flag;
			updateBackArea();
		}
		
		public function get type():String { return _type; }
		public function set type(t:String):void { 
			_type = t;
			if(_type == "node") {
				_subMapUid = undefined;
			} else {
				_ip = null;
				_zenClass = null;
			}
			updateBackArea();
		}
		
		/* Set and get value of the node name. */
		public function get nodeName():String { return displayLabel.text; }
		public function set nodeName(s:String):void { displayLabel.text = s; }
		
		/* Set and get value of the background color. */
		public function get defaultNodeColor():int { return _color; }
		public function set defaultNodeColor(c:int):void { _color = c; }
		
		public function get message():String { return messageField.text; }
		public function set message(t:String):void { messageField.text = t; }
		
		public function get imageName():String { return _imageName; }
		public function getImage():UIComponent { return _image; }
		
		public function setImage(img:Object, imgName:String):void 
		{
			if(img != null && imgName == null) throw Error(
				"darkemon::display::Node::setImage()\nImage name can't be null!");
			
			if(img == null) {
				_imageName = null;
				drawDefaultImage();
			} else {
				_imageName = imgName;
				_image.graphics.clear();
			}
			_image.source = img;
		}
		
		public function get ip():String { return _ip; }
		public function set ip(ipAddress:String):void { _ip = ipAddress; }
		
		public function get zenClass():String { return _zenClass; }
		public function set zenClass(path:String):void { _zenClass = path; }
		
		public function get submapUid():uint { return _subMapUid; }
		public function set submapUid(uid:uint):void { _subMapUid = uid; }
		
		/* Use this method before deleting the node. */
		public function free() : void {
			// Remove childs.
			removeElement(backArea);
			removeElement(_image);
			removeElement(displayLabel);
			_image = null;
			
			// Delete listeners.
			setActive(false);
		}
			
		public function setActive(active:Boolean):void {
			if(active) {
				addEventListener(MouseEvent.MOUSE_OVER, mouseListener);
				addEventListener(MouseEvent.MOUSE_OUT, mouseListener);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				addEventListener(MouseEvent.MOUSE_UP, mouseListener);
				addEventListener(MouseEvent.DOUBLE_CLICK, mouseListener);
			} else {
				removeEventListener(MouseEvent.MOUSE_OVER, mouseListener);
				removeEventListener(MouseEvent.MOUSE_OUT, mouseListener);
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				removeEventListener(MouseEvent.MOUSE_UP, mouseListener);
				removeEventListener(MouseEvent.DOUBLE_CLICK, mouseListener);
			}
		}
		
		public function set eventState(s:int):void {
			switch(s)
			{
				case CRITICAL_STATE:
					_backAreaColor = 0xed4119;
					break;
					
				case ERROR_STATE:
					_backAreaColor = 0xf18c32;
					break;
				
				case WARNING_STATE:
					_backAreaColor = 0xf2d82b;
					break;
				
				case CLEAR_STATE:
					_backAreaColor = 0x25f97f;
					break;
			}
			updateBackArea();
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		protected function clearSelect():void {
			_select = false;
			updateBackArea();
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function drawDefaultImage():void {
			_image.graphics.clear();
			_image.graphics.lineStyle(1);
			_image.graphics.beginFill(_color);
			_image.graphics.drawCircle(_image.width/2, _image.height/2, 10);
		}
				
		private function updateBackArea():void {
			if(_image != null) {
				backArea.graphics.clear();
				backArea.graphics.lineStyle(_select?2:0, 0x000000, _select?1:0);
				backArea.graphics.beginFill(_backAreaColor, 0.7);
				switch(_type) {
					case "node":
						backArea.graphics.drawCircle(0, 0, 
							(Math.max(_image.height,_image.width)/2)+10);
						break;
					case "submap":
						var size:int = Math.max(_image.height,_image.width)+30;
						backArea.graphics.drawRoundRect(-size/2, -size/2, size, size, 5, 5);
						break;
				}
			}
		}
			
	//--------------------------------------
	//  Handlers
	//--------------------------------------
			
		// The mouse events listener.
		private function mouseListener(e : MouseEvent) : void {
			if( !(e.target is Label) ) {
				switch(e.type)
				{
					case MouseEvent.DOUBLE_CLICK:
						NodeMenu.show(this);
						break;
					case MouseEvent.MOUSE_OVER:
				    	break;
					case MouseEvent.MOUSE_OUT:
						break;
					case MouseEvent.MOUSE_DOWN:
						unselectAll();
						select = true;
						startDrag();
						break;
					case MouseEvent.MOUSE_UP:
						stopDrag();
						break;
				}
			}
		}
	}
}