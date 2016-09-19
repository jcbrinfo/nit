# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# First style of specifying type parameter’s bounds of a subset: in the signature.

import core

class Natural #alt1# class Natural[BOOM]
	super Int
	subset do return self >= 0

	fun fib: Natural do
		if self < 2 then return self
		var a = (self - 1).as(Natural).fib
		var b = (self - 2).as(Natural).fib
		return (a + b).as(Natural)
	end
end

class Summable[E: Numeric] #alt2,3#
#alt2# class Summable[E: Natural]
#alt3# class Summable[E: Boom]
	super SequenceRead[E] #alt4,5#
	#alt4# super Bytes
	#alt5# super Range[E]
	subset do return true

	fun sum(default: E): E do
		if is_empty then return default
		var i = iterator
		var total = i.item
		i.next
		for x in i do total = (total + x).as(E)
		return total
	end
end

assert not [3, 2, 1, 0] isa Array[Natural]
var arr = new Array[Natural].with_items(
	3.as(Natural),
	2.as(Natural),
	1.as(Natural),
	0.as(Natural)
)
for x in arr do print(x.fib)
var s = arr.as(
	Summable[Numeric] #alt6# Summable[Natural] #alt7# Summable[Int]
)
print(s.sum(0.as(Natural)))
