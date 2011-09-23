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
	import fl.controls.Button;
	import fl.controls.ComboBox;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import darkemon.ui.ToolTip;
	import darkemon.events.ToolBarEvent;
	
	/*
	* Class ToolBar is a singleton.
	*
	*
	*/
	
	public class ToolBar extends Sprite {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _instance : ToolBar = null;
		private static var _allowInstantiation : Boolean = false;
		
		private static var panBtn : Button      = new Button();
		private static var moveNodeBtn : Button = new Button();
		private static var addNodeBtn : Button  = new Button();
		private static var delNodeBtn : Button  = new Button();
		private static var addEdgeBtn : Button  = new Button();
		private static var delEdgeBtn : Button  = new Button();
		
		private static var saveBtn : Button = new Button();
		private static var prefBtn : Button = new Button();
		private static var scaleBox : ComboBox = new ComboBox();
				
		private static var selectedButton  : Button;
		private static var displayedButton : Dictionary = new Dictionary();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function ToolBar()
		{
			if(!_allowInstantiation) {
				throw Error("ToolBar is a singleton class, use getInstance() instead.");
			}
			
			panBtn.label = "";
			moveNodeBtn.label = "";
			addNodeBtn.label = "";
			delNodeBtn.label = "";
			addEdgeBtn.label = "";
			delEdgeBtn.label = "";
			saveBtn.label = "";
			prefBtn.label = "";
			
			panBtn.alpha = 100;
			moveNodeBtn.alpha = 100;
			addNodeBtn.alpha = 100;
			delNodeBtn.alpha = 100;
			addEdgeBtn.alpha = 100;
			delEdgeBtn.alpha = 100;
			saveBtn.alpha = 100;
			prefBtn.alpha = 100;
			scaleBox.alpha = 100;
			
			panBtn.toggle = true;
			moveNodeBtn.toggle = true;
			addNodeBtn.toggle = true;
			delNodeBtn.toggle = true;
			addEdgeBtn.toggle = true;
			delEdgeBtn.toggle = true;
			
			panBtn.setSize(25,25);
			moveNodeBtn.setSize(25,25);
			addNodeBtn.setSize(25,25);
			delNodeBtn.setSize(25,25);
			addEdgeBtn.setSize(25,25);
			delEdgeBtn.setSize(25,25);
			saveBtn.setSize(25,25);
			prefBtn.setSize(25,25);
			
			panBtn.setStyle("icon", GrabHandSkin);
			moveNodeBtn.setStyle("icon", MoveNodeSkin);
			addNodeBtn.setStyle("icon", AddNodeSkin);
			delNodeBtn.setStyle("icon", DelNodeSkin);
			addEdgeBtn.setStyle("icon", AddEdgeSkin);
			delEdgeBtn.setStyle("icon", DelEdgeSkin);
			saveBtn.setStyle("icon", SaveSkin);
			prefBtn.setStyle("icon", PrefSkin);
			
			scaleBox.height = 25;
			scaleBox.width = 65;
			scaleBox.addItem({label:"25%"});
			scaleBox.addItem({label:"50%"});
			scaleBox.addItem({label:"75%"});
			scaleBox.addItem({label:"100%"});
			scaleBox.addItem({label:"200%"});
			scaleBox.addItem({label:"300%"});
			scaleBox.addItem({label:"400%"});
			scaleBox.selectedIndex = 3;
			
			panBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			moveNodeBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			addNodeBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			delNodeBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			addEdgeBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			delEdgeBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			saveBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			prefBtn.addEventListener(MouseEvent.CLICK, clickOnButtonListener);
			
			panBtn.addEventListener(MouseEvent.MOUSE_OVER, overButtonListener);
			panBtn.addEventListener(MouseEvent.MOUSE_OUT, overButtonListener);
			saveBtn.addEventListener(MouseEvent.MOUSE_OVER, overButtonListener);
			saveBtn.addEventListener(MouseEvent.MOUSE_OUT, overButtonListener);
			prefBtn.addEventListener(MouseEvent.MOUSE_OVER, overButtonListener);
			prefBtn.addEventListener(MouseEvent.MOUSE_OUT, overButtonListener);
			
			moveNodeBtn.addEventListener(MouseEvent.MOUSE_OVER, overNodeButtonListener);
			addNodeBtn.addEventListener(MouseEvent.MOUSE_OVER, overNodeButtonListener);
			delNodeBtn.addEventListener(MouseEvent.MOUSE_OVER, overNodeButtonListener);

			moveNodeBtn.addEventListener(MouseEvent.MOUSE_OUT, overNodeButtonListener);
			addNodeBtn.addEventListener(MouseEvent.MOUSE_OUT, overNodeButtonListener);
			delNodeBtn.addEventListener(MouseEvent.MOUSE_OUT, overNodeButtonListener);
			
			addEdgeBtn.addEventListener(MouseEvent.MOUSE_OVER, overEdgeButtonListener);
			delEdgeBtn.addEventListener(MouseEvent.MOUSE_OVER, overEdgeButtonListener);
			
			addEdgeBtn.addEventListener(MouseEvent.MOUSE_OUT, overEdgeButtonListener);
			delEdgeBtn.addEventListener(MouseEvent.MOUSE_OUT, overEdgeButtonListener);
			
			scaleBox.addEventListener(Event.CHANGE, changeScaleListener);
			
			addChild(panBtn);
			addChild(moveNodeBtn);
			addChild(addNodeBtn);
			addChild(delNodeBtn);
			addChild(addEdgeBtn);
			addChild(delEdgeBtn);
			addChild(saveBtn);
			addChild(prefBtn);
			addChild(scaleBox);
			
			panBtn.move(0, 0);
			moveNodeBtn.move(30, 0);
			addNodeBtn.move(30, 25);
			delNodeBtn.move(30, 50);
			addEdgeBtn.move(60, 0);
			delEdgeBtn.move(60, 25);
			
			saveBtn.move(90, 0);
			prefBtn.move(120, 0);
			scaleBox.move(150, 0);
			
			selectedButton = panBtn;
			selectedButton.selected = true;
			displayedButton["node"] = moveNodeBtn;
			displayedButton["edge"] = addEdgeBtn;
			
			setUpDropDownButton("node", moveNodeBtn);
			setUpDropDownButton("edge", addEdgeBtn);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public static function getInstance() : ToolBar {
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new ToolBar();
				_allowInstantiation = false;
			}
			return _instance;
		}
		
		public function currentScaleBoxIndex(i : int) : void {
			scaleBox.selectedIndex = i;
		}
		
		override public function get width() : Number {
			return panBtn.x + scaleBox.x + scaleBox.width;
		}
		
		override public function set height(w : Number) : void {
			throw Error("Property height is only for read.");
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private static function visibleAllDropDownButtons(type : String, flag : Boolean) : void 
		{
			switch(type) {
				case "node":
					addNodeBtn.visible = flag;
					delNodeBtn.visible = flag;
					moveNodeBtn.visible = flag;
					break;
				case "edge":
					addEdgeBtn.visible = flag;
					delEdgeBtn.visible = flag;
					break;
			}
		}
				
		/* To display the button from the list of buttons. */
		private static function setUpDropDownButton(type : String, btn : Button) : void 
		{
			var tmpX : Number = btn.x;
			var tmpY : Number = btn.y;
			btn.x = displayedButton[type].x;
			btn.y = displayedButton[type].y;
			displayedButton[type].x = tmpX;
			displayedButton[type].y = tmpY;
			displayedButton[type] = btn;
			visibleAllDropDownButtons(type, false);
			displayedButton[type].visible = true;
		}
		
		//--------------------------
		//    Listeners.
		//--------------------------
		
		private static function overButtonListener(e : MouseEvent) : void {
			switch(e.type) 
			{
				case MouseEvent.MOUSE_OVER:
					switch(e.target) {
						case panBtn:
							ToolTip.showToolTip(_instance, "Move map", 1000);
							break;
						case saveBtn:
							ToolTip.showToolTip(_instance, "Save map", 1000);
							break;
						case prefBtn:
							ToolTip.showToolTip(_instance, "Preferences", 1000);
							break;
					}
					break;
				case MouseEvent.MOUSE_OUT:
					ToolTip.hideToolTip();
					break;
			}
		}
		
		private static function overNodeButtonListener(e : MouseEvent) : void {
			switch(e.type) 
			{
				case MouseEvent.MOUSE_OVER:
					visibleAllDropDownButtons("node", true);
					switch(e.target) {
						case moveNodeBtn:
							ToolTip.showToolTip(_instance, "Move node", 1000);
							break;
						case addNodeBtn:
							ToolTip.showToolTip(_instance, "Add node", 1000);
							break;
						case delNodeBtn:
							ToolTip.showToolTip(_instance, "Delete node", 1000);
							break;
					}
					break;
				case MouseEvent.MOUSE_OUT:
					visibleAllDropDownButtons("node", false);
					displayedButton["node"].visible = true;
					ToolTip.hideToolTip();
					break;
			}
		}
		
		private static function overEdgeButtonListener(e : MouseEvent) : void {
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:
					visibleAllDropDownButtons("edge", true);
					switch(e.target) {
						case addEdgeBtn:
							ToolTip.showToolTip(_instance, "Add edge", 1000);
							break;
						case delEdgeBtn:
							ToolTip.showToolTip(_instance, "Delete edge", 1000);
							break;
					}
					break;
				case MouseEvent.MOUSE_OUT:
					visibleAllDropDownButtons("edge", false);
					displayedButton["edge"].visible = true;
					ToolTip.hideToolTip();
					break;
			}
		}

		private static function clickOnButtonListener(e : MouseEvent) : void {

			function selectBtn() : void {
				selectedButton.selected = false;
				selectedButton = (e.target as Button);
				selectedButton.selected = true;
			}
			
			switch(e.target) {
				case panBtn:
					selectBtn();
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.MOVE_MAP, false, false));
					break;
				case moveNodeBtn:
					selectBtn();
					setUpDropDownButton("node", selectedButton);
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.MOVE_NODE, false, false));
					break;
				case addNodeBtn:
					selectBtn();
					setUpDropDownButton("node", selectedButton);
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.ADD_NODE, false, false));
					break;
				case delNodeBtn:
					selectBtn();
					setUpDropDownButton("node", selectedButton);
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.DEL_NODE, false, false));
					break;
				case addEdgeBtn:
					selectBtn();
					setUpDropDownButton("edge", selectedButton);
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.ADD_EDGE, false, false));
					break;
				case delEdgeBtn:
					selectBtn();
					setUpDropDownButton("edge", selectedButton);
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.DEL_EDGE, false, false));
					break;
				case saveBtn:
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.SAVE_DATA, false, false));
					break;
				case prefBtn:
					_instance.dispatchEvent(new ToolBarEvent(ToolBarEvent.OPEN_PREF, false, false));
					break;
			}
		}
		
		private function changeScaleListener(e : Event) : void 
		{
			var v : String = (e.target as ComboBox).value;
			switch(v) 
			{
				case "25%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 0.25));
					break;
				case "50%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 0.5));
					break;
				case "75%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 0.75));
					break;
				case "100%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 1));
					break;
				case "200%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 2));
					break;
				case "300%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 3));
					break;
				case "400%":
					dispatchEvent(new ToolBarEvent(ToolBarEvent.SCALE_MAP, false, false, 4));
					break;
			}
		}
	}
}