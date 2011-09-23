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
	import com.yahoo.astra.containers.formClasses.FormItem;
	import com.yahoo.astra.fl.containers.Form;
	import com.yahoo.astra.fl.utils.FlValueParser;
	import com.yahoo.astra.managers.FormDataManager;
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import fl.controls.ComboBox;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.data.DataProvider;
	
	import flash.xml.*;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import darkemon.Global;
	import darkemon.display.Node;
			
	public class NodeDialog extends Sprite {

	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _instance : NodeDialog = null;
		private static var _allowInstantiation : Boolean = false;
		private static var _isVisible : Boolean = false;
		
		private static var mainForm : Form;
		private static var pathList : ComboBox;
		private static var deviceList : ComboBox;
		private static var deviceName : Label;
		private static var okBtn : Button;
		private static var cancelBtn : Button;
		private static var dictData : Object;
		private static var node : Node;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function NodeDialog() {
			if(!_allowInstantiation) {
				throw Error("NodeDialog is a singleton class, use getInstance() instead.");
			}
			initUI();
			initForm();
			initData();
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------

		public static function getInstance() : NodeDialog {
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new NodeDialog();
				_allowInstantiation = false;
			}
			return _instance;
		}
	
		public static function isVisible() : Boolean {
			return _isVisible;
		}
	
		public static function show(p : MovieClip, n : Node, glob : Global) : void {
			if(_instance == null) {
				getInstance();
			}
			
			var preloader : Preloader = new Preloader();
			p.stage.addChild(preloader);
			preloader.x = (p.stage.stageWidth/2) - (preloader.width/2);
			preloader.y = (p.stage.stageHeight/2) - (preloader.height/2);
			
			node = n;
			deviceName.text = n.nodeName;
			
			var urlLoader : URLLoader = new URLLoader();
			var urlRequest : URLRequest = new URLRequest(glob.url);
			var urlVars : URLVariables = new URLVariables(); 

			urlVars.action = "get_devicelist";
			
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = urlVars;
			
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, loadHandler);

			function loadHandler(e : Event) : void {
				try {
					dictData = new Object();
					var xml : XML = new XML(e.target.data);
								
					// Read device list.
					var dp : DataProvider = new DataProvider();
					var devices : Array;
					for each(var classNode : XML in xml.elements("class")) 
					{
						if(dictData[classNode.attribute("path")] == undefined) devices = new Array();
						else devices = dictData[classNode.attribute("path")];
						
						for each(var devNode : XML in classNode.elements("device"))
						{
							var dev : Object = new Object();
							dev.label = devNode.toString();
							dev.data = devNode.attribute("ip");
							devices.push(dev);
						}
						dictData[classNode.attribute("path")] = devices;
						var ob : Object = new Object();
						ob.label = classNode.attribute("path");
						dp.addItem(ob);
					}
					
					pathList.dataProvider = dp;
					
					pathList.sortItems(_instance.sortString);
					pathList.selectedIndex = 0;
					pathList.dispatchEvent(new Event(Event.CHANGE));
				
					// Add to scene.
					p.stage.removeChild(preloader);
					p.stage.addChild(_instance);
					_instance.x = (p.stage.stageWidth/2) - (mainForm.width/2);
					_instance.y = (p.stage.stageHeight/2) - (mainForm.height/2);
					_isVisible = true;
				
				} 
				catch(e : TypeError) {
					trace("Could not parse the XML file.");
					throw Error("Could not parse the XML file.\n"+e.toString());
				}
			}
		}
	
		public static function hide() : void {
			if(_isVisible) {
				_instance.parent.stage.removeChild(_instance);
				_isVisible = false;
			}
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function initUI() : void
		{
			pathList   = new ComboBox();
			deviceList = new ComboBox();
			deviceName = new Label();
			okBtn      = new Button();
			cancelBtn  = new Button();
			pathList.dropdownWidth = 250;
			deviceList.dropdownWidth = 250;
			deviceName.text = "...";
			okBtn.label     = "Ok";
			cancelBtn.label = "Cancel";
		}
		
		private function initForm() : void 
		{
			mainForm = new Form("Node preferences");
			mainForm.alpha = 100;
			mainForm.autoSize = false;
			mainForm.setSize(286, 142);
			mainForm.setStyle("skin", "FormSkin");
			mainForm.paddingLeft = mainForm.paddingRight = mainForm.paddingTop = mainForm.paddingBottom = 20;
			this.addChild(mainForm);
		}
		
		private function initData() : void 
		{
			// Init FormDataManager with FlValueParser since we are using UIcomponents.  
			var myFormDataManager:FormDataManager=new FormDataManager(FlValueParser);
			
			// Define formDataManager in Form before set dataSource.    
			mainForm.formDataManager = myFormDataManager;
			
			// Define dataSource with data array.           
			mainForm.dataSource = [{label:"Name:", items:deviceName},
								   {label:"",items:[pathList,deviceList]},
								   {label:"",items:[okBtn,cancelBtn]}];	
			
			okBtn.addEventListener(MouseEvent.CLICK, applyHandler);
			cancelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			pathList.addEventListener(Event.CHANGE, selectDeviceClass);
		}
		
		private function sortString(a:Object, b:Object) : Boolean {
		    return a.label > b.label;
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
	
		private function selectDeviceClass(e : Event) : void {
			var dp : DataProvider = new DataProvider(dictData[pathList.selectedLabel]);
			deviceList.dataProvider = dp;
			deviceList.sortItems(_instance.sortString);
			deviceList.selectedIndex = 0;
		}
		
		private function cancelHandler(e : MouseEvent) : void {
			hide();
		}
		
		private function applyHandler(e : MouseEvent) : void {
			var ob : Object = deviceList.selectedItem;
			node.nodeName = ob.label;
			node.ip = ob.data;
			node.zpath = pathList.selectedLabel;
			hide();
		}
	}
}