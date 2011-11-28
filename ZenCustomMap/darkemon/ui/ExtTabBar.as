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
	import darkemon.events.TabBarEvent;
	import darkemon.skins.ExtTabBarSkin;
	import darkemon.skins.TabBarButtonAddSkin;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Scroller;
	import spark.components.TabBar;
	import spark.core.NavigationUnit;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.ScrollBarLeftButtonSkin;
	import spark.skins.spark.ScrollBarRightButtonSkin;
	
	public class ExtTabBar extends Group {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var tabBar:TabBar = new TabBar();
		private var backBtn:Button = new Button();
		private var nextBtn:Button = new Button();
		private var addBtn:Button = new Button();
		private var scroller:Scroller = new Scroller();
		private var scrollContainer:HGroup = new HGroup();
		
		private var anim:Animate = new Animate();
		private var path:SimpleMotionPath = new SimpleMotionPath();
		
		private var tabUIDs:Array = new Array();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function ExtTabBar() {
			super();
			width = 150;
			height = 24;
			
			addBtn.toolTip = "Add new map";
						
			backBtn.setStyle("skinClass", Class(spark.skins.spark.ScrollBarLeftButtonSkin));
			nextBtn.setStyle("skinClass", Class(spark.skins.spark.ScrollBarRightButtonSkin));
			addBtn.setStyle("skinClass", Class(darkemon.skins.TabBarButtonAddSkin));
			tabBar.setStyle("skinClass", Class(darkemon.skins.ExtTabBarSkin));
			tabBar.setStyle("cornerRadius", 1);
			scroller.setStyle("horizontalScrollPolicy", "off");
			
			addBtn.width = backBtn.width = nextBtn.width = 24;
			scroller.height = tabBar.height = backBtn.height = 
				nextBtn.height = addBtn.height = 24;
			
			scrollContainer.addElement(tabBar);
			scroller.viewport = scrollContainer;

			// Add animation.
			var v:Vector.<MotionPath> = new Vector.<MotionPath>();
			v.push(path);
			path.property = "horizontalScrollPosition";
			anim.duration = 500;
			anim.motionPaths = v;
			anim.target = scrollContainer;
						
			addElement(backBtn);
			addElement(scroller);
			addElement(nextBtn);
			addElement(addBtn);
			
			backBtn.setConstraintValue("left", 0);
			backBtn.setConstraintValue("top", 0);
			backBtn.setConstraintValue("bottom", 0);
			scroller.setConstraintValue("left", backBtn.width);
			scroller.setConstraintValue("right", backBtn.width+addBtn.width);
			scroller.setConstraintValue("top", 0);
			scroller.setConstraintValue("bottom", 0);
			nextBtn.setConstraintValue("right", addBtn.width);
			nextBtn.setConstraintValue("top", 0);
			nextBtn.setConstraintValue("bottom", 0);
			addBtn.setConstraintValue("right", 0);
			addBtn.setConstraintValue("top", 0);
			addBtn.setConstraintValue("bottom", 0);
			
			backBtn.addEventListener(MouseEvent.CLICK, leftScrollHandler);
			nextBtn.addEventListener(MouseEvent.CLICK, rightScrollHandler);
			addBtn.addEventListener(MouseEvent.CLICK, addButtonHandler);
			tabBar.addEventListener(IndexChangeEvent.CHANGE, selectTabHandler);
			tabBar.addEventListener(TabBarEvent.CHANGE_LABEL, tabEventListener);
			tabBar.addEventListener(TabBarEvent.CLOSE_TAB, tabEventListener);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function get dataProvider():ArrayCollection {
			return ArrayCollection(tabBar.dataProvider);
		}
		
		public function set dataProvider(dp:ArrayCollection):void {
			tabUIDs = new Array();
			for(var i:int=0; i<dp.length; i++) {
				var item:Object = dp.getItemAt(i);
				if(!(item.uid is int)) {
					throw Error("ExtTabBar::dataProvider\nTab uid not integer!");
				}
				if(tabUIDs[item.uid] == 1) {
					throw Error("ExtTabBar::dataProvider\nDuplicate tab uid!");
				} else {
					tabUIDs[item.uid] = 1;
				}
			}
			tabBar.dataProvider = dp;
			if(dp.length > 0) dispatchEvent(
				new TabBarEvent(TabBarEvent.SELECT_TAB, dp[0].label, dp[0].uid));
		}
		
		public function getLabelByUid(uid:int):String {
			for each(var item:Object in tabBar.dataProvider) {
				if(item.uid == uid) return item.label; 
			}
			return "";
		}
		
		public function get selectedTabUid():int {
			if(length == 0) return -1;
			else return tabBar.selectedItem.uid;
		}
		
		public function set selectedTabUid(uid:int):void {
			for(var i:int=0; i<tabBar.dataProvider.length; i++) {
				if(tabBar.dataProvider.getItemAt(i).uid == uid) 
				{
					tabBar.selectedIndex = i;
					dispatchEvent(new TabBarEvent(TabBarEvent.SELECT_TAB, 
						tabBar.selectedItem.label, tabBar.selectedItem.uid));
					break;
				}
			}
		}
		
		public function get length():uint {
			return tabBar.dataProvider.length;
		}
		
		public function hasTabUid(uid:int):Boolean {
			for each(var item:Object in tabBar.dataProvider) {
				if(item.uid == uid) return true;
			}
			return false;
		}
		
		/*
		override public function set height(w:Number):void {
			throw Error("Property height is only for read.");
		}
		
		override public function get height():Number {
			return 24;
		}
		
		override public function set width(w:Number):void {
			var widthBtns:Number = backBtn.width+nextBtn.width+addBtn.width;
			if(w < widthBtns) { scroller.width = 0; }
			else { scroller.width = w - widthBtns; }
		}
		
		override public function get width():Number {
			return scroller.width+backBtn.width+nextBtn.width+addBtn.width;
		} 
		*/
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function getTabUid():int 
		{
			for(var i:int=0; i<=tabBar.dataProvider.length; i++) {
				if(tabUIDs[i] == undefined) return i;
			}
			return -1;
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function leftScrollHandler(e:MouseEvent):void {
			path.valueBy = -120;
			anim.play();
		}
		
		private function rightScrollHandler(e:MouseEvent):void {
			path.valueBy = 120;
			anim.play();
		}
		
		private function addButtonHandler(e:MouseEvent):void {
			var newItem:Object = new Object;
			newItem.label = "";
			newItem.uid = getTabUid();
			tabUIDs[newItem.uid] = 1;
			
			// Add new item and select new tab.
			tabBar.dataProvider.addItem(newItem);
			tabBar.selectedIndex = tabBar.dataProvider.length - 1;
			
			// Move to new tab.
			if(tabBar.dataProvider.length > 1) {
				var tab:UIComponent = 
					tabBar.dataGroup.getElementAt(tabBar.selectedIndex-1) as UIComponent;
				path.valueBy = scrollContainer.getHorizontalScrollPositionDelta(
					NavigationUnit.END) + tab.width;
				anim.play();
			}
			
			dispatchEvent(new TabBarEvent(TabBarEvent.ADD_TAB, newItem.label,
				newItem.uid));
		}
		
		// Animation moving tabs.
		private function selectTabHandler(e:Event):void 
		{
			var tabObject:Object = tabBar.selectedItem;
			var tab:UIComponent = tabBar.dataGroup.getElementAt(tabBar.selectedIndex) 
				as UIComponent;
			var tabRect:Rectangle = tab.getRect(this);
			
			if(nextBtn.hitTestObject(tab)) {
				path.valueBy = tab.width - Math.abs(nextBtn.x - tabRect.x);
				anim.play();
			}
			if(backBtn.hitTestObject(tab)) {
				path.valueBy = -(Math.abs((backBtn.x+backBtn.width+1) - tabRect.x));
				anim.play();
			}
			dispatchEvent(new TabBarEvent(TabBarEvent.SELECT_TAB,
				tabObject.label, tabObject.uid));
		}
		
		private function tabEventListener(e:TabBarEvent):void {
			e.stopImmediatePropagation();
			switch(e.type) {
				case TabBarEvent.CHANGE_LABEL: 
					var item:Object = tabBar.selectedItem;
					item.label = e.tabLabel;
					tabBar.dataProvider.setItemAt(item, tabBar.selectedIndex);
					dispatchEvent(new TabBarEvent(TabBarEvent.CHANGE_LABEL, 
						item.label, item.uid));
					break;
				case TabBarEvent.CLOSE_TAB:
					Alert.show("Delete this map?", "Warning", 
						Alert.YES|Alert.NO, null, alertListener);
					break;
			}
			function alertListener(ev:CloseEvent):void {
				if(ev.detail == Alert.YES) {
					var evt:TabBarEvent = new TabBarEvent(TabBarEvent.CLOSE_TAB,
						tabBar.selectedItem.label, tabBar.selectedItem.uid);
					tabUIDs[tabBar.selectedItem.uid] = undefined;
					tabBar.dataProvider.removeItemAt(tabBar.selectedIndex);
										
					dispatchEvent(evt);
					if(tabBar.dataProvider.length == 0) {
						dataProvider = new ArrayCollection([{"label":"untitled", "uid":0}]);
					} else {
						dispatchEvent(new TabBarEvent(TabBarEvent.SELECT_TAB,
							tabBar.selectedItem.label, tabBar.selectedItem.uid));
					}
					path.valueBy = scrollContainer.getHorizontalScrollPositionDelta(
						NavigationUnit.HOME);
					anim.play();
				}
			}
		}
	}
}