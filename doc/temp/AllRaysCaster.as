package raymulticast
{
	import flash.geom.Point;
	//Only used for the complete event, so not really req'd if
	//ResultsDislayer:traceResults() is not used.
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Casts rays from a single point through a {@link World} object, which describes 
	 * impassable locations. Fills in a 2D array of {@link RayData} objects, 
	 * describing the visibility status of each point in the world as viewed from the 
	 * defined origin point. 
	 * 
	 * Rays take full advantage of work done by previous ray casts, and do not get 
	 * cast into occluded areas, making for near-optimal efficiency.
	 * 
	 * The results array is not necessary for the algorithm's operation - it is 
	 * generated for external use. 
	 * 
	 */
	public class AllRaysCaster extends EventDispatcher
	{		
		private var world:World; // holds obstruction data
		private var origin:Point; // the point at which the rays will be cast from
		private var perimeter:Array; // rays currently on the search frontier (*** was of type Queue<RayData> ***)
		private var results:Array; // stores calculated data for external use (*** was of type RayData[][] ***)
		private var currentData:RayData;
		
		public function AllRaysCaster(world:World, originX:int, originY:int)
		{
			this.world = world; 
			this.origin = new Point(originX, originY);
			this.perimeter = new Array(); //(*** was new LinkedList<RayData>() ***)
			var worldSize:int = world.getSize();
			this.results = new Array(worldSize);// was new RayData[world.getSize()][world.getSize()]; 
			for (var i:int = 0; i < worldSize; i++) //construct the 2nd dimension of array
			{
				this.results[i] = new Array(worldSize);
			}
			expandPerimeterFrom(new RayData(0, 0));
		}
		
		public function getOrigin():Point
		{
			return this.origin;
		}
		
		//may be somewhat redundant as castRays() returns results on every cycle
		public function getResults():Array //(*** was RayData[][]***)
		{
			return this.results;
		}
		
		//Executes the ray casting operation by running a breadth-first traversal 
		//(flood) of the world, beginning at the origin. 
		public function castRays():Array //was void
		{
			//expandPerimeterFrom(new RayData(origin.x, origin.y));
			//var currentData:RayData;
			//while (perimeter.length > 0)
			if (perimeter.length > 0)
			{
				trace ("perimeter length is", perimeter.length);
				
				//NOTE: The following step would be about 10x faster using a linked-list
				//based queue such as the one available at Polygonal labs:
				//http://lab.polygonal.de/2007/05/23/data-structures-example-the-queue-class/
				//This is because the AS3 native array used here requires downward
				//reshifting of every element in the array after we remove the first element
				//as is req'd in a Queue (FIFO). I have however used the shift function here
				//as it's native to AS3, letting this app work without extra libraries.
				currentData = perimeter.shift();
				
				// since we are traversing breadth-first, all inputs are guaranteed 
				// to be added to current data by the time it is removed.
				mergeInputs(currentData);
				if (!currentData.ignore)
					expandPerimeterFrom(currentData);
			}
			else
				dispatchEvent(new Event(Event.COMPLETE));
			return this.results;
		}
		
	
		// Expands by the unit length in each component's current direction.
		// If a component has no direction, then it is expanded in both of its 
		// positive and negative directions. This is essentially expanding
		// Bresenhams algorithm for a single octant, to include all octants.
		// See wikipedia for more.
		private function expandPerimeterFrom(from:RayData):void
		{			
			if (from.xLoc >= 0)
			{
				processRay(new RayData(from.xLoc + 1, from.yLoc), from);
			}
			if (from.xLoc <= 0) 
			{
				processRay(new RayData(from.xLoc - 1, from.yLoc), from);
			}
			if (from.yLoc >= 0) 
			{
				processRay(new RayData(from.xLoc, from.yLoc + 1), from);
			}
			if (from.yLoc <= 0) 
			{
				processRay(new RayData(from.xLoc, from.yLoc - 1), from);
			}
		}
		
	
		// Does bounds checking, marks obstructions, assigns inputs, and adds the 
		// ray to the perimeter if it is valid.
		private function processRay(newRay:RayData, inputRay:RayData):void
		{
			var mapX:int = origin.x + newRay.xLoc;
			var mapY:int = origin.y + newRay.yLoc;
	
			// bounds check
			if((mapX < 0) || (mapX > (world.getSize() - 1)))
				return;
			if((mapY < 0) || (mapY > (world.getSize() - 1)))
				return;
			
			// Since there are multiple inputs to each new ray, we need to check if 
			// the new ray has already been set up.
			// Here we use the results table as lookup, but we could easily use 
			// a different structure, such as a hashset keyed point data.
			if (results[mapX][mapY] != null) //since not strict equality, equates also to undefined.
				newRay = results[mapX][mapY];
			
			// Setting the reference from the new ray to this input ray.
			var isXInput:Boolean = (newRay.yLoc == inputRay.yLoc);
			if (isXInput) newRay.xInput = inputRay;
			else newRay.yInput = inputRay;
			
			// Adding the new ray to the perimeter if it hasn't already been added.
			if (!newRay.added)
			{
				perimeter.push(newRay);
				newRay.added = true;
				results[origin.x + newRay.xLoc][origin.y + newRay.yLoc] = newRay;
			}
		}
		
	
		// Once all inputs are known to be assigned, mergeInputs performs the key 
		// task of populating the new ray with the necessary obscurity data. 
		private function mergeInputs(newRay:RayData):void
		{
			trace("mergeInputs for",(origin.x + newRay.xLoc), 
									(origin.y + newRay.yLoc));
			//1. Special case: newRay is on an Obstruction. Obstructions propagate obscurity.
			if( world.hasObstructionAt( (origin.x + newRay.xLoc), 
										(origin.y + newRay.yLoc)) )
			{
				var absXLoc:int = newRay.xLoc < 0 ? -newRay.xLoc : newRay.xLoc;//Math.abs unneeded
				var absYLoc:int = newRay.yLoc < 0 ? -newRay.yLoc : newRay.yLoc;//Math.abs unneeded
				newRay.xObsc = absXLoc;
				newRay.yObsc = absYLoc;
				newRay.xErrObsc = newRay.xObsc;
				newRay.yErrObsc = newRay.yObsc;
				return; 
			}
			
			// Process individual input information, determining obscurity and all-out 
			// culling. If both inputs are null, the point is never checked, so ignorance 
			// is propagated trivially in that case.

			var xInput:RayData = newRay.xInput;
			var yInput:RayData = newRay.yInput;
			var xInputNull:Boolean = (xInput == null);
			var yInputNull:Boolean = (yInput == null);
			//if (newRay.xLoc == 3 && newRay.yLoc == 1) //DEBUG
				//trace("Breakpoint!");
			if(!xInputNull) processXInput(newRay, xInput);
			if(!yInputNull) processYInput(newRay, yInput);
			
			// Culling handled here. If both inputs are null, the point is never checked,
			// so ignorance of "beyond" tiles is propagated trivially in that case.
			
			if (xInputNull) //rays vertical from origin have no x-input
			{
				trace("xInput is null");
				// cut point (inside edge)
				if(yInput.obscured) newRay.ignore = true;
			}
			else if(yInputNull) //rays horizontal from origin have no y-input 
			{
				trace("yInput is null");
				// cut point (inside edge)
				if(xInput.obscured) newRay.ignore = true;
			}
			else  //both y and x inputs are valid, this means any non-vertical/non-horizontal rays (w.r.t. origin)
			{
				trace("both xInput & yInput are null");
				// cut point (within arc of obscurity)
				if (xInput.obscured && yInput.obscured)
				{
					newRay.ignore = true;
					return;
				}
			}
		}
		
	
		// The X input can provide two main pieces of information for the RayData: 
		// 1. Progressive X obscurity.
		// 2. Recessive Y obscurity.
		private function processXInput(newRay:RayData, xInput:RayData):void
		{
			trace("processXInput for ",(origin.x + newRay.xLoc),
										(origin.y + newRay.yLoc));
			// Progressive X obscurity
			if(xInput.xErrObsc > 0) //if there is a positive Obscurity Error factor on the xInput
			{
				trace("...xInput.xErrObsc > 0");
				//if xInput ray is as yet unobscured by a vector with an x-component
				if(newRay.xObsc == 0) 
				{ // favouring recessive input angle
				
					//"Because we stepped in the X direction, we adjust the data to suit:
					//the X value drops by the vector Y, and the Y value increases by the
					//vector Y. Or rather, since we moved in the X direction, our
					//propensity to move further in the X direction is reduced, and our
					//propensity to move in the Y direction is increased (by the amount
					//needed to follow the ray)."
					//So, here we change "propensities":
					//(1) The new ray's Obscurity Error factor in x is the same as its
					//xInput's, minus the xInput's own Obscurity factor in x.
					//(2) The new ray's Obscurity Error factor in y is the same as its
					//xInput's, *plus* the xInput's own Obscurity factor in y.
					newRay.xErrObsc =  xInput.xErrObsc - xInput.yObsc;//(1)
					newRay.yErrObsc =  xInput.yErrObsc + xInput.yObsc;//(2)

					//simple propagation of the obstruction vector
					newRay.yObsc = xInput.yObsc; 
					newRay.xObsc = xInput.xObsc;
				}
			}
			// Recessive Y obscurity
			if(xInput.yErrObsc <= 0)  //if there is a negative Obscurity Error factor on the xInput
			{
				trace("...xInput.yErrObsc <= 0");
				//if xInput ray is as yet (negatively) obscured by a vector with a y-component,
				//and it's Obscurity Error factor in x is greater than 0
				if((xInput.yObsc > 0) && (xInput.xErrObsc > 0)) 
				{ 
					//for an explanation, see comment in above if statement for Progressive X obscurity.
					newRay.yErrObsc =  xInput.yErrObsc + xInput.yObsc;
					newRay.xErrObsc =  xInput.xErrObsc - xInput.yObsc;
					
					//simple propagation of the obstruction vector to this new ray from it's input
					newRay.xObsc = xInput.xObsc;
					newRay.yObsc = xInput.yObsc;
				}
			}
		}
		
		
		// The Y input can provide two main pieces of information for the RayData:
		// 1. Progressive Y obscurity.
		// 2. Recessive X obscurity.
		private function processYInput(newRay:RayData, yInput:RayData):void
		{
			trace("processYInput for ",(origin.x + newRay.xLoc),
									(origin.y + newRay.yLoc));
			// Progressive Y obscurity
			if(yInput.yErrObsc > 0)
			{
				trace("...yInput.yErrObsc > 0");
				if(newRay.yObsc == 0)
				{ // favouring recessive input angle
					newRay.yErrObsc = (yInput.yErrObsc - yInput.xObsc);
					newRay.xErrObsc = (yInput.xErrObsc + yInput.xObsc);
					newRay.xObsc = yInput.xObsc;
					newRay.yObsc = yInput.yObsc;
				}
			}
			// Recessive X obscurity
			if(yInput.xErrObsc <= 0)
			{
				trace("...yInput.xErrObsc <= 0");
				if((yInput.xObsc > 0) && (yInput.yErrObsc > 0))
				{ 
					newRay.xErrObsc = (yInput.xErrObsc + yInput.xObsc);
					newRay.yErrObsc = (yInput.yErrObsc - yInput.xObsc);
					newRay.xObsc = yInput.xObsc;
					newRay.yObsc = yInput.yObsc;
				}
			}
		}
	}
}