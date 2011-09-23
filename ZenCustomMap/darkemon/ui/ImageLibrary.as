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
	import com.yahoo.astra.containers.formClasses.FormLayoutStyle;
	import com.yahoo.astra.fl.containers.Form;
	import com.yahoo.astra.fl.utils.FlValueParser;
	import com.yahoo.astra.managers.FormDataManager;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	
	import fl.controls.Button;
	import fl.controls.TileList;
	import fl.controls.ScrollBarDirection;
	import fl.controls.ScrollPolicy;
	import fl.controls.ProgressBar;
	import fl.controls.ProgressBarMode;
	import fl.data.DataProvider;
	
	import darkemon.Global;
	import darkemon.display.Node;
	
	public class ImageLibrary extends MovieClip {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		private static var _instance : ImageLibrary = null;
		private static var _allowInstantiation : Boolean = false;
		private static var _isVisible : Boolean = false;
		private static var _glob : Global;
		private static var _node : Node;
		
		private static var mainForm : Form;
		private static var tileList : TileList;
		private static var okBtn : Button;
		private static var cancelBtn : Button;
		private static var clearBtn : Button;
		private static var loadBtn : Button;
		private static var delBtn : Button;
		private static var preloader : Preloader;
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
			
		public function ImageLibrary() {
			if(!_allowInstantiation) {
				throw Error("ImageLibrary is a singleton class, use getInstance() instead.");
			}
								
			initUI();
			initForm();
			initData();
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public static function getInstance() : ImageLibrary {
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new ImageLibrary();
				_allowInstantiation = false;
			}
			return _instance;
		}
		
		public static function isVisible() : Boolean {
			return _isVisible;
		}
	
		public static function show(p : MovieClip, node : Node, glob : Global) : void {
			if(_instance == null) {
				getInstance();
			}
			
			_node = node;
			_glob = glob;
									
			// Add to scene.
			p.stage.addChild(_instance);
			_instance.x = (p.stage.stageWidth/2) - (mainForm.width/2);
			_instance.y = (p.stage.stageHeight/2) - (mainForm.height/2);
			_isVisible = true;
			
			updateTileList();
		}
	
		public static function hide() : void {
			if(_isVisible) {
				_instance.parent.removeChild(_instance);
				_isVisible = false;
			}
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
	
		private function initUI() : void
		{
			mainForm = new Form();
			tileList = new TileList();
			okBtn = new Button();
			clearBtn = new Button();
			cancelBtn = new Button();
			loadBtn = new Button();
			delBtn = new Button();
			preloader = new Preloader();
			
			okBtn.label = "Set image";
			cancelBtn.label = "Close";
			loadBtn.label = "Load";
			delBtn.label = "Delete";
			clearBtn.label = "Clear";
			
			loadBtn.width = 65;
			delBtn.width = 65;
			clearBtn.width = 65;
			
			tileList.columnWidth = 100;
			tileList.rowHeight = 100;
			tileList.columnCount = 2;
			tileList.rowCount = 2;
			tileList.setSize(215,200);
			tileList.scrollPolicy = ScrollPolicy.ON;
			tileList.direction = ScrollBarDirection.VERTICAL;
		}
		
		private function initForm() : void 
		{
			mainForm = new Form("Images");
			mainForm.alpha = 100;
			mainForm.autoSize = false;
			mainForm.setSize(250,300);
			mainForm.setStyle("skin", "ImageLibrarySkin");
			mainForm.labelAlign = FormLayoutStyle.RIGHT;
			mainForm.paddingLeft = mainForm.paddingRight = mainForm.paddingTop = mainForm.paddingBottom = 10;
			this.addChild(mainForm);
		}
		
		private function initData() : void 
		{
			
			var myFormDataManager:FormDataManager=new FormDataManager(FlValueParser);
					
			mainForm.formDataManager = myFormDataManager;
						
			mainForm.dataSource = [
				{label:"",items:tileList},
				{label:"",items:[loadBtn,delBtn,clearBtn]},
				{label:"",items:[okBtn,cancelBtn]}
			];
			
			okBtn.addEventListener(MouseEvent.CLICK, applyHandler);
			cancelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			loadBtn.addEventListener(MouseEvent.CLICK, loadFileHandler);
			delBtn.addEventListener(MouseEvent.CLICK, deleteFileHandler);
			clearBtn.addEventListener(MouseEvent.CLICK, clearImageHandler);
		}
		
		private function setComponentsState(st : Boolean) : void {
			tileList.enabled = okBtn.enabled = cancelBtn.enabled = 
			    loadBtn.enabled = delBtn.enabled = st;
		}
		
		private function showPreloader() : void {
			setComponentsState(false);
			addChild(preloader);
			preloader.x = (mainForm.width/2) - (preloader.width/2);
			preloader.y = (mainForm.height/2) - (preloader.height/2);
		}
		
		private function hidePreloader() : void {
			removeChild(preloader);
			setComponentsState(true);
		}
		
		private static function updateTileList() : void 
		{
			_instance.showPreloader();
						
			var urlLoader : URLLoader = new URLLoader();
			var urlRequest : URLRequest = new URLRequest(_glob.url);
			var urlVars : URLVariables = new URLVariables(); 

			urlVars.action = "download_nodeimage";
			
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = urlVars;
			
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, loadHandler);

			function loadHandler(e : Event) : void {
				try {
					var xml : XML = new XML(e.target.data);
								
					// Read image name list.
					var dp : DataProvider = new DataProvider();
					for each(var image : XML in xml.elements("image")) 
					{
						var src : String = _glob.url+"?action=download_nodeimage&filename="+
							image.toString();
						dp.addItem({"label":image.toString(),"source":src});
					}
					tileList.dataProvider = dp;
					tileList.drawNow();
				} 
				catch(e : TypeError) {
					trace("Could not parse the XML file.");
					throw Error("Could not parse the XML file.\n"+e.toString());
				}
				finally {
					_instance.hidePreloader();
				}
			}
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
	
		private function cancelHandler(e : MouseEvent) : void {
			hide();
		}
		
		private function applyHandler(e : MouseEvent) : void {
			if(tileList.selectedItem != null) {
				var urlRequest : URLRequest = new URLRequest((tileList.selectedItem).source);
				urlRequest.method = URLRequestMethod.POST;

				_node.loadImageURL(urlRequest,(tileList.selectedItem).label);
				hide();
			}
		}
		
		private function loadFileHandler(e : MouseEvent) : void 
		{
			var fileRef : FileReference = new FileReference(); 
			fileRef.addEventListener(Event.SELECT, selectHandler); 
			fileRef.addEventListener(Event.COMPLETE, completeHandler); 
			
			var progressBar : ProgressBar = new ProgressBar();
			progressBar.mode = ProgressBarMode.EVENT;
			progressBar.indeterminate = false;
			progressBar.source = fileRef;
			progressBar.setSize(250, 12);
			
			try 
			{ 
				var imageTypes : FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", 
															 "*.jpg; *.jpeg; *.gif; *.png"); 
			    var success : Boolean = fileRef.browse([imageTypes]);
			} 
			catch (error:Error) 
			{ 
			    trace("Unable to browse for files."); 
			}
						
			// Handlers.
			function selectHandler(event : Event) : void { 
			    var urlRequest : URLRequest = new URLRequest(_glob.url) ;
				var urlVars : URLVariables = new URLVariables();
				
				urlRequest.method = URLRequestMethod.POST;
				urlVars.action = "upload_nodeimage";
				urlRequest.data = urlVars;
			    
				try 
				{ 
			        fileRef.upload(urlRequest);
					_instance.addChild(progressBar);
			    } 
				catch (error:Error) 
				{ 
			        trace("Unable to upload file.");
    			} 
			}
			
			function completeHandler(event : Event) : void { 
    			trace("uploaded");
				_instance.removeChild(progressBar);
				updateTileList();
			}
		}
		
		private function deleteFileHandler(e : Event) : void 
		{
			var urlLoader : URLLoader = new URLLoader();
			var urlRequest : URLRequest = new URLRequest(_glob.url);
			var urlVars : URLVariables = new URLVariables(); 

			urlVars.action = "delete_nodeimage";
			urlVars.filename = (tileList.selectedItem).label;
			
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = urlVars;
			
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			
			function completeHandler(e : Event) : void { 
				urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
    			updateTileList();
			}
		}
		
		private function clearImageHandler(e : Event) : void {
			_node.deleteImage();
			hide();
		}
	}
}