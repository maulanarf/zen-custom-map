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
	import darkemon.Global;
	import darkemon.application.MapApplication;
	import darkemon.display.Node;
	import darkemon.skins.ControlBarSkin;
	import darkemon.skins.DropUpListSkin;
	import darkemon.skins.TabBarButtonCloseSkin;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Spacer;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	import spark.components.TextInput;
	import spark.layouts.HorizontalLayout;

	public class ControlPanel extends SkinnableContainer {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var _searchResult:Array = null;
		private var _currentIndex:int = -1;
		private var _global:Global = null;
		
		private var resultLabel:Label = new Label();
		private var textInput:TextInput = new TextInput();
		private var searchList:DropDownList = new DropDownList();
		private var nextSearchBtn:Button = new Button();
		private var prevSearchBtn:Button = new Button();
		
		[Embed(source="assets/search_icon.png")]
		private var searchIcon:Class;
		
		[Embed(source="assets/next_search_icon.png")]
		private var nextSearchIcon:Class;
		
		[Embed(source="assets/prev_search_icon.png")]
		private var prevSearchIcon:Class;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function ControlPanel(g:Global) {
			_global = g;
			
			layout = new HorizontalLayout();
			(layout as HorizontalLayout).verticalAlign = "middle";
			setStyle("skinClass", darkemon.skins.ControlBarSkin);
			
			var searchImage:Image = new Image();
			searchImage.source = searchIcon;
			searchImage.height = searchImage.width = 24;
			
			// Search settings section
			var searchLabel:Label = new Label();
			searchLabel.text = "Search by";
			searchLabel.setStyle("verticalAlign", "bottom");
			searchList.dataProvider = new ArrayCollection(["Name", "IP address"]);
			searchList.selectedIndex = 0;
			
			// Result label
			resultLabel.text = "";
			resultLabel.setStyle("verticalAlign", "bottom");
			
			// Buttons
			nextSearchBtn.label = "Next";
			prevSearchBtn.label = "Previous";
			nextSearchBtn.setStyle("icon", nextSearchIcon);
			prevSearchBtn.setStyle("icon", prevSearchIcon);
			nextSearchBtn.enabled = prevSearchBtn.enabled = false;
			
			// Spacers
			var space1:Spacer = new Spacer();
			var space2:Spacer = new Spacer();
			space1.width = space2.width = 1;
						
			addElement(searchImage);
			addElement(textInput);
			addElement(prevSearchBtn);
			addElement(nextSearchBtn);
			addElement(space1);
			addElement(searchLabel);
			addElement(searchList);
			addElement(space2);
			addElement(resultLabel);
			
			// Add listeners
			textInput.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			prevSearchBtn.addEventListener(MouseEvent.CLICK, prevHandler);
			nextSearchBtn.addEventListener(MouseEvent.CLICK, nextHandler);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function resetResult():void {
			_searchResult = null;
			_currentIndex = -1;
			resultLabel.text = "";
			nextSearchBtn.enabled = prevSearchBtn.enabled = false;
			Node.unselectAll();
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function updateButtonState():void {
			nextSearchBtn.enabled = prevSearchBtn.enabled = true;
			if(_currentIndex == 0) prevSearchBtn.enabled = false;
			if(_currentIndex == _searchResult.length - 1) 
				nextSearchBtn.enabled = false;
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function keyListener(e:KeyboardEvent):void {
			if(e.keyCode == Keyboard.ENTER)
			{
				resetResult();
				switch(searchList.selectedItem.toString()) {
					case "Name":
						_searchResult = 
							_global.dataProvider.searchNodes(textInput.text);
						break;
					case "IP address":
						_searchResult = 
							_global.dataProvider.searchNodes(textInput.text, "ip");
						break;
				}
				resultLabel.text = "Found "+String(_searchResult.length)+"" +
					" objects.";
				if(_searchResult.length >= 1) {
					_currentIndex = 0;
					Node.selectionMode = Node.SINGLE_SELECTION;
					var n:Node = _searchResult[0] as Node;
					n.select = true;
					_global.scene.showNodeInCenter(n.x, n.y);
					updateButtonState();
				}
			}
		}
		
		private function nextHandler(e:MouseEvent):void {
			Node.selectionMode = Node.SINGLE_SELECTION;
			var n:Node = _searchResult[++_currentIndex] as Node;
			n.select = true;
			_global.scene.showNodeInCenter(n.x, n.y);
			updateButtonState();
		}
		
		private function prevHandler(e:MouseEvent):void {
			Node.selectionMode = Node.SINGLE_SELECTION;
			var n:Node = _searchResult[--_currentIndex] as Node;
			n.select = true;
			_global.scene.showNodeInCenter(n.x, n.y);
			updateButtonState();
		}
	}
}