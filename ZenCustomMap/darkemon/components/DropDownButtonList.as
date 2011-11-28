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

package darkemon.components {
	import darkemon.skins.DropDownButtonSkin;
	
	import flash.events.MouseEvent;
	
	import spark.components.ToggleButton;
	import spark.components.VGroup;
	import spark.skins.spark.ToggleButtonSkin;
	
	public class DropDownButtonList extends VGroup {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var headContainer:VGroup = new VGroup();
		private var bodyContainer:VGroup = new VGroup();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function DropDownButtonList() {
			super();
			gap = -1;
			headContainer.gap = -1;
			bodyContainer.gap = -1;
			bodyContainer.visible = false;
			addElement(headContainer);
			addElement(bodyContainer);
			
			bodyContainer.addEventListener(MouseEvent.MOUSE_OVER, headOverHandler);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function addButton(btn:ToggleButton):void {
			if(headContainer.numChildren == 0) {
				headContainer.addElement(btn);
				btn.setStyle("skinClass", Class(darkemon.skins.DropDownButtonSkin));
				btn.addEventListener(MouseEvent.MOUSE_OVER, headOverHandler);
			} else {
				bodyContainer.addElement(btn);
			}
			btn.addEventListener(MouseEvent.CLICK, selectHandler);
			btn.addEventListener(MouseEvent.MOUSE_OUT, bodyOutHandler);
		}
	
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private function selectHandler(e:MouseEvent):void {
			var btn:ToggleButton = e.target as ToggleButton;
			if(btn.parent == bodyContainer) {
				var i:int = bodyContainer.getElementIndex(btn);
				var oldHeadBtn:ToggleButton = headContainer.getElementAt(0) as ToggleButton;
				btn.addEventListener(MouseEvent.MOUSE_OVER, headOverHandler);
				oldHeadBtn.removeEventListener(MouseEvent.MOUSE_OVER, headOverHandler);
				bodyContainer.removeElementAt(i);
				headContainer.removeElement(oldHeadBtn);
				bodyContainer.addElementAt(oldHeadBtn, i);
				headContainer.addElement(btn);
				btn.setStyle("skinClass", Class(darkemon.skins.DropDownButtonSkin));
				oldHeadBtn.setStyle("skinClass", Class(spark.skins.spark.ToggleButtonSkin));
				
				for(var j:int=0; j<bodyContainer.numElements; j++) {
					(bodyContainer.getElementAt(j) as ToggleButton).selected = false;
				}
			}
			btn.selected = true;
		}
		
		private function headOverHandler(e:MouseEvent):void {
			bodyContainer.visible = true;
		}
		
		private function bodyOutHandler(e:MouseEvent):void {
			bodyContainer.visible = false;
		}
	}
}