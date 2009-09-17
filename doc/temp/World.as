package raymulticast
{
	
	// This file contains both the public World interface and a 
	// package-visible implementation (SimpleWorld).
	
	/**
	 * <p>A Map object is a simple implementation of a world where some points are 
	 * impenetrable. Points can be marked as obstructed, and checked for obstruction.</p>
	 * 
	 * <p>The implied contract is that obstructionAt(a,b) is true iff 
	 * addObstruction(a,b) was called on the object in the past.</p>
	 * 
	 */
	public interface World
	{
		function getSize():int;
		function addObstructionAt(x:int, y:int):void;
		function hasObstructionAt(x:int, y:int):Boolean;
		function getObstructions():Array;
	}
}

