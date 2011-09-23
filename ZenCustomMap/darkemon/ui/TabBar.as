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
	import com.yahoo.astra.fl.controls.Carousel;
	import com.yahoo.astra.fl.controls.carouselClasses.SlidingCarouselRenderer;

	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import fl.controls.Button;
	import fl.data.DataProvider;

	import darkemon.events.TabEvent;

	public class TabBar extends MovieClip {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		private var _width : Number = 300;
		private var _isHide : Boolean = false;
		private var _action : TabEvent = null;
		
		private var carousel : Carousel = new Carousel();
		private var layout : SlidingCarouselRenderer = new SlidingCarouselRenderer();
		private var nextBtn : Button = new Button();
		private var backBtn : Button = new Button();
		private var addBtn : Button = new Button();
		private var showBtn : Button = new Button();
		private var tabIDs : Array;
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function TabBar() {
			nextBtn.setSize(15, 27);
			backBtn.setSize(15, 27);
			addBtn.setSize(15, 27);
			showBtn.setSize(15,27);
			showBtn.alpha = 100;
			nextBtn.setStyle("icon", "NextTab");
			backBtn.setStyle("icon", "BackTab");
			addBtn.setStyle("icon", "AddTab");
			showBtn.setStyle("icon", "BackTab");
			//nextBtn.y = 5;
			//backBtn.y = 5;
			//addBtn.y = 5;
			
			backBtn.addEventListener(MouseEvent.CLICK, backTabHandler);
			nextBtn.addEventListener(MouseEvent.CLICK, nextTabHandler);
			addBtn.addEventListener(MouseEvent.CLICK, addTabHandler);
			showBtn.addEventListener(MouseEvent.CLICK, showHideHandler);
			
			carousel.setStyle("cellRenderer", "Tab");
			carousel.setStyle("skin", Shape);
			
			carousel.labelField = "label";  
			carousel.sourceField = "data";
			
			carousel.height = 34;
			carousel.width = 300;
						
			layout.horizontalAlign = "center";
			layout.clickToSelect = true;
			
			layout.addEventListener(TabEvent.CHANGE_LABEL, tabsListener);
			layout.addEventListener(TabEvent.CLOSE_TAB, tabsListener);
			layout.addEventListener(TabEvent.SELECT_TAB, tabsListener);
			
			carousel.layoutRenderer = layout;
			carousel.addEventListener(Event.CHANGE, carouselChangeHandler);
						
			addChild(backBtn);
			addChild(carousel);
			addChild(nextBtn);
			addChild(addBtn);
			addChild(showBtn);
			updateButtonPosition();
		}

	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function get dataProvider() : DataProvider { return carousel.dataProvider; }
		public function set dataProvider(dp : DataProvider) : void { 
			tabIDs = new Array();
			for(var i:int=0; i<dp.length; i++) {
				var item : Object = dp.getItemAt(i);
				if(!(item.data is int)) {
					throw Error("TabBar::dataProvider()\nTab ID not integer!");
				}
				if(tabIDs[item.data] == 1) {
					throw Error("TabBar::dataProvider()\nDuplicate tab id!");
				} else {
					tabIDs[item.data] = 1;
				}
			}
			carousel.dataProvider = dp;
			carousel.drawNow();
			updateButtonEnabledState();
		}

		override public function get width() : Number {
			return nextBtn.width + backBtn.width + addBtn.width + carousel.width + showBtn.width;
		}
		
		override public function set width(w : Number) : void {
			_width = w;
			updateButtonPosition();
			if(_isHide) showBtn.x = 0;
		}
		
		override public function get height() : Number {
			return (nextBtn.height + backBtn.height + addBtn.height + showBtn.height)/4;
		}
		
		override public function set height(w : Number) : void {
			throw Error("Property height is only for read.");
		}
		
		public function get minimize() : Boolean {
			return _isHide;
		}
		
		public function set minimize(f : Boolean) : void {
			if( (!f && _isHide) || (f && !_isHide) ) 
			    showBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		public function get selectedTabId() : int {
			if(length == 0) return -1;
			else {
				var item:Object = carousel.getItemAt(carousel.selectedIndex);
				return item.data;
			}
		}
		
		public function get length() : uint {
			return carousel.length;
		}
					
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function updateButtonEnabledState() : void
		{
			backBtn.enabled = carousel.selectedIndex > 0;
			nextBtn.enabled = carousel.selectedIndex < carousel.length - 1;
		}
		
		private function getUniqueTabId() : int 
		{
			for(var i:int=0; i<=carousel.length; i++) {
				if(tabIDs[i] == undefined) return i;
			}
			return -1;
		}
		
		private function updateButtonPosition() : void {
			carousel.x = backBtn.width;
			carousel.width = _width - nextBtn.width - backBtn.width - addBtn.width - showBtn.width;
			nextBtn.x = carousel.width + backBtn.width; 
			addBtn.x = nextBtn.x + nextBtn.width;
			showBtn.x = addBtn.x + addBtn.width;
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function tabsListener(e : TabEvent) : void {
			_action = e;			
			if(e.type == TabEvent.CHANGE_LABEL) {
				carousel.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function backTabHandler(e : MouseEvent) : void {
			var prev : int = carousel.selectedIndex - 1;
			carousel.selectedIndex = Math.max(prev, 0);
			updateButtonEnabledState();
		}
		
		private function nextTabHandler(e : MouseEvent) : void {
			var next : int = carousel.selectedIndex + 1;
			carousel.selectedIndex = Math.min(next, carousel.length - 1);
			updateButtonEnabledState();
		}
		
		private function addTabHandler(e : MouseEvent) : void {
			var newItem : Object = new Object;
			newItem.label = "";
			newItem.data = getUniqueTabId();
			tabIDs[newItem.data] = 1;
						
			carousel.addItem(newItem);
			carousel.selectedIndex = carousel.length - 1;
			updateButtonEnabledState();
			
			dispatchEvent(
				new TabEvent(TabEvent.ADD_TAB, false, false, newItem.label, newItem.data));
		}
		
		private function carouselChangeHandler(e : Event) : void {
			updateButtonEnabledState();
			var item : Object;
			if(_action != null) {
				switch(_action.type) {
					case TabEvent.CHANGE_LABEL:
						item = carousel.getItemAt(carousel.selectedIndex);
						item.label = _action.tabLabel;
						carousel.replaceItemAt(item, carousel.selectedIndex);
						dispatchEvent(
							new TabEvent(TabEvent.CHANGE_LABEL, false, false, item.label, item.data));
						break;
					case TabEvent.CLOSE_TAB:
						item = carousel.getItemAt(carousel.selectedIndex);
						carousel.removeItemAt(carousel.selectedIndex);
						carousel.drawNow();
					
						tabIDs[item.data] = undefined;
						dispatchEvent(
							new TabEvent(TabEvent.CLOSE_TAB, false, false, item.label, item.data));
						break;
					case TabEvent.SELECT_TAB:
					    item = carousel.getItemAt(carousel.selectedIndex);
						dispatchEvent(
							new TabEvent(TabEvent.SELECT_TAB, false, false, item.label, item.data));
						break;
				}
				_action = null;
			}
		}
		
		private function showHideHandler(e : Event) : void {
			if(_isHide) {
				showBtn.setStyle("icon", "BackTab");
				nextBtn.visible = true;
				backBtn.visible = true;
				addBtn.visible = true;
				carousel.visible = true;
				updateButtonPosition();
			} else {
				showBtn.setStyle("icon", "NextTab");
				nextBtn.visible = false;
				backBtn.visible = false;
				addBtn.visible = false;
				carousel.visible = false;
				showBtn.x = 0;
			}
			_isHide = !_isHide;
		}
	}
}
