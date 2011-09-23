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
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Shape;
		
	import flash.filters.DropShadowFilter;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
		
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	import flash.net.URLRequest;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
		
	import darkemon.events.NodeEvent;
	
	public class Node extends Sprite {
				
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		public static const CRITICAL_STATE : int = 5;
		public static const ERROR_STATE : int = 4;
		public static const WARNING_STATE : int = 3;
		public static const CLEAR_STATE : int = 0;
	
		private static var _textSize : int = 18;

		private var _id : int;
		private var _color : int = 0X00CC00; // green
		private var _ip : String;
		private var _zpath : String;
		private var _image : DisplayObject = null;
		private var _imageName : String = null;
		
		private var nameField : Sprite = new Sprite();
		private var txtField : TextField = new TextField();
		private var _textMargin : int = 0;
		
		private var contMenu : ContextMenu;
		private var prefItem : ContextMenuItem;
		private var imageLibItem : ContextMenuItem;
		private var linkItem : ContextMenuItem;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function Node(id : int) 
		{
			_id = id; // Set id.
			init();
			setContextMenu();
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/* Set and get value of the node ID. */
		public function get id() : int { return _id; }
		public function set id(id : int) : void { _id = id; }
				
		/* Set and get value of the node name. */
		public function get nodeName() : String { return txtField.text; }
		public function set nodeName(s : String) : void {
			txtField.text = s;
			updateNameField(_textMargin);
		}
		
		/* Set and get value of the background color. */
		public function get defaultColor() : int { return _color; }
		public function set defaultColor(c : int) : void { _color = c; }
		
		public function get imageName() : String { return _imageName; }
		public function getImage() : DisplayObject { return _image; }
		
		public function setImage(i : DisplayObject, imgName : String) : void 
		{
			if(_image != null) removeChild(_image);

			if(imgName == null) throw Error("Image name can't be null!");
			_imageName = imgName;
			
			if(i == null) throw Error("Image can't be null!");
			_image = i;
			
			addChild(_image);
			_image.x -= _image.width / 2;
			_image.y -= _image.height / 2;
			updateNameField(_image.height/2);
		}
		
		public function deleteImage() : void {
			if(_image != null) removeChild(_image);
			_image = null;
			_image = drawDefaultImage();
			addChild(_image);
			_imageName = null;
			updateNameField(5);
		}
		
		public function get ip() : String { return _ip; }
		public function set ip(ipAddress : String) : void { _ip = ipAddress; }
		
		public function get zpath() : String { return _zpath; }
		public function set zpath(path : String) : void { _zpath = path; }
		
		/* Use this method before deleting the node. */
		public function free() : void {
			// Remove childs.
			removeChild(_image);
			removeChild(nameField);
			_image = null;
			nameField = null;
			
			// Delete listeners.
			setActive(false);
		}
			
		public function setActive(active : Boolean) : void {
			if(active) {
				addEventListener(MouseEvent.MOUSE_OVER, mouseListener);
				addEventListener(MouseEvent.MOUSE_OUT, mouseListener);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				addEventListener(MouseEvent.MOUSE_UP, mouseListener);
			} else {
				removeEventListener(MouseEvent.MOUSE_OVER, mouseListener);
				removeEventListener(MouseEvent.MOUSE_OUT, mouseListener);
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				removeEventListener(MouseEvent.MOUSE_UP, mouseListener);
			}
		}
		
		public function set eventState(st : int) : void {
			switch(st)
			{
				case CRITICAL_STATE:
					filters = [new DropShadowFilter(0,90,0xFF0000,1,4,4,40)];
					break;
					
				case ERROR_STATE:
					filters = [new DropShadowFilter(0,90,0xFF9900,1,4,4,40)];
					break;
				
				case WARNING_STATE:
					filters = [new DropShadowFilter(0,90,0xFFFF00,1,4,4,40)];
					break;
				
				case CLEAR_STATE:
					filters = null;
					break;
			}
		}
		
		public function loadImageURL(url : URLRequest, imgName : String) : void {
			
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initListener);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorListener);
			loader.load(url);
									
			function initListener(e : Event) : void {
				setImage(loader.content, imgName);
			}
			
			function errorListener(e : IOErrorEvent) : void {
				trace("darkemon::display::Node::loadImageURL\n"+e.text);
			}
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function drawDefaultImage() : Sprite {
			var circle : Sprite = new Sprite();
			circle.graphics.clear();
			circle.graphics.lineStyle(1);
			circle.graphics.beginFill(_color);
			circle.graphics.drawCircle(0, 0, 10);
			return circle;
		}
						
		private function updateNameField(margin : int) : void {
			if(nameField.parent != null) {
				removeChild(nameField);
				nameField.width = txtField.textWidth;
				addChild(nameField);
			}
			nameField.y -= _textMargin;
			nameField.y += margin;
			_textMargin = margin;
		}
		
		private function init() : void {
			// Set the default image.
			_image = drawDefaultImage();
			addChild(_image);
			
			// Set name field.
			var format : TextFormat = new TextFormat();
			format.size = _textSize;
			txtField.defaultTextFormat = format;
			txtField.autoSize = TextFieldAutoSize.CENTER;
			txtField.filters = [new DropShadowFilter(1,90,0xffffff,0.8,4,4,10)];
			txtField.text = "";
			txtField.x = x - txtField.width/2;
			txtField.y = y + txtField.height/2;
			updateNameField(5);
			nameField.addChild(txtField);
			addChild(nameField);
			
			// Set button mode.
			doubleClickEnabled = true;
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			// Add listeners.
			setActive(true);
		}
		
		private function setContextMenu() : void {
			contMenu = new ContextMenu();
			prefItem = new ContextMenuItem("Node preferences");
			imageLibItem = new ContextMenuItem("Image");
			linkItem = new ContextMenuItem("Events");
			
			contMenu.hideBuiltInItems();
			contMenu.customItems.push(prefItem);
			contMenu.customItems.push(imageLibItem);
			contMenu.customItems.push(linkItem);
			prefItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectItemHandler);
			imageLibItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectItemHandler);
			linkItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectItemHandler);
			contextMenu = contMenu;
		}
			
	//--------------------------------------
	//  Handlers
	//--------------------------------------
			
		// The mouse events listener.
		private function mouseListener(e : MouseEvent) : void {
			if( !(e.target is TextField) ) {
				switch(e.type)
				{
					case MouseEvent.MOUSE_OVER:
						//drawSelectNode();
				    	break;
					case MouseEvent.MOUSE_OUT:
				    	//drawUnselectNode();
						break;
					case MouseEvent.MOUSE_DOWN:
						startDrag();
						break;
					case MouseEvent.MOUSE_UP:
						stopDrag();
						break;
				}
			}
		}
		
		private function selectItemHandler(e : ContextMenuEvent) : void {
			switch(e.target) 
			{
				case prefItem:
					dispatchEvent(new NodeEvent(NodeEvent.OPEN_PREF, true, false));
					break;
				case imageLibItem:
					dispatchEvent(new NodeEvent(NodeEvent.OPEN_LIBRARY, true, false));
					break;
				case linkItem:
					dispatchEvent(new NodeEvent(NodeEvent.OPEN_LINK, true, false));
					break;
			}
		}
	}
}