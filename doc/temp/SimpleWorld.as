package raymulticast
{
	import flash.geom.Point;
	/**
	 * <p>A basic implementation of the World interface.</p>
	 * 
	 */
	public class SimpleWorld implements World
	{		
		private var obstructions:Array; //(*** was boolean[][] ***)
		private var size:int;
		
		public function SimpleWorld(size:int)
		{
			this.size = size;
			obstructions = new Array();//(*** was new boolean[size][size]; ***)
			for (var x:int = 0; x < size; x++) //construct the 2nd dimension of array
			{
				obstructions[x] = new Array(size);
				for (var y:int = 0; y < size; y++) //initialize to false
				{
					obstructions[x][y] = false;
				}
			}
		}
		
		public function getSize():int
		{
			return size;
		}
		
		public function addObstructionAt(x:int, y:int):void
		{
			obstructions[x][y] = true;
		}
		
		public function hasObstructionAt(x:int, y:int):Boolean
		{
			return obstructions[x][y];
		}
		
		public function getObstructions():Array
		{
			var coordinates:Array = new Array();
			var size:int = obstructions.length;
			
			for (var x:int = 0; x < size; x++) //construct the 2nd dimension of array
			{
				for (var y:int = 0; y < size; y++) //initialize to false
				{
					if (obstructions[x][y])
					{
						coordinates.push(new Point(x, y));
					}
				}
			}
			return coordinates;
		}
	}
}