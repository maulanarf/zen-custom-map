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
package darkemon {
	import darkemon.display.Node;
	
	public class NodeArray {
		
		private var edgeArray : Array = new Array();
		private var nodeArray : Array = new Array();
		
		public function removeAll() : void {
			edgeArray = new Array();
			nodeArray = new Array();
		}
		
		/*
		*	Nodes.
		*/
		
		public function getFirstFreeNodeID() : int {
			for(var i:int=0; i<=nodeArray.length; i++) {
				if(nodeArray[i] == undefined) { return i; }
			}
			return nodeArray.length;
		}
		
		public function addNode(id : int, node : Node) : void {
			if(nodeArray[id] is Node) { throw new Error("Node with id "+id+" already exist."); }
			nodeArray[id] = node;
		}
		
		public function removeNode(id : int) : void {
			nodeArray[id].free();
			nodeArray[id] = undefined;
		}
		
		public function getNode(id : int) : Node { 
			if(nodeArray[id] == undefined) {
				return null;
			}
			return nodeArray[id]; 
		}
		
		public function length() : int { return nodeArray.length; }
		
		/*
		*	Edges.
		*/
		
		public function addEdge(sourceID : int, targetID : int) : void {
			var arr : Array;
			if(sourceID > targetID) {
				var tmp : int = sourceID;
				sourceID = targetID;
				targetID = tmp;
			}
			if(edgeArray[sourceID] == undefined) {
				arr = new Array();
			} else {
				arr = edgeArray[sourceID];
			}
			if(arr.indexOf(targetID) == -1) {
				arr.push(targetID);
			}
			edgeArray[sourceID] = arr;
		}
		
		public function removeEdge(sourceID : int, targetID : int) : void {
			if(sourceID > targetID) {
				var tmp : int = sourceID;
				sourceID = targetID;
				targetID = tmp;
			}
			if(edgeArray[sourceID] != undefined) {
				var arr : Array = edgeArray[sourceID];
				if(arr.length == 1) {
					edgeArray[sourceID] = undefined;
				} else {
					var i : int = arr.indexOf(targetID);
					arr.splice(i,1);
				}
			} 
		}
		
		public function removeEdgesFrom(sourceID : int) : void {
			for(var i:int=0; i<edgeArray.length; i++) {
				if(edgeArray[i] != undefined) {
					var a : Array = edgeArray[i];
					for(var j:int=0; j<a.length; j++) {
						if(a[j] == sourceID) {
							a.splice(j,1);
						}
					}
				}
			}
			if(edgeArray[sourceID] != undefined) {
				edgeArray[sourceID] = undefined;
			} 
		}
		
		public function getEdgesFrom(sourceID : int) : Array {
			if(edgeArray[sourceID] == undefined) {
				return null;
			} else {
				return edgeArray[sourceID];
			}
		}
		
		public function lengthEdgeArray() : int { return edgeArray.length; }
		
		//===========================================================================
		//							Test methods.
		//===========================================================================
				
		public function showEdges() : String {
			var res : String = new String();
			for(var i:int=0; i<edgeArray.length; i++) {
				if(edgeArray[i] != undefined) {
					var a : Array = edgeArray[i];
					res += "Source: "+i+" Targets: ";
					for(var j:int=0; j<a.length; j++) {
						res += a[j]+" ";
					}
					res += "\n";
				}
			}
			return res;
		}
	}
}