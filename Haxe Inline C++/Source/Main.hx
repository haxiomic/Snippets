package;

import cpp.Pointer;
import geom.Vec3;
import haxe.ds.Vector;

abstract FlatVec3Array(Vector<Float>){
	static inline var VEC_SIZE:Int = 3;
	public inline function new(count:Int){
		this = new Vector<Float>(count*VEC_SIZE);
	}

	@:extern public inline function get(index:Int, k:Int):Float
		return this[index*VEC_SIZE + k];

	@:extern public inline function set(index:Int, k:Int, value:Float):Float
		return this[index*VEC_SIZE + k] = value;

	static public inline function fromArrayVec3(array:Array<Vec3>){
		var r = new FlatVec3Array(array.length*3);
		for(i in 0...array.length)
			for(k in 0...3)
				r.set(i, k, array[i][k]);
		return r;
	}
}

class Main{
	@:noStack
	public function new(){
		accessTest();
		//performanceTest();
	}

	@:noStack
	function accessTest(){
/*		positions.pushCopy(
		positions.pushCopy(
		positions.pushCopy(
		
		trace(positions.get(1,1));*/
		var x = new Array<Vec3>();
		x.push(new Vec3(1,3,4));
		x.push(new Vec3(14,33,41));
		x.push(new Vec3(2,35,44));
		var s = FlatVec3Array.fromArrayVec3(x);
		//s[0] = new Vec3();
		trace(s.get(1,1));
	}

	@:noStack
	function performanceTest(){
		var startTime:Float, endTime:Float;
		var runCount:Int = Std.int(10000000*.4);

		var v = new haxe.ds.Vector<Float>(500);
		startTime = Sys.cpuTime();
		for(i in 0...runCount)
			for(j in 0...500)
				v[j] = v[j] + 0.05;
		endTime = Sys.cpuTime();

		trace("Vector: "+(endTime-startTime)+" - "+v[3]);

/*		var a = new Array<Float>();
		for(i in 0...500)a.push(0);

		startTime = Sys.cpuTime();
		for(i in 0...runCount)
			for(j in 0...500)
				a[j] += a[j] + 0.05;
		endTime = Sys.cpuTime();

		trace("Array: "+(endTime-startTime)+" - "+a[3]);*/

		var b = new Array<Float>();
		for(i in 0...500)b.push(0);
		var p:cpp.Pointer<Float> = cpp.Pointer.fromArray(b,0);
		startTime = Sys.cpuTime();
		for(i in 0...runCount)
			for(j in 0...500)
				p[j] = p[j] + 0.05;
		endTime = Sys.cpuTime();

		trace("Pointer to Array: "+(endTime-startTime)+" - "+p[3]);

		var f = new AbsFloats(500);
		startTime = Sys.cpuTime();
		for(i in 0...runCount)
			for(j in 0...500)
				f[j] = f[j] + 0.05;
		endTime = Sys.cpuTime();

		trace("AbsFloats: "+(endTime-startTime)+" - "+f[3]);

/*		var f = new RawArrayFloat(500);
		f[3] = 5;
		var c = f[3];
		trace(c);

		var a = new AbsFloats(10);
		a[5] = 888;
		c = a[5];
		trace(c);

		//so we can use pointers to access raw array values
		var testArray:Array<Float> = [5,6,7,8];
		var p:cpp.Pointer<Float> = cpp.Pointer.fromArray(testArray,0);
		var r = p[3];

		trace(r);*/
	}

}

@:headerClassCode('
	Float * innerArray;
	inline Float __get(int index){return this->innerArray[index];}
	inline Float __set(int index, Float value){return this->innerArray[index] = value;}
') 
class RawArrayFloat implements ArrayAccess<Float>{
	public var length(default, null):Int;
	@:noStack
	public function new(length:Int){
		this.length = length;
		alloc(length);
	}

	@:noStack
	function alloc(length:Int):Void{
		untyped __cpp__('this->innerArray = new Float[length]()');
	}
}


abstract AbsFloats(RawArrayFloat){
	public var length(get, never):Int;

	public function new(length:Int){
		this = new RawArrayFloat(length);
	}

	@:extern
	public inline function get_length():Int
		return this.length;

	@:noStack
	@:arrayAccess
	@:extern
	public inline function get(index:Int):Float{
		return this[index];
	}

	@:noStack
	@:arrayAccess
	@:extern
	public inline function set(index:Int, value:Float):Float{
		return this[index] = value;
	}
}